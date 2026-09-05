"""SSE 进度流：回放、Last-Event-ID 续传、流过期后的合成终态。"""
from __future__ import annotations

import json
import asyncio
from contextlib import AsyncExitStack, asynccontextmanager

import httpx
import redis.asyncio as aioredis
from sqlalchemy import create_engine
from sqlalchemy.orm import Session

from app.auth import load_api_keys
from app.deps import get_db
from app.main import create_app
from app.models import Base

from app.config import settings
from app.db import SessionLocal
from app.models import Job
from app.services import events

from .conftest import READ_KEY, WRITE_KEY, auth, make_job

PUB = {"maxlen": settings.events_maxlen, "ttl_s": settings.events_ttl_s}


def parse_sse(text: str) -> list[dict]:
    """把原始 SSE 文本拆成 [{id, event, data}]，忽略心跳注释行。"""
    out, cur = [], {}
    for line in text.splitlines():
        if not line.strip():
            if cur:
                out.append(cur)
                cur = {}
            continue
        if line.startswith(":"):
            continue
        field, _, value = line.partition(":")
        value = value.lstrip()
        if field == "data":
            cur["data"] = json.loads(value)
        elif field in ("id", "event"):
            cur[field] = value
    if cur:
        out.append(cur)
    return out


def test_stream_replays_from_beginning_and_stops_at_terminal(client, sync_redis):
    job_id, answer_id = make_job(api_key_id="reader")
    events.publish(sync_redis, job_id, {"type": "stage", "stage": "search", "status": "started"}, **PUB)
    events.publish(sync_redis, job_id,
                   {"type": "progress", "stage": "read", "current": 1, "total": 2}, **PUB)
    events.publish(sync_redis, job_id, {"type": "succeeded", "answer_id": answer_id}, **PUB)

    r = client.get(f"/v1/jobs/{job_id}/events", headers=auth(READ_KEY))
    assert r.status_code == 200
    assert r.headers["content-type"].startswith("text/event-stream")
    got = parse_sse(r.text)
    assert [e["event"] for e in got] == ["stage", "progress", "succeeded"]
    assert got[1]["data"] == {"stage": "read", "current": 1, "total": 2}
    assert got[2]["data"] == {"answer_id": answer_id}
    assert all(e["id"] for e in got), "每条事件都要带 id，否则无法续传"


def test_last_event_id_resumes_after_that_entry(client, sync_redis):
    job_id, answer_id = make_job(api_key_id="reader")
    first = events.publish(sync_redis, job_id,
                           {"type": "progress", "stage": "read", "current": 1, "total": 2}, **PUB)
    events.publish(sync_redis, job_id,
                   {"type": "progress", "stage": "read", "current": 2, "total": 2}, **PUB)
    events.publish(sync_redis, job_id, {"type": "succeeded", "answer_id": answer_id}, **PUB)

    r = client.get(f"/v1/jobs/{job_id}/events",
                   headers={**auth(READ_KEY), "Last-Event-ID": first})
    got = parse_sse(r.text)
    assert [e["event"] for e in got] == ["progress", "succeeded"]
    assert got[0]["data"]["current"] == 2


def test_expired_stream_synthesises_terminal_event(client, sync_redis):
    job_id, answer_id = make_job(api_key_id="reader", status="succeeded")
    with SessionLocal() as db:
        job = db.get(Job, job_id)
        job.result = {"answer_id": answer_id}
        db.commit()
    assert not sync_redis.exists(events.stream_key(job_id))

    got = parse_sse(client.get(f"/v1/jobs/{job_id}/events", headers=auth(READ_KEY)).text)
    assert len(got) == 1
    assert got[0]["event"] == "succeeded"
    assert got[0]["id"] == "0-0"
    assert got[0]["data"] == {"answer_id": answer_id}


def test_expired_stream_of_failed_job_reports_error_code(client, sync_redis):
    job_id, _ = make_job(api_key_id="reader", status="failed")
    with SessionLocal() as db:
        db.get(Job, job_id).error = {"code": "no_papers", "message": "nothing found"}
        db.commit()

    got = parse_sse(client.get(f"/v1/jobs/{job_id}/events", headers=auth(READ_KEY)).text)
    assert got[0]["event"] == "failed"
    assert got[0]["data"]["code"] == "no_papers"


def test_other_keys_job_is_invisible(client, sync_redis):
    job_id, _ = make_job(api_key_id="somebody-else")
    assert client.get(f"/v1/jobs/{job_id}", headers=auth(READ_KEY)).status_code == 404
    assert client.get(f"/v1/jobs/{job_id}/events", headers=auth(READ_KEY)).status_code == 404


def test_cancel_sets_flag_and_terminal_job_conflicts(client, sync_redis):
    job_id, _ = make_job(api_key_id="writer")
    assert client.delete(f"/v1/jobs/{job_id}", headers=auth(WRITE_KEY)).status_code == 204
    assert sync_redis.exists(events.cancel_key(job_id))

    done_id, _ = make_job(api_key_id="writer", status="succeeded")
    r = client.delete(f"/v1/jobs/{done_id}", headers=auth(WRITE_KEY))
    assert r.status_code == 409
    assert r.json()["code"] == "conflict"


def test_job_list_scopes_to_own_key_unless_admin(client, sync_redis):
    make_job(api_key_id="writer")
    make_job(api_key_id="reader")

    mine = client.get("/v1/jobs", headers=auth(READ_KEY)).json()
    assert mine["total"] == 1
    assert mine["items"][0]["api_key_id"] == "reader"

    from .conftest import ADMIN_KEY

    assert client.get("/v1/jobs", headers=auth(ADMIN_KEY)).json()["total"] == 2
    assert client.get("/v1/jobs", params={"kind": "kb_reindex"},
                      headers=auth(ADMIN_KEY)).json()["total"] == 0


def streaming_app(redis):
    app = create_app()
    app.state.redis = redis
    app.state.auth_disabled = False
    app.state.principals = load_api_keys(settings.api_keys_file)
    return app


@asynccontextmanager
async def live_sse(app, path, *, headers=None):
    """直接驱动 ASGI 收发，响应持续打开，不用会缓冲完整响应的测试 transport。"""
    incoming, outgoing = asyncio.Queue(), asyncio.Queue()
    await incoming.put({"type": "http.request", "body": b"", "more_body": False})
    scope = {
        "type": "http", "asgi": {"version": "3.0", "spec_version": "2.4"},
        "http_version": "1.1", "method": "GET", "scheme": "http",
        "path": path, "raw_path": path.encode(), "query_string": b"", "root_path": "",
        "headers": [(k.lower().encode(), v.encode())
                    for k, v in (headers or auth(READ_KEY)).items()],
        "client": ("127.0.0.1", 1234), "server": ("test", 80),
    }
    task = asyncio.create_task(app(scope, incoming.get, outgoing.put))
    try:
        start = await asyncio.wait_for(outgoing.get(), 3)
        assert start["type"] == "http.response.start"
        assert start["status"] == 200
        yield outgoing
    finally:
        await incoming.put({"type": "http.disconnect"})
        try:
            await asyncio.wait_for(task, 3)
        finally:
            if not task.done():
                task.cancel()
            await asyncio.gather(task, return_exceptions=True)


async def finish_sse(outgoing):
    chunks = []
    while True:
        message = await asyncio.wait_for(outgoing.get(), 8)
        assert message["type"] == "http.response.body"
        chunks.append(message.get("body", b""))
        if not message.get("more_body", False):
            return parse_sse(b"".join(chunks).decode())


async def test_fifteen_live_streams_leave_database_available(tmp_path, sync_redis):
    # SQLite 文件配默认 QueuePool（5+10），让第十六个普通请求暴露连接泄漏。
    engine = create_engine(f"sqlite:///{tmp_path / 'sse.db'}",
                           connect_args={"check_same_thread": False}, pool_timeout=0.2)
    Base.metadata.create_all(engine)
    redis = aioredis.from_url(settings.redis_url)
    app = streaming_app(redis)

    def db_session():
        with Session(engine) as db:
            yield db

    app.dependency_overrides[get_db] = db_session
    try:
        with Session(engine) as db:
            db.add(Job(id="live", kind="ask", status="running", api_key_id="reader", params={}))
            db.commit()
        first = events.publish(sync_redis, "live", {"type": "stage", "stage": "search"}, **PUB)
        async with AsyncExitStack() as stack:
            for _ in range(15):
                output = await stack.enter_async_context(live_sse(app, "/v1/jobs/live/events"))
                chunk = await asyncio.wait_for(output.get(), 3)
                assert parse_sse(chunk["body"].decode())[0]["id"] == first
            async with httpx.AsyncClient(transport=httpx.ASGITransport(app=app),
                                         base_url="http://test") as client:
                response = await asyncio.wait_for(client.get("/v1/jobs/live", headers=auth(READ_KEY)), 3)
                assert response.status_code == 200
                assert response.json()["status"] == "running"
    finally:
        app.dependency_overrides.clear()
        await redis.aclose()
        engine.dispose()


async def test_live_subscription_converges_when_database_finishes(sync_redis):
    job_id, _ = make_job(api_key_id="reader", status="running")
    first = events.publish(sync_redis, job_id, {"type": "stage", "stage": "search"}, **PUB)
    redis = aioredis.from_url(settings.redis_url)
    try:
        async with live_sse(streaming_app(redis), f"/v1/jobs/{job_id}/events") as output:
            chunk = await asyncio.wait_for(output.get(), 3)
            assert parse_sse(chunk["body"].decode())[0]["id"] == first
            with SessionLocal() as db:
                job = db.get(Job, job_id)
                job.status = "failed"
                job.error = {"code": "no_papers", "message": "nothing found"}
                db.commit()
            got = await finish_sse(output)
            assert [(e["event"], e["data"]) for e in got] == [
                ("failed", {"code": "no_papers", "message": "nothing found"})]
    finally:
        await redis.aclose()


async def test_resume_after_terminal_entry_still_closes(sync_redis):
    job_id, _ = make_job(api_key_id="reader", status="cancelled")
    last = events.publish(sync_redis, job_id, {"type": "cancelled"}, **PUB)
    redis = aioredis.from_url(settings.redis_url)
    try:
        async with live_sse(streaming_app(redis), f"/v1/jobs/{job_id}/events",
                            headers={**auth(READ_KEY), "Last-Event-ID": last}) as output:
            got = await finish_sse(output)
            assert got == [{"id": last, "event": "cancelled", "data": {}}]
    finally:
        await redis.aclose()
