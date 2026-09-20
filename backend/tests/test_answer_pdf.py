"""PDF 导出：正文引用芯片、参考文献取舍、附录高亮、文件名与端点契约。"""
from __future__ import annotations

import asyncio
import datetime as dt
import os

import pytest

from app.db import SessionLocal
from app.export.answer_pdf import build_answer_html, export_filename
from app.export.markdown import highlight_quotes
from app.models import Answer

from .conftest import OTHER_TOKEN, USER_TOKEN, auth

BODY = "**结论 / Bottom line**\n\n甲 [1¶3] 乙 [2] 丙 [9] \\[1¶3] `[1¶3]`"


def _paper(n: int, **overrides) -> dict:
    return {"n": n, "pmid": f"pm{n}", "title": f"Paper {n}", "journal": "NEJM", "year": "2024",
            "authors": "A B", "source": "pmc", "relevance": 3, "quartile": "1",
            "n_citations": 2, "n_citations_verified": 2, **overrides}


def _row(**overrides) -> Answer:
    row = Answer(id="a1", status="ready", question="ACE 抑制剂有效吗？", queries=[],
                 options={}, papers=[_paper(1), _paper(2)], body_md=BODY,
                 citations=[{"n": 1, "pid": 3, "sec": "Results", "page": 5,
                             "text": "abc def ghi", "quotes": ["def"], "from_marker": True}],
                 kb_hits=[], trace=[], n_papers=2, n_fulltext=1,
                 created_at=dt.datetime(2026, 9, 19, 2, 0))
    for key, value in overrides.items():
        setattr(row, key, value)
    return row


def test_markers_become_chips_only_for_real_papers():
    html = build_answer_html(_row())

    assert 'href="#c-1-3"' in html and "¶3</span>" in html   # 有附录段落 → 链到附录
    assert 'href="#ref-2"' in html                            # 无段落 → 链到参考文献
    assert "丙 [9]" in html                                   # 越界编号保持字面
    assert "[1¶3] <code>[1¶3]</code>" in html                 # 转义与行内代码都不动
    assert 'id="c-1-3"' in html and 'id="ref-1"' in html and 'id="ref-2"' in html
    assert "结论" in html and "BOTTOM LINE" in html


def test_unused_paper_is_dropped_unless_the_body_cites_it():
    papers = [_paper(1), _paper(2, relevance=0)]
    body = "**结论 / Bottom line**\n\n只引 [1]"

    assert 'id="ref-2"' not in build_answer_html(_row(papers=papers, body_md=body))
    assert 'id="ref-2"' in build_answer_html(_row(papers=papers, body_md=body + " 与 [2]"))


def test_codex_answer_has_no_reference_or_passage_modules():
    """codex 没有结构化 papers，裸 [n] 不是本次论文编号，不能当引用渲染。"""
    html = build_answer_html(_row(body_md=None, answer_md="# 结论\n\n见 [1]", papers=[],
                                  citations=[], options={"engine": "codex"}))

    assert "REFERENCES" not in html and "SOURCE PASSAGES" not in html
    assert "见 [1]" in html
    assert "智能体" in html


def test_highlight_skips_overlapping_and_repeated_quotes():
    # "c d" 起点 2；"def" 首次出现在 4，与之重叠被跳过；末尾第二个 "def" 不参与匹配
    assert highlight_quotes("abc def ghi def", ["def", "c d"]) == "ab<mark>c d</mark>ef ghi def"


def test_export_filename_sanitizes_and_truncates():
    ascii_name, utf8_name = export_filename(_row(question='a/b:c?*"<>|  d'))
    assert utf8_name.startswith("PicoSeek-") and utf8_name.endswith("-a b c d.pdf")
    assert ascii_name == "PicoSeek-a1.pdf"

    long_name = export_filename(_row(question="问" * 50))[1]
    assert long_name.endswith("-" + "问" * 40 + ".pdf")


def _ready_answer(**overrides) -> str:
    with SessionLocal() as db:
        row = _row(**overrides)
        row.user_id = "writer"
        db.add(row)
        db.commit()
        return row.id


async def _fake_pdf(html: str, question: str = "") -> bytes:
    return b"%PDF-1.7\n"


def test_pdf_endpoint_serves_an_attachment_to_the_owner(client, monkeypatch):
    monkeypatch.setattr("app.routers.answers.render_pdf", _fake_pdf)
    answer_id = _ready_answer()

    r = client.get(f"/v1/answers/{answer_id}/pdf", headers=auth(OTHER_TOKEN))

    assert r.status_code == 200
    assert r.headers["content-type"].startswith("application/pdf")
    assert r.content.startswith(b"%PDF-")
    assert "filename*=UTF-8''PicoSeek-" in r.headers["content-disposition"]
    assert r.headers["cache-control"] == "no-store"


def test_pdf_endpoint_rejects_unready_foreign_and_anonymous(client, monkeypatch):
    monkeypatch.setattr("app.routers.answers.render_pdf", _fake_pdf)
    answer_id = _ready_answer(status="running")

    assert client.get(f"/v1/answers/{answer_id}/pdf", headers=auth(OTHER_TOKEN)).status_code == 409
    assert client.get(f"/v1/answers/{answer_id}/pdf", headers=auth(USER_TOKEN)).status_code == 404
    assert client.get(f"/v1/answers/{answer_id}/pdf").status_code == 401


def _chromium_missing() -> bool:
    try:
        from playwright.sync_api import sync_playwright

        with sync_playwright() as pw:
            return not os.path.exists(pw.chromium.executable_path)
    except Exception:  # noqa: BLE001 - 没装 playwright 或浏览器时一律跳过
        return True


@pytest.mark.skipif(_chromium_missing(), reason="没有 Playwright Chromium")
def test_render_pdf_produces_pdf_bytes():
    from app.export.answer_pdf import render_pdf

    pdf = asyncio.run(render_pdf("<html><body><p>中文 test</p></body></html>", "冒烟"))

    assert pdf.startswith(b"%PDF-")
