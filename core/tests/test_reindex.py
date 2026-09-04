"""kb 重建的崩溃安全性：失败或取消都不能动到线上索引。

重建的输入是 library/、输出是 kb/，而 API 正在读同一份 kb/。所以重建必须
「先在别处建好、成功后再换上去」，这组测试盯的就是这个不变量。
"""
from __future__ import annotations

import json
import shutil
from pathlib import Path

import pytest

import knowledge_store as ks

FIX = Path(__file__).parent / "fixtures" / "paper_39133485"


@pytest.fixture
def kb(monkeypatch, tmp_path):
    """两篇文献的 library + 一份已建好的线上 kb。"""
    lib, kb_dir = tmp_path / "library", tmp_path / "kb"
    lib.mkdir()
    kb_dir.mkdir()
    for pmid in ("39133485", "20000001"):
        d = lib / pmid
        d.mkdir()
        for name in ("paragraphs.json", "facts.json"):
            shutil.copyfile(FIX / name, d / name)
        meta = json.loads((FIX / "meta.json").read_text(encoding="utf-8"))
        meta["pmid"] = pmid
        (d / "meta.json").write_text(json.dumps(meta, ensure_ascii=False), encoding="utf-8")
    monkeypatch.setattr(ks, "LIB_DIR", str(lib))
    monkeypatch.setattr(ks, "KB_DIR", str(kb_dir))

    items, papers = ks.reindex()
    assert (items, papers) == (ks.KnowledgeStore(kb_dir=str(kb_dir)).stats()["items"], 2)
    return kb_dir


def _live(kb_dir: Path) -> dict:
    return ks.KnowledgeStore(kb_dir=str(kb_dir)).stats()


def _staging_leftovers(kb_dir: Path) -> list[Path]:
    return [p for p in kb_dir.parent.iterdir() if p.name.startswith(".kb-reindex-")]


def test_cancelled_reindex_leaves_live_index_intact(kb: Path):
    before = _live(kb)
    calls = {"n": 0}

    def cancel_on_second() -> bool:
        calls["n"] += 1
        return calls["n"] > 1

    with pytest.raises(ks.ReindexCancelled):
        ks.reindex(should_cancel=cancel_on_second)

    assert _live(kb) == before
    assert _staging_leftovers(kb) == []


def test_crash_midway_leaves_live_index_intact(kb: Path, monkeypatch):
    before = _live(kb)
    calls = {"n": 0}
    real_add = ks.KnowledgeStore.add_paper

    def flaky(self, meta, paras, facts, replace=True):
        calls["n"] += 1
        if calls["n"] > 1:
            raise RuntimeError("disk on fire")
        return real_add(self, meta, paras, facts, replace)

    monkeypatch.setattr(ks.KnowledgeStore, "add_paper", flaky)
    with pytest.raises(RuntimeError):
        ks.reindex()

    assert _live(kb) == before
    assert _staging_leftovers(kb) == []


def test_successful_reindex_replaces_index(kb: Path):
    before = _live(kb)
    shutil.rmtree(Path(ks.LIB_DIR) / "20000001")

    items, papers = ks.reindex()

    assert papers == 1
    assert items < before["items"]
    after = _live(kb)
    assert after["items"] == items
    assert after["papers"] == 1
    assert _staging_leftovers(kb) == []


def test_reindex_of_empty_library_clears_index(kb: Path):
    for d in Path(ks.LIB_DIR).iterdir():
        shutil.rmtree(d)

    assert ks.reindex() == (0, 0)
    assert _live(kb) == {"items": 0, "papers": 0, "by_kind": {}, "embedder": None, "dim": None}
