"""确定性假 LLM：既能当函数桩（monkeypatch ask.llm），也能当 OpenAI 兼容服务。

用途：无 GPU 也要能跑完整条流水线。回答按 system prompt 前缀分派，并且从
user prompt 里抄真实段落原文，这样 `knowledge_store.verify_citations` 的引文
核实是真的在做匹配，而不是被绕过。

    python -m tests.fake_llm --port 4000       # 起 /v1/models + /v1/chat/completions
"""
from __future__ import annotations

import json
import re

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
            "### Relevance\n2\n"   # 真实模型写 '### Relevance (2)' 或 '### Relevance\n2'，不回抄 (0-3)
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


def create_app():
    """OpenAI 兼容的最小服务，只实现 ask.py 用到的两个端点。"""
    import os

    from fastapi import FastAPI
    from pydantic import BaseModel

    model_name = os.environ.get("LLM_MODEL", "qwen3-14b")
    app = FastAPI(title="fake-llm")

    class Message(BaseModel):
        role: str
        content: str = ""

    class ChatRequest(BaseModel):
        model: str = model_name
        messages: list[Message] = []
        max_tokens: int = 2000
        temperature: float = 0.2

    @app.get("/v1/models")
    def models() -> dict:
        return {"object": "list", "data": [{"id": model_name, "object": "model", "owned_by": "fake"}]}

    @app.post("/v1/chat/completions")
    def chat(req: ChatRequest) -> dict:
        system = next((m.content for m in req.messages if m.role == "system"), "")
        user = next((m.content for m in req.messages if m.role == "user"), "")
        text = fake_llm(system, user, max_tokens=req.max_tokens, temperature=req.temperature)
        return {"id": "fake-1", "object": "chat.completion", "model": req.model,
                "choices": [{"index": 0, "finish_reason": "stop",
                             "message": {"role": "assistant", "content": text}}],
                "usage": {"prompt_tokens": len(user) // 4, "completion_tokens": len(text) // 4,
                          "total_tokens": (len(user) + len(text)) // 4}}

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
