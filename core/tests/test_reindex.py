"""kb 索引的换代原子性：失败或取消都不能动到线上索引，也不能读到混代。

重建的输入是 library/、输出是 kb/，而 API 正在读同一份 kb/。所以整份索引是
一个文件、一次 rename：读者要么看到上一代、要么看到这一代。这组测试盯的就是
这个不变量——尤其是「新向量配旧元数据」这种长度相等、静默错配的中间态。
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


def _pmids(kb_dir: Path) -> set[str]:
    store = ks.KnowledgeStore(kb_dir=str(kb_dir))
    return {m.get("pmid") for m in store.meta}


def test_failed_promote_keeps_previous_generation(kb: Path, monkeypatch):
    """换代那一步失败后，重新实例化仍读到完整的上一代，而不是两代混合。"""
    before_pmids = _pmids(kb)
    before = _live(kb)
    shutil.rmtree(Path(ks.LIB_DIR) / "39133485")        # 新一代只剩另一篇

    real_replace = ks.os.replace

    def fail_on_promote(src, dst):
        if str(dst).endswith(ks.INDEX_FILE):
            raise OSError("power loss during rename")
        return real_replace(src, dst)

    monkeypatch.setattr(ks.os, "replace", fail_on_promote)
    with pytest.raises(OSError):
        ks.reindex()
    monkeypatch.undo()

    assert _pmids(kb) == before_pmids, "读到的必须整代是旧的，不能缺篇也不能混代"
    assert _live(kb) == before
    assert _staging_leftovers(kb) == []


def test_failed_snapshot_write_keeps_previous_generation(kb: Path, monkeypatch):
    """写快照途中崩溃（写到一半的 tmp）不影响线上索引，也不留半成品。"""
    before = _live(kb)
    calls = {"n": 0}
    real_savez = ks.np.savez

    def die_midway(f, **arrays):
        calls["n"] += 1
        real_savez(f, **arrays)             # 先写点东西进去，模拟半成品
        if calls["n"] >= 2:
            raise OSError("disk full")

    monkeypatch.setattr(ks.np, "savez", die_midway)
    with pytest.raises(OSError):
        ks.reindex()
    monkeypatch.undo()

    assert _live(kb) == before
    assert list(Path(kb).glob("*.tmp")) == []
    assert _staging_leftovers(kb) == []


def test_index_is_a_single_file(kb: Path):
    """多文件布局无法原子更新，因此线上索引必须只有一个权威文件。"""
    assert sorted(p.name for p in kb.iterdir()) == [ks.INDEX_FILE]


def test_legacy_three_file_layout_is_read_then_migrated(tmp_path, monkeypatch):
    """已有部署的 kb/ 是旧布局，必须能直接读，并在下一次保存时自动迁移。"""
    kb_dir = tmp_path / "kb"
    kb_dir.mkdir()
    meta = [{"pmid": "1", "kind": "fact", "pid": 1, "text": "legacy fact"}]
    (kb_dir / "meta.jsonl").write_text(json.dumps(meta[0], ensure_ascii=False) + "\n", encoding="utf-8")
    ks.np.save(kb_dir / "vectors.npy", ks.np.zeros((1, 4), dtype="float32"))
    (kb_dir / "info.json").write_text(json.dumps({"embedder": "hash-bow-v1", "dim": 4}), encoding="utf-8")

    store = ks.KnowledgeStore(kb_dir=str(kb_dir))
    assert store.stats()["items"] == 1
    assert store.stats()["embedder"] == "hash-bow-v1"
    assert ks.index_info(str(kb_dir))["items"] == 1     # 探针也认旧布局

    store._save()
    assert (kb_dir / ks.INDEX_FILE).exists()
    assert sorted(p.name for p in kb_dir.iterdir()) == [ks.INDEX_FILE]
    assert ks.KnowledgeStore(kb_dir=str(kb_dir)).meta == meta
