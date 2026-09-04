"""backend 测试的公共替身：TestClient、arq stub、worker ctx。"""
from __future__ import annotations

import datetime as dt
from typing import Any

import pytest
import redis
import redis.asyncio as aioredis
from fastapi.testclient import TestClient
from sqlalchemy import delete

from app.config import settings
from app.db import SessionLocal
from app.deps import get_arq
from app.main import create_app
from app.models import Answer, Job

READ_KEY = "test_read_key"
WRITE_KEY = "test_write_key"
ADMIN_KEY = "test_admin_key"


def auth(key: str) -> dict[str, str]:
    return {"Authorization": f"Bearer {key}"}


class ArqStub:
    """记录 enqueue_job 调用，不真的把任务交给 worker。"""

    def __init__(self) -> None:
        self.calls: list[tuple[str, tuple[Any, ...], dict[str, Any]]] = []

    async def enqueue_job(self, fn_name: str, *args: Any, **kwargs: Any) -> None:
        self.calls.append((fn_name, args, kwargs))

    async def aclose(self) -> None:
        pass


@pytest.fixture(autouse=True)
def clean_db():
    """每个测试自带干净的 jobs/answers，避免「活跃任务数」等断言互相污染。"""
    with SessionLocal() as db:
        db.execute(delete(Answer))
        db.execute(delete(Job))
        db.commit()
    yield
    with SessionLocal() as db:
        db.execute(delete(Answer))
        db.execute(delete(Job))
        db.commit()


@pytest.fixture
def sync_redis():
    client = redis.Redis.from_url(settings.redis_url)
    client.flushdb()
    yield client
    client.flushdb()
    client.close()


@pytest.fixture
def arq() -> ArqStub:
    return ArqStub()


@pytest.fixture
def client(arq: ArqStub, sync_redis):
    app = create_app()
    app.dependency_overrides[get_arq] = lambda: arq
    with TestClient(app) as c:
        yield c
    app.dependency_overrides.clear()


@pytest.fixture
def worker_ctx(sync_redis):
    ctx = {"redis_sync": sync_redis, "redis_async": aioredis.from_url(settings.redis_url)}
    yield ctx


def make_job(*, kind: str = "ask", status: str = "queued", api_key_id: str = "writer",
             params: dict | None = None, answer: bool = True) -> tuple[str, str | None]:
    """直接建库里的 job(+answer) 行，绕过 HTTP，便于单测 worker。"""
    job_id = f"job-{dt.datetime.now(dt.timezone.utc).timestamp():.6f}".replace(".", "")
    answer_id = f"ans-{job_id}" if answer else None
    with SessionLocal() as db:
        db.add(Job(id=job_id, kind=kind, status=status, api_key_id=api_key_id,
                   params={**(params or {}), **({"answer_id": answer_id} if answer_id else {})}))
        db.flush()      # answers.job_id 有外键，必须先落 job 行
        if answer_id:
            db.add(Answer(id=answer_id, job_id=job_id, api_key_id=api_key_id, status="queued",
                          question="测试问题", queries=[],
                          options={"question": "测试问题", "papers": 1, "use_kb": False},
                          papers=[], citations=[], kb_hits=[]))
        db.commit()
    return job_id, answer_id
