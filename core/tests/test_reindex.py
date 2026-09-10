"""kb 索引的换代原子性：失败或取消都不能动到线上索引，也不能读到混代。

重建的输入是 library/、输出是 kb/，而 API 正在读同一份 kb/。所以整份索引是
一个文件、一次 rename：读者要么看到上一代、要么看到这一代。这组测试盯的就是
这个不变量——尤其是「新向量配旧元数据」这种长度相等、静默错配的中间态。
"""
from __future__ import annotations

import json
import shutil
import multiprocessing
import threading
from concurrent.futures import ThreadPoolExecutor
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
    return [p for p in kb_dir.iterdir() if p.name.startswith(".kb-reindex-")]


def test_cancelled_reindex_leaves_live_index_intact(kb: Path):
    before = _live(kb)
    cancel = threading.Event()

    def progress(event):
        if event.get("type") == "progress" and event.get("current") == 1:
            cancel.set()

    with pytest.raises(ks.ReindexCancelled):
        ks.reindex(emit=progress, should_cancel=cancel.is_set)

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


def test_staging_lives_inside_kb_dir(kb: Path, monkeypatch):
    """暂存目录必须和线上索引同一个挂载点，否则发布那一次 os.replace 会 EXDEV 失败。

    容器里 kb/ 是独立 bind mount：暂存放到 kb/ 的父目录时，重建每次都会以
    `Invalid cross-device link` 失败。这里直接盯住「暂存建在 kb/ 内」这个不变量。
    """
    seen: list[str] = []
    real_mkdtemp = ks.tempfile.mkdtemp

    def recording_mkdtemp(*args, **kwargs):
        path = real_mkdtemp(*args, **kwargs)
        seen.append(path)
        return path

    monkeypatch.setattr(ks.tempfile, "mkdtemp", recording_mkdtemp)
    ks.reindex()

    staging = [p for p in seen if Path(p).name.startswith(".kb-reindex-")]
    assert len(staging) == 1
    assert Path(staging[0]).parent.resolve() == kb.resolve()


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
        if str(dst) == str(kb / ks.INDEX_FILE):
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
    real_savez = ks.np.savez

    def die_midway(f, **arrays):
        real_savez(f, **arrays)             # 先写点东西进去，模拟半成品
        raise OSError("disk full")

    monkeypatch.setattr(ks.np, "savez", die_midway)
    with pytest.raises(OSError):
        ks.reindex()
    monkeypatch.undo()

    assert _live(kb) == before
    assert list(Path(kb).glob("*.tmp")) == []
    assert _staging_leftovers(kb) == []


def test_legacy_three_file_layout_is_read_then_migrated(tmp_path):
    """已有部署的 kb/ 是旧布局，必须能直接读，并在下一次保存时自动迁移。"""
    kb_dir = tmp_path / "kb"
    kb_dir.mkdir()
    meta = [{"pmid": "1", "kind": "fact", "pid": 1, "text": "legacy fact"}]
    (kb_dir / "meta.jsonl").write_text(json.dumps(meta[0], ensure_ascii=False) + "\n", encoding="utf-8")
    ks.np.save(kb_dir / "vectors.npy", ks.np.array([[1.0, 0.0]], dtype="float32"))
    (kb_dir / "info.json").write_text(
        json.dumps({"embedder": _TinyEmbedder.name, "dim": 2}), encoding="utf-8")

    store = ks.KnowledgeStore(kb_dir=str(kb_dir), embedder=_TinyEmbedder())
    assert store.search("legacy")[0]["text"] == "legacy fact"
    assert ks.index_info(str(kb_dir))["items"] == 1

    _add(store, "2")
    restored = ks.KnowledgeStore(kb_dir=str(kb_dir), embedder=_TinyEmbedder())
    assert {hit["pmid"] for hit in restored.search("query")} == {"1", "2"}
    assert restored.stats()["papers"] == 2
    assert all(not (kb_dir / name).exists() for name in ks.LEGACY_FILES)


class _TinyEmbedder:
    name = "test-two-dimensional"

    def encode(self, texts):
        return ks.np.array([[1.0, 0.0] for _ in texts], dtype="float32")


class _OtherBackend(_TinyEmbedder):
    """同维度、不同后端名——正是 bge-m3 与它的 int8 量化版之间的关系。"""

    name = "test-two-dimensional+quantised"


def _add(store, pmid):
    return store.add_paper({"pmid": pmid, "title": pmid},
                           [{"id": 1, "sec": "", "text": pmid}], [])


def _process_add(kb_dir, pmid, ready, proceed):
    store = ks.KnowledgeStore(kb_dir, _TinyEmbedder())
    ready.set()
    assert proceed.wait(10)
    _add(store, pmid)


def test_preloaded_writers_preserve_both_papers(tmp_path):
    first = ks.KnowledgeStore(str(tmp_path / "kb"), _TinyEmbedder())
    second = ks.KnowledgeStore(first.dir, _TinyEmbedder())
    _add(first, "1001")
    _add(second, "2001")
    assert _pmids(Path(first.dir)) == {"1001", "2001"}


def test_other_backend_is_refused_instead_of_silently_mixed(tmp_path):
    """换了后端却没重建：读和写都必须报错，而不是拿新 query 点乘旧矩阵。

    维度检查在这里帮不上忙——bge-m3 与它的 int8 量化版都是 1024 维，余弦却只有
    0.937、top-5 邻居重合率 0.875，混起来只会静默漂。
    """
    kb_dir = str(tmp_path / "kb")
    _add(ks.KnowledgeStore(kb_dir, _TinyEmbedder()), "1001")

    other = ks.KnowledgeStore(kb_dir, _OtherBackend())
    with pytest.raises(ks.EmbedderMismatch):
        other.search("query")
    with pytest.raises(ks.EmbedderMismatch):
        _add(other, "2001")

    assert _pmids(Path(kb_dir)) == {"1001"}, "被拒的写入不许留下痕迹"
    assert ks.index_info(kb_dir)["embedder"] == _TinyEmbedder.name, "标签不许被覆盖成新后端"


def test_empty_index_accepts_any_backend(tmp_path):
    """空库没有可比性问题：初始化和 reindex 到 staging 都从这里起步。"""
    store = ks.KnowledgeStore(str(tmp_path / "kb"), _OtherBackend())
    assert store.search("query") == []
    assert _add(store, "1001") == 1
    assert ks.index_info(store.dir)["embedder"] == _OtherBackend.name


def test_process_writers_reload_latest_baseline(tmp_path):
    ctx = multiprocessing.get_context("spawn")
    proceed = ctx.Event()
    ready = [ctx.Event(), ctx.Event()]
    kb_dir = str(tmp_path / "kb")
    processes = [ctx.Process(target=_process_add, args=(kb_dir, pmid, signal, proceed))
                 for pmid, signal in zip(("1001", "2001"), ready)]
    try:
        for process in processes:
            process.start()
        assert all(signal.wait(10) for signal in ready)
        proceed.set()
        for process in processes:
            process.join(15)
            assert process.exitcode == 0
        assert _pmids(Path(kb_dir)) == {"1001", "2001"}
    finally:
        proceed.set()
        for process in processes:
            if process.is_alive():
                process.terminate()
            process.join(5)


def test_search_keeps_metadata_from_scored_generation(tmp_path, monkeypatch):
    store = ks.KnowledgeStore(str(tmp_path / "kb"), _TinyEmbedder())
    _add(store, "1001")
    scored, resume = threading.Event(), threading.Event()
    real_argsort = ks.np.argsort

    def gated_argsort(scores):
        scored.set()
        assert resume.wait(10)
        return real_argsort(scores)

    monkeypatch.setattr(ks.np, "argsort", gated_argsort)
    with ThreadPoolExecutor() as pool:
        result = pool.submit(store.search, "query")
        try:
            assert scored.wait(10)
            ks.write_index(store.index_path, [{"pmid": "2001", "kind": "paragraph"}],
                           ks.np.array([[0.0, 1.0]], dtype="float32"), store.info)
            store._load()
        finally:
            resume.set()
        assert result.result(timeout=10)[0]["pmid"] == "1001"
    assert store.search("query")[0]["pmid"] == "2001"


def test_reindex_and_waiting_add_preserve_new_paper(kb, monkeypatch):
    entered, resume, waiting = threading.Event(), threading.Event(), threading.Event()
    real_glob = ks.glob_dirs
    real_flock = ks.fcntl.flock
    writer = ks.KnowledgeStore(str(kb))

    def gated_glob():
        entered.set()
        assert resume.wait(10)
        return real_glob()

    def observed_flock(fd, operation):
        try:
            return real_flock(fd, operation)
        except BlockingIOError:
            waiting.set()
            raise

    monkeypatch.setattr(ks, "glob_dirs", gated_glob)
    monkeypatch.setattr(ks.fcntl, "flock", observed_flock)
    with ThreadPoolExecutor() as pool:
        rebuild = pool.submit(ks.reindex)
        try:
            assert entered.wait(10)
            add = pool.submit(_add, writer, "3001")
            assert waiting.wait(10)
        finally:
            resume.set()
        rebuild.result(timeout=20)
        add.result(timeout=20)
    assert _pmids(kb) == {"39133485", "20000001", "3001"}


@pytest.mark.parametrize("empty", [False, True])
def test_cancel_before_publish_preserves_old_generation(kb, empty):
    before = (kb / ks.INDEX_FILE).read_bytes()
    if empty:
        for directory in Path(ks.LIB_DIR).iterdir():
            shutil.rmtree(directory)
    cancel = threading.Event()

    def emit(event):
        if (empty and event["type"] == "stage") or (
                event["type"] == "progress" and event["current"] == event["total"]):
            cancel.set()

    with pytest.raises(ks.ReindexCancelled):
        ks.reindex(emit=emit, should_cancel=cancel.is_set)
    assert (kb / ks.INDEX_FILE).read_bytes() == before
    assert _staging_leftovers(kb) == []


def test_cancel_while_waiting_for_writer_lock(kb, monkeypatch):
    before = (kb / ks.INDEX_FILE).read_bytes()
    waiting, cancel = threading.Event(), threading.Event()
    real_flock = ks.fcntl.flock

    def observed_flock(fd, operation):
        try:
            return real_flock(fd, operation)
        except BlockingIOError:
            waiting.set()
            raise

    monkeypatch.setattr(ks.fcntl, "flock", observed_flock)
    with ThreadPoolExecutor() as pool, ks._writer_lock(str(kb)):
        rebuild = pool.submit(ks.reindex, should_cancel=cancel.is_set)
        assert waiting.wait(10)
        cancel.set()
        with pytest.raises(ks.ReindexCancelled):
            rebuild.result(timeout=10)
    assert (kb / ks.INDEX_FILE).read_bytes() == before


def test_library_save_finishes_before_reindex_reads(kb, monkeypatch):
    writing, resume, waiting = threading.Event(), threading.Event(), threading.Event()
    real_dump, real_flock = ks.json.dump, ks.fcntl.flock

    def gated_dump(value, file, **kwargs):
        result = real_dump(value, file, **kwargs)
        if file.name.endswith("paragraphs.json"):
            writing.set()
            assert resume.wait(10)
        return result

    def observed_flock(fd, operation):
        try:
            return real_flock(fd, operation)
        except BlockingIOError:
            waiting.set()
            raise

    monkeypatch.setattr(ks.json, "dump", gated_dump)
    monkeypatch.setattr(ks.fcntl, "flock", observed_flock)
    with ThreadPoolExecutor() as pool:
        save = pool.submit(ks.save_to_library, {"pmid": "3001"},
                           [{"id": 1, "sec": "", "text": "new paper"}], [], "")
        try:
            assert writing.wait(10)
            rebuild = pool.submit(ks.reindex)
            assert waiting.wait(10)
        finally:
            resume.set()
        save.result(timeout=10)
        rebuild.result(timeout=20)
    assert _pmids(kb) == {"39133485", "20000001", "3001"}


def test_cancel_during_last_encode_cannot_publish_when_thread_resumes(kb, monkeypatch):
    before = (kb / ks.INDEX_FILE).read_bytes()
    shutil.rmtree(Path(ks.LIB_DIR) / "20000001")
    encoding, resume, cancel = threading.Event(), threading.Event(), threading.Event()
    real_encode = ks.Embedder.encode

    def gated_encode(self, texts):
        encoding.set()
        assert resume.wait(10)
        return real_encode(self, texts)

    monkeypatch.setattr(ks.Embedder, "encode", gated_encode)
    with ThreadPoolExecutor() as pool:
        rebuild = pool.submit(ks.reindex, should_cancel=cancel.is_set)
        try:
            assert encoding.wait(10)
            cancel.set()
        finally:
            resume.set()
        with pytest.raises(ks.ReindexCancelled):
            rebuild.result(timeout=20)
    assert (kb / ks.INDEX_FILE).read_bytes() == before
