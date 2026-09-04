"""进程内共享的知识库访问服务。"""
from __future__ import annotations

import os
import threading

from knowledge_store import INDEX_FILE, KnowledgeStore
from picos_paths import KB_DIR
from starlette.concurrency import run_in_threadpool


class KbService:
    """共享 KnowledgeStore，避免为每次请求重复加载昂贵的 Embedder。

    worker 会用一次 rename 换掉整份索引（kb/index.npz），因此按该文件的 mtime
    感知新索引，并在原实例上重载，保留已经加载的 Embedder。旧的三文件布局
    仍受支持，此时退回看 meta.jsonl。
    """

    def __init__(self) -> None:
        self._store: KnowledgeStore | None = None
        self._mtime: float | None = None
        self._lock = threading.Lock()

    @staticmethod
    def _index_mtime() -> float:
        for name in (INDEX_FILE, "meta.jsonl"):
            try:
                return os.path.getmtime(os.path.join(KB_DIR, name))
            except FileNotFoundError:
                continue
        return 0.0

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
        return await run_in_threadpool(store.search, q, top_k, kind, pmids)

    def stats(self) -> dict:
        return self.get_store().stats()
