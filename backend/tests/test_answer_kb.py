"""后台入库 outbox、每篇让路与答案状态隔离。"""

from __future__ import annotations

import asyncio
import json
import threading
from unittest.mock import AsyncMock

import pytest

import ask
from app.db import SessionLocal
from app.models import Answer, Job
from app.services import answer_kb, jobs
from app.worker import _terminate, dispatch_answer_kb, run_answer_kb_job, run_ask_job

from .conftest import ArqStub, OTHER_TOKEN, auth, make_job
from .test_worker import _result


@pytest.fixture(autouse=True)
def isolated_lease(monkeypatch, tmp_path):
    monkeypatch.setattr(answer_kb, "VAR_DIR", str(tmp_path / "var"))


async def _ready(worker_ctx, monkeypatch, tmp_path, *, count=2):
    job_id, answer_id = make_job()
    (tmp_path / "papers").mkdir()
    result = _result(answer_id, str(tmp_path / "papers"))
    result.papers = [{**result.papers[0], "n": n} for n in range(1, count + 1)]

    def run(opts, **kwargs):
        assert kwargs["defer_kb"] is True
        return result

    with SessionLocal() as db:
        answer = db.get(Answer, answer_id)
        answer.options = {**answer.options, "use_kb": True}
        db.commit()

    monkeypatch.setattr(ask, "run_ask", run)
    await run_ask_job(worker_ctx, job_id)
    with SessionLocal() as db:
        kb_id = db.get(Job, job_id).result["kb_job_id"]
    return job_id, answer_id, kb_id


async def test_ready_answer_and_full_snapshot_precede_background(
    worker_ctx, monkeypatch, tmp_path
):
    parent, answer_id, kb_id = await _ready(worker_ctx, monkeypatch, tmp_path)
    with SessionLocal() as db:
        assert db.get(Answer, answer_id).status == "ready"
        assert db.get(Job, parent).status == "succeeded"
        job = db.get(Job, kb_id)
        assert job.status == "queued"
        with open(job.params["snapshot_path"]) as handle:
            snapshot = json.load(handle)
        assert [paper["n"] for paper in snapshot["papers"]] == [1, 2]
        assert db.get(Answer, answer_id).n_papers == 1
        assert jobs.active_job_count(db, "writer") == 0


async def test_dispatch_recovers_enqueue_failure_and_keeps_ready(
    worker_ctx, monkeypatch, tmp_path
):
    _, answer_id, kb_id = await _ready(worker_ctx, monkeypatch, tmp_path)
    failed = AsyncMock(side_effect=ConnectionError("redis unavailable"))
    arq = ArqStub()
    worker_ctx["redis"] = arq
    monkeypatch.setattr(arq, "enqueue_job", failed)
    await dispatch_answer_kb(worker_ctx)
    with SessionLocal() as db:
        assert db.get(Job, kb_id).status == "queued"
        assert db.get(Answer, answer_id).status == "ready"
    recovered = ArqStub()
    worker_ctx["redis"] = recovered
    await dispatch_answer_kb(worker_ctx)
    assert recovered.calls[0][1] == (kb_id, 0)


async def test_one_paper_then_frontend_priority_and_stale_delivery(
    worker_ctx, monkeypatch, tmp_path
):
    _, _, kb_id = await _ready(worker_ctx, monkeypatch, tmp_path)
    positions = []

    def index(path, *, position, **kwargs):
        positions.append(position)
        return {"paper_count": 2, "next_position": position + 1, "items": 4}

    monkeypatch.setattr(ask, "index_kb_snapshot", index)
    await run_answer_kb_job(worker_ctx, kb_id, 0)
    foreground, _ = make_job()
    arq = ArqStub()
    worker_ctx["redis"] = arq
    await dispatch_answer_kb(worker_ctx)
    await run_answer_kb_job(worker_ctx, kb_id, 1)
    assert positions == [0]
    assert arq.calls == []
    with SessionLocal() as db:
        assert db.get(Job, kb_id).status == "queued"
        db.get(Job, foreground).status = "succeeded"
        db.commit()
    await run_answer_kb_job(worker_ctx, kb_id, 0)
    assert positions == [0]
    await run_answer_kb_job(worker_ctx, kb_id, 1)
    await run_answer_kb_job(worker_ctx, kb_id, 1)
    assert positions == [0, 1]
    with SessionLocal() as db:
        job = db.get(Job, kb_id)
        assert job.status == "succeeded"
        assert job.result["items"] == 8
        assert job.result["position"] == 2


async def test_restart_recovers_running_cursor(worker_ctx, monkeypatch, tmp_path):
    _, _, kb_id = await _ready(worker_ctx, monkeypatch, tmp_path)
    with SessionLocal() as db:
        job = db.get(Job, kb_id)
        job.status = "running"
        job.result = {"position": 1, "paper_count": 2, "items": 4, "attempt": 1}
        db.commit()
    arq = ArqStub()
    worker_ctx["redis"] = arq
    await dispatch_answer_kb(worker_ctx)
    assert arq.calls[0][1] == (kb_id, 1)
    monkeypatch.setattr(
        ask,
        "index_kb_snapshot",
        lambda path, **kw: {
            "paper_count": 2,
            "next_position": kw["position"] + 1,
            "items": 5,
        },
    )
    await run_answer_kb_job(worker_ctx, kb_id, 1)
    with SessionLocal() as db:
        assert db.get(Job, kb_id).status == "succeeded"
        assert db.get(Job, kb_id).result["items"] == 9


async def test_cancelled_await_keeps_thread_lease_against_duplicate(
    worker_ctx, monkeypatch, tmp_path
):
    _, _, kb_id = await _ready(worker_ctx, monkeypatch, tmp_path)
    entered, release, finished = threading.Event(), threading.Event(), threading.Event()
    calls = []

    def index(path, **kwargs):
        calls.append(kwargs["position"])
        entered.set()
        assert release.wait(5)
        return {"paper_count": 2, "next_position": 1, "items": 3}

    original = answer_kb.process_answer_kb

    def tracked(*args):
        try:
            return original(*args)
        finally:
            finished.set()

    monkeypatch.setattr(ask, "index_kb_snapshot", index)
    monkeypatch.setattr("app.worker.process_answer_kb", tracked)
    task = asyncio.create_task(run_answer_kb_job(worker_ctx, kb_id, 0))
    try:
        assert await asyncio.to_thread(entered.wait, 5)
        task.cancel()
        with pytest.raises(asyncio.CancelledError):
            await task
        # 绕过包装器观测第二次 delivery，不让其完成信号代替原线程的信号。
        await asyncio.to_thread(original, worker_ctx, kb_id, 0, threading.Event())
        assert calls == [0]
        with SessionLocal() as db:
            assert db.get(Job, kb_id).status == "running"
    finally:
        release.set()
        assert await asyncio.to_thread(finished.wait, 5)
    with SessionLocal() as db:
        assert db.get(Job, kb_id).result["position"] == 1


async def test_bounded_failure_does_not_pollute_answer(
    worker_ctx, monkeypatch, tmp_path
):
    parent, answer_id, kb_id = await _ready(worker_ctx, monkeypatch, tmp_path)
    calls = []

    def fail(path, **kwargs):
        calls.append(kwargs["position"])
        raise RuntimeError("index unavailable")

    monkeypatch.setattr(ask, "index_kb_snapshot", fail)
    for _ in range(answer_kb.MAX_ATTEMPTS + 1):
        await run_answer_kb_job(worker_ctx, kb_id, 0)
    assert calls == [0] * answer_kb.MAX_ATTEMPTS
    with SessionLocal() as db:
        assert db.get(Job, kb_id).status == "failed"
        assert db.get(Job, kb_id).error["message"] == "RuntimeError: index unavailable"
        assert db.get(Job, parent).status == "succeeded"
        answer = db.get(Answer, answer_id)
        assert answer.status == "ready" and answer.error is None
        assert answer.body_md == "结论 [1¶1]"
    _terminate(worker_ctx, kb_id, "cancelled")
    with SessionLocal() as db:
        assert db.get(Answer, answer_id).status == "ready"


async def test_background_cancel_api_is_durable_and_independent(
    client, worker_ctx, monkeypatch, tmp_path, sync_redis
):
    _, answer_id, kb_id = await _ready(worker_ctx, monkeypatch, tmp_path)
    response = client.post(f"/v1/jobs/{kb_id}/cancel", headers=auth(OTHER_TOKEN))
    assert response.status_code == 202
    sync_redis.flushdb()
    await run_answer_kb_job(worker_ctx, kb_id, 0)
    response = client.get(f"/v1/jobs/{kb_id}", headers=auth(OTHER_TOKEN))
    assert response.json()["kind"] == "answer_kb"
    assert response.json()["status"] == "cancelled"
    with SessionLocal() as db:
        assert db.get(Answer, answer_id).status == "ready"


async def test_empty_batch_completes_without_index_call(
    worker_ctx, monkeypatch, tmp_path
):
    _, _, kb_id = await _ready(worker_ctx, monkeypatch, tmp_path, count=0)

    def never(*args, **kwargs):
        pytest.fail("empty snapshot must not call single-paper indexer")

    monkeypatch.setattr(ask, "index_kb_snapshot", never)
    await run_answer_kb_job(worker_ctx, kb_id, 0)
    with SessionLocal() as db:
        assert db.get(Job, kb_id).status == "succeeded"
        assert db.get(Job, kb_id).result["items"] == 0


async def test_repeated_dispatch_uses_arq_deduplication(
    worker_ctx, monkeypatch, tmp_path
):
    from arq import create_pool
    from arq.connections import RedisSettings
    from arq.constants import default_queue_name
    from app.config import settings

    await _ready(worker_ctx, monkeypatch, tmp_path)
    pool = await create_pool(RedisSettings.from_dsn(settings.redis_url))
    worker_ctx["redis"] = pool
    try:
        await dispatch_answer_kb(worker_ctx)
        await dispatch_answer_kb(worker_ctx)
        assert await pool.zcard(default_queue_name) == 1
    finally:
        await pool.aclose()


async def test_cancelled_row_cannot_be_overwritten_by_late_thread(
    client, worker_ctx, monkeypatch, tmp_path
):
    _, answer_id, kb_id = await _ready(worker_ctx, monkeypatch, tmp_path)
    entered, release = threading.Event(), threading.Event()

    def index(path, **kwargs):
        entered.set()
        assert release.wait(5)
        return {"paper_count": 2, "next_position": 1, "items": 3}

    monkeypatch.setattr(ask, "index_kb_snapshot", index)
    task = asyncio.create_task(run_answer_kb_job(worker_ctx, kb_id, 0))
    try:
        assert await asyncio.to_thread(entered.wait, 5)
        response = client.post(f"/v1/jobs/{kb_id}/cancel", headers=auth(OTHER_TOKEN))
        assert response.status_code == 202
    finally:
        release.set()
        await task
    with SessionLocal() as db:
        assert db.get(Job, kb_id).status == "cancelled"
        assert db.get(Job, kb_id).result["position"] == 0
        assert db.get(Answer, answer_id).status == "ready"


async def test_kb_disabled_does_not_snapshot_or_create_background(
    worker_ctx, monkeypatch, tmp_path
):
    parent, answer_id = make_job()
    monkeypatch.setattr(
        ask, "run_ask", lambda opts, **kw: _result(answer_id, str(tmp_path))
    )

    def never(*args, **kwargs):
        pytest.fail("use_kb=False must not write a background snapshot")

    monkeypatch.setattr(ask, "save_kb_snapshot", never)
    await run_ask_job(worker_ctx, parent)
    with SessionLocal() as db:
        from sqlalchemy import select

        assert db.get(Job, parent).result == {"answer_id": answer_id}
        assert db.get(Answer, answer_id).status == "ready"
        assert db.scalar(select(Job.id).where(Job.kind == "answer_kb")) is None


async def test_background_terminal_event_and_database_fallback_match(
    worker_ctx, sync_redis, monkeypatch, tmp_path
):
    from app.routers.jobs import _terminal_payload
    from .test_worker import _stream

    _, _, kb_id = await _ready(worker_ctx, monkeypatch, tmp_path, count=1)
    monkeypatch.setattr(
        ask,
        "index_kb_snapshot",
        lambda path, **kw: {"paper_count": 1, "next_position": 1, "items": 5},
    )
    await run_answer_kb_job(worker_ctx, kb_id, 0)
    assert _stream(sync_redis, kb_id)[-1] == ("succeeded", {"items": 5, "papers": 1})
    with SessionLocal() as db:
        assert _terminal_payload(db.get(Job, kb_id)) == {"items": 5, "papers": 1}
