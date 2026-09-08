"""确定性假 LLM：既能当函数桩（monkeypatch ask.llm），也能当 OpenAI 兼容服务。

用途：无 GPU 也要能跑完整条流水线。回答按 system prompt 前缀分派，并且从
user prompt 里抄真实段落原文，这样 `knowledge_store.verify_citations` 的引文
核实是真的在做匹配，而不是被绕过。

    python -m tests.fake_llm --port 4000       # 起 /v1/models + /v1/chat/completions
"""
from __future__ import annotations

import json
import os
import re
from collections.abc import Iterator

from fastapi import Request
from fastapi.responses import StreamingResponse
from pydantic import BaseModel

PARA_RE = re.compile(r"\[¶(\d+)\]\s*(.+?)(?=\n\[¶\d+\]|\n##|\Z)", re.S)
MARKER_RE = re.compile(r"\[(\d{1,2})¶(\d{1,4})\]")


def _paragraphs(user: str) -> list[tuple[int, str]]:
    return [(int(m.group(1)), " ".join(m.group(2).split())) for m in PARA_RE.finditer(user)]


def _quote(text: str, words: int = 12) -> str:
    """抄一段逐字引文；去掉引号，避免破坏 (¶n: "...") 的解析。"""
    return " ".join(text.replace('"', "").replace("“", "").replace("”", "").split()[:words])


def _cited(user: str) -> tuple[int, str]:
    """故意引第 2 段（而不是第 1 段）：pid 不等于 1 才能暴露段落号串位的 bug。"""
    paras = _paragraphs(user)
    if not paras:
        return 1, "no paragraph text available in prompt"
    pid, text = paras[1] if len(paras) > 1 else paras[0]
    return pid, _quote(text)


def fake_llm(system: str, user: str, max_tokens: int = 2000, think: bool = False,
             temperature: float = 0.2, **_: object) -> str:
    if system.startswith("You are a medical librarian"):
        q = " ".join(user.split())[:120]
        return json.dumps({"english_question": f"english form of: {q}",
                           "queries": ["fake query one", "fake query two", "fake query three"]},
                          ensure_ascii=False)

    if system.startswith("You are a meticulous clinical research analyst"):
        pid, quote = _cited(user)
        return (
            # 照抄 READ_SYS 里的标题（真实模型的行为）：解析器必须跳过标题里的取值范围
            "### Relevance (0-3)\n2 — directly addresses the question.\n"
            "### P — Patient / 研究对象\nAdults described by the paper.\n"
            "### I — Intervention / 干预措施\nThe intervention the paper reports.\n"
            "### C — Comparator / 对照方式\nThe comparator the paper reports.\n"
            "### O — Outcome / 结局指标\nNot reported.\n"
            "### S — Study design / 研究设计\nCohort study.\n"
            "### Key findings relevant to the question\n"
            f'- The paper reports its main result. (¶{pid}: "{quote}")\n'
            "### Limitations stated by the authors\n"
            f'- Observational design. (¶{pid}: "{quote}")\n'
        )

    if system.startswith("You are building a medical knowledge base"):
        pid, quote = _cited(user)
        return json.dumps([{"fact": "The paper reports its main result with exact numbers.",
                            "fact_zh": "该研究报告了带具体数字的主要结果。",
                            "kind": "finding", "pid": pid, "quote": quote}], ensure_ascii=False)

    if system.startswith("You are a medical literature assistant"):
        marker = MARKER_RE.search(user)
        cite = marker.group(0) if marker else "[1]"
        return (f"**结论 / Bottom line** — 依据现有证据给出简要结论 {cite}。\n\n"
                f"**证据 / Evidence**\n- 队列研究报告了主要结局 {cite}。\n\n"
                "**PICOS 证据表 / PICOS table**\n\n"
                "| [n] | P 研究对象 | I 干预措施 | C 对照方式 | O 结局指标 | S 研究设计 |\n"
                "|---|---|---|---|---|---|\n"
                "| [1] | 成人 | 干预 | 对照 | 主要结局 | 队列研究 |\n\n"
                "**局限 / Caveats**\n- 观察性设计，存在残余混杂。\n")

    return "fake-llm: unrecognised system prompt"


class Message(BaseModel):
    role: str
    content: str = ""


class ChatRequest(BaseModel):
    """只声明 ask.py 会发的字段；其余（chat_template_kwargs 等）忽略。"""

    model: str = ""
    messages: list[Message] = []
    max_tokens: int = 2000
    temperature: float = 0.2


def model_name() -> str:
    return os.environ.get("LLM_MODEL", "qwen3-14b")


FAKE_CODEX_ANSWER = """**结论 / Bottom line**: fake-codex 的确定性回答，用于验证 codex 引擎链路。

**证据 / Evidence**
- 这是假模型产出的占位证据 [1]。

**局限 / Caveats**: 本回答来自 fake-llm，不含真实文献。

**参考文献 / References**
[1] Fake A (2026). A deterministic placeholder. Fake Journal. PMID:00000000

*This is a literature summary for research/educational use, not medical advice.*"""


# 让假模型真的调一次 MCP 工具：提问里带 `TOOLTEST_PDF=<路径>` 时，第一轮回一个
# 指向 read_pdf 的 function_call，第二轮把工具返回的原文抄进答案。没有这个指令时
# 就是一次性作答，普通冒烟不受影响。
# 指令是从 JSON 序列化后的 input 里抓的，字符集必须排除引号与反斜杠，否则会把转义带进路径
TOOL_DIRECTIVE = re.compile(r"TOOLTEST_PDF=([\w./-]+)")
MCP_NAMESPACE = "mcp__semantic_scholar"


def _sse(event: str, payload: dict) -> str:
    return f"event: {event}\ndata: {json.dumps(payload, ensure_ascii=False)}\n\n"


def _tool_outputs(request_input: object) -> list[str]:
    return [str(i.get("output") or "") for i in (request_input or [])  # type: ignore[union-attr]
            if isinstance(i, dict) and i.get("type") == "function_call_output"]


def next_output_item(body: dict) -> dict:
    """按请求里已有的工具结果决定这一轮输出：先调工具，再作答。"""
    request_input = body.get("input") or []
    directive = TOOL_DIRECTIVE.search(json.dumps(request_input, ensure_ascii=False))
    outputs = _tool_outputs(request_input)
    if directive and not outputs:
        # namespace 型工具必须把 namespace 与 name 分开给，合成 "ns.tool" 会被
        # codex 判成 unsupported call
        return {"type": "function_call", "id": "fc_1", "call_id": "call_1",
                "namespace": MCP_NAMESPACE, "name": "read_pdf",
                "arguments": json.dumps({"path": directive[1]})}
    text = FAKE_CODEX_ANSWER if not outputs else (
        "**结论 / Bottom line**: 工具返回如下原文。\n\n```\n" + outputs[-1] + "\n```")
    return {"type": "message", "role": "assistant", "id": "msg_1", "status": "completed",
            "content": [{"type": "output_text", "text": text}]}


def responses_stream(item: dict) -> Iterator[str]:
    """Responses API 的最小事件流：codex 只要 created / output_item.done / completed。

    `usage` 的字段一个都不能少（含 total_tokens），否则 codex 判定流未完成并重试。
    """
    usage = {"input_tokens": 1, "input_tokens_details": {"cached_tokens": 0},
             "output_tokens": 1, "output_tokens_details": {"reasoning_tokens": 0},
             "total_tokens": 2}
    yield _sse("response.created", {"type": "response.created", "response": {"id": "resp_fake"}})
    yield _sse("response.output_item.done", {"type": "response.output_item.done", "item": item})
    yield _sse("response.completed", {"type": "response.completed",
                                      "response": {"id": "resp_fake", "usage": usage, "output": [item]}})


def create_app():
    """OpenAI 兼容的最小服务：ask.py 用 /v1/chat/completions，codex 用 /v1/responses。

    请求模型与 `Request` 之类的注解类型必须在模块级导入：本文件开了
    `from __future__ import annotations`，函数内导入的名字 FastAPI 解析不到，
    参数会被当成 query 参数（422）。
    """
    from fastapi import FastAPI

    app = FastAPI(title="fake-llm")

    @app.get("/v1/models")
    def models() -> dict:
        name = model_name()
        return {"object": "list", "data": [{"id": name, "object": "model", "owned_by": "fake"}]}

    @app.post("/v1/chat/completions")
    def chat(req: ChatRequest) -> dict:
        system = next((m.content for m in req.messages if m.role == "system"), "")
        user = next((m.content for m in req.messages if m.role == "user"), "")
        text = fake_llm(system, user, max_tokens=req.max_tokens, temperature=req.temperature)
        return {"id": "fake-1", "object": "chat.completion", "model": req.model or model_name(),
                "choices": [{"index": 0, "finish_reason": "stop",
                             "message": {"role": "assistant", "content": text}}],
                "usage": {"prompt_tokens": len(user) // 4, "completion_tokens": len(text) // 4,
                          "total_tokens": (len(user) + len(text)) // 4}}

    @app.post("/v1/responses")
    async def responses(request: Request) -> StreamingResponse:
        # codex 只用 responses 线协议（0.147 起 wire_api="chat" 已被移除）
        item = next_output_item(await request.json())
        return StreamingResponse(responses_stream(item), media_type="text/event-stream")

    return app


def main() -> None:
    import argparse

    import uvicorn

    ap = argparse.ArgumentParser(description="deterministic fake LLM (OpenAI-compatible)")
    ap.add_argument("--host", default="0.0.0.0")
    ap.add_argument("--port", type=int, default=4000)
    args = ap.parse_args()
    uvicorn.run(create_app(), host=args.host, port=args.port, log_level="warning")


if __name__ == "__main__":
    main()
