"""codex 引擎的工具闭环：真的拉起 codex 运行时与 MCP，跑通「调用 → 执行 → 结果回传 → 作答」。

这里不打桩 `run_codex`：桩测只能证明落库形状，工具执行整条链断了也照样绿。
假模型（`tests.fake_llm`）第一轮回一个指向 `read_pdf` 的 function_call，第二轮把
工具返回的原文抄进答案，于是断言「答案里出现 PDF 里的标记」等价于断言工具真的执行过。
"""
from __future__ import annotations

import os
import socket
import threading
from pathlib import Path

import pytest
import uvicorn

import ask
from app.services import codex as codex_engine
from picos_paths import PDF_DIR

from .fake_llm import create_app

MARKER = "CODEXTOOLLOOPMARKER42"


def _minimal_pdf(text: str) -> bytes:
    """手写最小 PDF：测试依赖里没有 PDF 生成器，而 pypdf 能从这种文件抽出文本。"""
    stream = b"BT /F1 14 Tf 20 100 Td (" + text.encode() + b") Tj ET"
    bodies = [
        b"<</Type/Catalog/Pages 2 0 R>>",
        b"<</Type/Pages/Kids[3 0 R]/Count 1>>",
        b"<</Type/Page/Parent 2 0 R/MediaBox[0 0 300 200]/Contents 4 0 R"
        b"/Resources<</Font<</F1 5 0 R>>>>>>",
        b"<</Length " + str(len(stream)).encode() + b">>stream\n" + stream + b"\nendstream",
        b"<</Type/Font/Subtype/Type1/BaseFont/Helvetica>>",
    ]
    out = bytearray(b"%PDF-1.4\n")
    offsets = []
    for number, body in enumerate(bodies, 1):
        offsets.append(len(out))
        out += str(number).encode() + b" 0 obj" + body + b"endobj\n"
    xref = len(out)
    out += b"xref\n0 " + str(len(bodies) + 1).encode() + b"\n0000000000 65535 f \n"
    for offset in offsets:
        out += b"%010d 00000 n \n" % offset
    out += (b"trailer<</Size " + str(len(bodies) + 1).encode() + b"/Root 1 0 R>>\nstartxref\n"
            + str(xref).encode() + b"\n%%EOF\n")
    return bytes(out)


@pytest.fixture
def fake_llm_url():
    """真起一个 HTTP 服务：codex 运行时是独立进程，连不上 TestClient 的内存传输。"""
    with socket.socket() as probe:
        probe.bind(("127.0.0.1", 0))
        port = probe.getsockname()[1]
    server = uvicorn.Server(uvicorn.Config(create_app(), host="127.0.0.1", port=port,
                                           log_level="warning"))
    thread = threading.Thread(target=server.run, daemon=True)
    thread.start()
    for _ in range(200):
        if server.started:
            break
        threading.Event().wait(0.05)
    assert server.started, "fake-llm 未能启动"
    yield f"http://127.0.0.1:{port}/v1"
    server.should_exit = True
    thread.join(timeout=10)


@pytest.fixture
def codex_home(tmp_path: Path, monkeypatch):
    home = tmp_path / "codex"
    monkeypatch.setattr(codex_engine, "CODEX_HOME", str(home))
    monkeypatch.setattr(codex_engine, "WORK_DIR", str(home / "work"))
    monkeypatch.setenv("CODEX_HOME", str(home))
    # provider 配置里写的是 env_key；缺这个变量 codex 会直接判 turn failed
    monkeypatch.setenv("LOCAL_QWEN_KEY", os.environ.get("LOCAL_QWEN_KEY", "sk-123456"))
    return home


def test_codex_executes_mcp_tool_and_answers_with_its_output(fake_llm_url, codex_home, monkeypatch):
    pdf = Path(PDF_DIR) / "codex-tool-loop.pdf"
    pdf.parent.mkdir(parents=True, exist_ok=True)
    pdf.write_bytes(_minimal_pdf(MARKER))
    monkeypatch.setattr(ask, "LLM_BASE", fake_llm_url)
    logs: list[str] = []

    result = codex_engine.run_codex(
        f"读取本地 PDF 并复述其内容。TOOLTEST_PDF={pdf.name}",
        emit=lambda e: logs.append(str(e.get("message", ""))),
    )

    assert result.tool_calls == ["semantic_scholar/read_pdf"]
    assert MARKER in result.answer_md, "工具返回的原文没有回到模型，说明闭环断了"
    assert any("mcp: semantic_scholar/read_pdf (completed)" in line for line in logs)
    assert result.thread_id


def test_codex_answers_without_tools_when_prompt_has_no_directive(fake_llm_url, codex_home,
                                                                  monkeypatch):
    monkeypatch.setattr(ask, "LLM_BASE", fake_llm_url)

    result = codex_engine.run_codex("SGLT2 抑制剂对 HFpEF 有什么获益？")

    assert result.tool_calls == []
    assert "结论" in result.answer_md
