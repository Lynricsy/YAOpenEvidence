"""run_ingest 的契约：阶段事件序列、library 落盘（含 source 标记）、失败码。

PDF 解析与 LLM 都换成替身；被断言的是「一篇 PDF 进库」这个可观测结果，
而不是内部调用顺序。
"""
from __future__ import annotations

import json
from pathlib import Path

import pytest

import ingest
import journal_rank as jr
import knowledge_store as ks
import literature as lit

BODY = "--- page 1 ---\n" + ("Sentence about trial outcomes. " * 120)


class _StubStore:
    def __init__(self, *a, **kw) -> None:
        self.added: list[dict] = []

    def add_paper(self, meta, paras, facts, replace=True) -> int:
        self.added.append(meta)
        return 0


@pytest.fixture
def lib(monkeypatch, tmp_path):
    """library / kb 隔到 tmp_path，PDF 解析与抽事实换成替身。"""
    monkeypatch.setattr(ks, "LIB_DIR", str(tmp_path / "library"))
    monkeypatch.setattr(ks, "KB_DIR", str(tmp_path / "kb"))
    monkeypatch.setattr(ks, "KnowledgeStore", _StubStore)
    monkeypatch.setattr(ks, "extract_facts", lambda paras, llm, question="", **kw: [])
    monkeypatch.setattr(lit, "pdf_text", lambda path, max_chars: BODY)
    monkeypatch.setattr(jr, "lookup", lambda issn="", title="": None)
    return tmp_path / "library"


def _stages(events: list[dict]) -> list[str]:
    return [f"{e['stage']}/{e['status']}" for e in events if e["type"] == "stage"]


def _src(**kw) -> ingest.IngestSource:
    base = {"kind": "upload", "pdf_path": "/nonexistent.pdf", "doi": "", "meta": {"title": "Trial X"}}
    return ingest.IngestSource(**(base | kw))


def test_upload_lands_in_library_with_upload_source(lib, monkeypatch):
    events: list[dict] = []
    res = ingest.run_ingest(_src(), emit=events.append)

    assert res.key == "Trial_X"
    assert res.n_paragraphs > 0
    assert (res.n_facts, res.items) == (0, 0)
    assert _stages(events) == ["fulltext/started", "fulltext/finished", "kb/started", "kb/finished"]

    meta = json.loads((Path(lib) / "Trial_X" / "meta.json").read_text(encoding="utf-8"))
    assert meta["source"] == "upload"
    assert meta["title"] == "Trial X"
    assert meta["n_paragraphs"] == res.n_paragraphs
    assert (Path(lib) / "Trial_X" / "fulltext.md").read_text(encoding="utf-8").startswith("# Trial X")


def test_progress_brackets_the_fact_extraction(lib):
    events: list[dict] = []
    ingest.run_ingest(_src(), emit=events.append)
    progress = [(e["stage"], e["current"], e["total"]) for e in events if e["type"] == "progress"]
    assert progress == [("kb", 0, 1), ("kb", 1, 1)]


def test_unreadable_pdf_raises_pdf_unreadable(lib, monkeypatch):
    monkeypatch.setattr(lit, "pdf_text", lambda path, max_chars: "ERROR: encrypted")
    with pytest.raises(ingest.PdfUnreadable) as exc:
        ingest.run_ingest(_src())
    assert exc.value.code == "pdf_unreadable"


def test_scanned_pdf_with_too_little_text_raises_pdf_unreadable(lib, monkeypatch):
    monkeypatch.setattr(lit, "pdf_text", lambda path, max_chars: "--- page 1 ---\nshort")
    with pytest.raises(ingest.PdfUnreadable):
        ingest.run_ingest(_src())


def test_doi_source_without_playwright_raises_fulltext_unavailable(lib, monkeypatch):
    monkeypatch.setattr(ingest, "paywall_fetch", None)
    with pytest.raises(ingest.FulltextUnavailable) as exc:
        ingest.run_ingest(_src(kind="doi", doi="10.1000/x"))
    assert exc.value.code == "fulltext_unavailable"


def test_doi_source_downloads_through_paywall(lib, monkeypatch, tmp_path):
    calls: list[tuple] = []

    class _Fetch:
        @staticmethod
        def download_pdf(doi, out_path, state_path):
            calls.append((doi, out_path, state_path))
            return True, "sciencedirect"

    monkeypatch.setattr(ingest, "paywall_fetch", _Fetch)
    dest = str(tmp_path / "ingest" / "job.pdf")
    res = ingest.run_ingest(_src(kind="doi", doi="10.1000/x", pdf_path=dest,
                                 meta={"title": "Fetched", "journal": "Lancet"}))

    assert res.key == "Fetched"
    assert calls == [("10.1000/x", dest, ingest.PAYWALL_STATE)]
    meta = json.loads((Path(lib) / "Fetched" / "meta.json").read_text(encoding="utf-8"))
    assert meta["source"] == "inst"


def test_failed_institutional_download_raises_fulltext_unavailable(lib, monkeypatch):
    class _Fetch:
        @staticmethod
        def download_pdf(doi, out_path, state_path):
            return False, "paywalled"

    monkeypatch.setattr(ingest, "paywall_fetch", _Fetch)
    with pytest.raises(ingest.FulltextUnavailable, match="paywalled"):
        ingest.run_ingest(_src(kind="doi", doi="10.1000/x"))


def test_cancellation_is_cooperative(lib):
    with pytest.raises(ingest.PipelineCancelled):
        ingest.run_ingest(_src(), should_cancel=lambda: True)
