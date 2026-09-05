"""backend 测试的公共替身：TestClient、arq stub、worker ctx。"""
from __future__ import annotations

import datetime as dt
import hashlib
from functools import lru_cache
from typing import Any

import pytest
from argon2 import PasswordHasher
import redis
import redis.asyncio as aioredis
from fastapi.testclient import TestClient
from sqlalchemy import delete

from app.config import settings
from app.db import SessionLocal
from app.deps import get_arq
from app.main import create_app
from app.models import Answer, Job, User, UserSession

USER_TOKEN = "test_user_session"
OTHER_TOKEN = "test_other_session"
ADMIN_TOKEN = "test_admin_session"
PASSWORD = "Testing-user-pass!1"


def auth(token: str) -> dict[str, str]:
    return {"Authorization": f"Bearer {token}"}


class ArqStub:
    """记录 enqueue_job 调用，不真的把任务交给 worker。"""

    def __init__(self) -> None:
        self.calls: list[tuple[str, tuple[Any, ...], dict[str, Any]]] = []

    async def enqueue_job(self, fn_name: str, *args: Any, **kwargs: Any) -> None:
        self.calls.append((fn_name, args, kwargs))

    async def aclose(self) -> None:
        pass


@lru_cache(maxsize=1)
def _password_hash() -> str:
    return PasswordHasher().hash(PASSWORD)


def _clear_db(db) -> None:
    for model in (Answer, Job, UserSession, User):
        db.execute(delete(model))
    db.commit()


@pytest.fixture(autouse=True)
def clean_db():
    """每个测试独立持有真实用户与会话，业务外键与认证检查均不绕过。"""
    with SessionLocal() as db:
        _clear_db(db)
        now = dt.datetime.now(dt.timezone.utc)
        identities = (("reader", USER_TOKEN), ("writer", OTHER_TOKEN), ("admin", ADMIN_TOKEN))
        for user_id, _ in identities:
            db.add(User(id=user_id, username=user_id, password_hash=_password_hash(),
                        role="admin" if user_id == "admin" else "user", is_active=True,
                        auth_version=0, created_at=now))
        db.flush()
        for user_id, token in identities:
            db.add(UserSession(token_hash=hashlib.sha256(token.encode()).hexdigest(),
                               user_id=user_id, auth_version=0, created_at=now,
                               expires_at=now + dt.timedelta(days=1)))
        db.commit()
    yield
    with SessionLocal() as db:
        _clear_db(db)


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


def make_job(*, kind: str = "ask", status: str = "queued", user_id: str | None = "writer",
             params: dict | None = None, answer: bool = True) -> tuple[str, str | None]:
    """直接建库里的 job(+answer) 行，绕过 HTTP，便于单测 worker。"""
    job_id = f"job-{dt.datetime.now(dt.timezone.utc).timestamp():.6f}".replace(".", "")
    answer_id = f"ans-{job_id}" if answer else None
    with SessionLocal() as db:
        if user_id is not None and db.get(User, user_id) is None:
            db.add(User(id=user_id, username=user_id, password_hash=_password_hash(),
                        role="user", is_active=True, auth_version=0))
            db.flush()
        db.add(Job(id=job_id, kind=kind, status=status, user_id=user_id,
                   params={**(params or {}), **({"answer_id": answer_id} if answer_id else {})}))
        db.flush()      # answers.job_id 有外键，必须先落 job 行
        if answer_id:
            db.add(Answer(id=answer_id, job_id=job_id, user_id=user_id, status="queued",
                          question="测试问题", queries=[],
                          options={"question": "测试问题", "papers": 1, "use_kb": False},
                          papers=[], citations=[], kb_hits=[]))
        db.commit()
    return job_id, answer_id
