"""同步 SQLAlchemy engine/session。

刻意用同步驱动：worker 在线程里跑 core 的同步流水线，API 侧的 DB 路由用
`def`（FastAPI 自动丢线程池），两边共用同一套 model 与 session 语义，不必
为了 async 再养一套。SQLite 开 WAL + busy_timeout，让 api 与 worker 能并发。
"""
from __future__ import annotations

import os
from collections.abc import Iterator

from sqlalchemy import create_engine, event
from sqlalchemy.engine import Engine
from sqlalchemy.orm import Session, sessionmaker

from .config import settings


def _make_engine() -> Engine:
    if settings.is_sqlite:
        path = settings.database_url.split("///", 1)[-1]
        if path and path != ":memory:":
            os.makedirs(os.path.dirname(os.path.abspath(path)), exist_ok=True)
        eng = create_engine(settings.database_url, connect_args={"check_same_thread": False},
                            future=True)

        @event.listens_for(eng, "connect")
        def _sqlite_pragmas(dbapi_conn, _rec) -> None:  # noqa: ANN001
            cur = dbapi_conn.cursor()
            cur.execute("PRAGMA journal_mode=WAL")
            cur.execute("PRAGMA busy_timeout=5000")
            cur.execute("PRAGMA foreign_keys=ON")
            cur.close()

        return eng
    return create_engine(settings.database_url, pool_pre_ping=True, future=True)


engine = _make_engine()
SessionLocal = sessionmaker(engine, expire_on_commit=False, class_=Session)


def get_db() -> Iterator[Session]:
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
