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


PAPER_FILES = ("fulltext.md", "paragraphs.json", "facts.json", "meta.json")


def _stray_paper_files(lib: Path) -> list[Path]:
    """落在库外或库根的文献文件。`kb.lock` 是既有的跨进程锁，不算产物。"""
    root = lib.parent
    return sorted(p for p in root.rglob("*")
                  if p.name in PAPER_FILES and p.parent in (root, lib))


@pytest.mark.parametrize("title", ["..", ".", ""])
def test_path_component_titles_are_refused(lib, title):
    """`.`/`..`/空串都是合法路径分量，拼进 LIB_DIR 会写到库根甚至库外。"""
    with pytest.raises(ValueError):
        ingest.run_ingest(_src(meta={"title": title}))
    assert _stray_paper_files(Path(lib)) == []


def test_whitespace_title_still_lands_in_a_subdir(lib):
    """core 只保证路径安全：空白折叠成 `_` 是子目录，去空白后的 422 由后端负责。"""
    res = ingest.run_ingest(_src(meta={"title": "   "}))
    assert res.key == "_"
    assert (Path(lib) / "_" / "meta.json").is_file()
    assert _stray_paper_files(Path(lib)) == []


def test_pmid_and_doi_take_precedence_over_title(lib):
    res = ingest.run_ingest(_src(meta={"title": "Trial X", "doi": "10.1016/x.2026"}))
    assert res.key == "10.1016_x.2026"
    assert (Path(lib) / res.key / "meta.json").is_file()

    res = ingest.run_ingest(_src(meta={"title": "Trial X", "doi": "10.1016/x.2026", "pmid": "39133485"}))
    assert res.key == "39133485"