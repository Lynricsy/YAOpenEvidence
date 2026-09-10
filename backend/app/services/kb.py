"""进程内共享的知识库访问服务。"""
from __future__ import annotations

import os
import threading

from knowledge_store import INDEX_FILE, EmbedderMismatch, KnowledgeStore
from picos_paths import KB_DIR
from starlette.concurrency import run_in_threadpool

from ..errors import ApiError

# 后端错配是配置问题、不是未知故障：全局兜底会把它变成 500 internal_error，那既
# 分类错了、又只留在日志里。检索在这种状态下无法给出可比的结果，所以报 503。
# detail 不透传异常原文——那里带着索引的绝对路径。
_MISMATCH_DETAIL = ("知识库索引与本进程的向量后端不一致：所有 API / worker 必须使用同一个 "
                    "EMBED_BACKEND 与 EMBED_MODEL，切换后需重建整库（POST /kb/reindex）。")


class KbService:
    """共享 KnowledgeStore，避免为每次请求重复加载昂贵的 Embedder。

    worker 一次 rename 换代，按 inode、mtime_ns、size 感知新索引。
    原实例只交换快照引用，活动检索继续持有旧代，Embedder 始终复用。
    旧三文件布局退回观察 meta.jsonl。
    """

    def __init__(self) -> None:
        self._store: KnowledgeStore | None = None
        self._mtime: tuple[int, int, int] | None = None
        self._lock = threading.Lock()

    @staticmethod
    def _index_mtime() -> tuple[int, int, int]:
        for name in (INDEX_FILE, "meta.jsonl"):
            try:
                stat = os.stat(os.path.join(KB_DIR, name))
                return stat.st_ino, stat.st_mtime_ns, stat.st_size
            except FileNotFoundError:
                continue
        return 0, 0, 0

    def get_store(self) -> KnowledgeStore:
        with self._lock:
            mtime = self._index_mtime()
            if self._store is None:
                self._store = KnowledgeStore()
                self._mtime = mtime
            elif mtime != self._mtime:
                self._store._load()
                self._mtime = mtime
            return self._store

    async def search(self, q: str, kind: str = "", top_k: int = 8,
                     pmids: set[str] | None = None) -> list[dict]:
        store = self.get_store()
        try:
            return await run_in_threadpool(store.search, q, top_k, kind, pmids)
        except EmbedderMismatch as exc:
            raise ApiError(503, "unavailable", _MISMATCH_DETAIL) from exc

    def stats(self) -> dict:
        return self.get_store().stats()
