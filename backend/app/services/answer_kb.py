"""答案入库的持久 outbox：DB 保存游标，arq 只负责唤醒，一次最多一篇。"""

from __future__ import annotations

import asyncio
from contextlib import contextmanager
import fcntl
import logging
from pathlib import Path
import threading

from sqlalchemy import select, update

import ask
from picos_paths import VAR_DIR

from ..config import settings
from ..db import SessionLocal
from ..models import Job, utcnow
from . import events

logger = logging.getLogger("yaoe.worker.answer_kb")
MAX_ATTEMPTS = 3


@contextmanager
def _lease():
    """共享 POSIX 卷上的进程租约：线程超时不释放，进程退出自动释放。

    全局锁保证多个答案也不会同时入库；不删除锁文件，避免 inode 更换绕过锁。
    """
    path = Path(VAR_DIR) / "answer-kb.lock"
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a") as handle:
        try:
            fcntl.flock(handle, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            yield False
            return
        try:
            yield True
        finally:
            fcntl.flock(handle, fcntl.LOCK_UN)


def _foreground_pending(db) -> bool:
    return (
        db.scalar(
            select(Job.id)
            .where(Job.kind != "answer_kb", Job.status.in_(("queued", "running")))
            .limit(1)
        )
        is not None
    )


def _publish(ctx: dict, job_id: str, event: dict) -> None:
    # 事件不可用不应重跑已经提交的索引；终态由现有 SSE 数据库补齐。
    try:
        events.publish(
            ctx["redis_sync"],
            job_id,
            event,
            maxlen=settings.events_maxlen,
            ttl_s=settings.events_ttl_s,
        )
    except Exception:
        logger.exception("background event unavailable for %s", job_id)


def _transition(db, job: Job, **values) -> bool:
    # 状态与游标一起 CAS：取消 API 可以与持锁线程并行，不能被晚提交覆盖。
    changed = db.execute(
        update(Job)
        .where(Job.id == job.id, Job.status == job.status, Job.result == job.result)
        .values(**values)
        .execution_options(synchronize_session=False)
    ).rowcount
    db.commit()
    return changed == 1


def _finish(db, job: Job, status: str, error: dict | None = None) -> bool:
    # 后台任务不查找、不修改 Answer，即便 params 携带 answer_id。
    return _transition(db, job, status=status, error=error, finished_at=utcnow())


def _candidate(ctx: dict) -> tuple[str, int, int] | None:
    with _lease() as acquired:
        if not acquired:
            return None
        with SessionLocal() as db:
            rows = db.scalars(
                select(Job)
                .where(Job.kind == "answer_kb", Job.status.in_(("queued", "running")))
                .order_by(Job.created_at)
            ).all()
            candidate = None
            for job in rows:
                if events.is_cancel_requested(ctx["redis_sync"], job.id):
                    if _finish(db, job, "cancelled"):
                        _publish(ctx, job.id, {"type": "cancelled"})
                    continue
                if candidate is None:
                    state = job.result or {}
                    candidate = (
                        job.id,
                        int(state.get("position", 0)),
                        int(state.get("attempt", 0)),
                    )
            return None if _foreground_pending(db) else candidate


async def dispatch_answer_kb(ctx: dict) -> None:
    """启动及每十秒扫描 DB；入队失败保持原记录，下次扫描重试。"""
    try:
        candidate = await asyncio.to_thread(_candidate, ctx)
        if candidate is None:
            return
        job_id, position, attempt = candidate
        await ctx["redis"].enqueue_job(
            "run_answer_kb_job",
            job_id,
            position,
            _job_id=f"answer-kb:{job_id}:{position}:{attempt}",
        )
    except Exception:
        logger.exception("answer KB outbox dispatch failed; will retry")


def process_answer_kb(
    ctx: dict, job_id: str, position: int, stopped: threading.Event
) -> None:
    """认领、处理、提交都在持锁线程中；重复投递和旧游标无副作用。"""
    with _lease() as acquired:
        if not acquired:
            return
        with SessionLocal() as db:
            job = db.get(Job, job_id)
            if (
                job is None
                or job.kind != "answer_kb"
                or job.status not in ("queued", "running")
            ):
                return
            state = dict(job.result or {})
            if int(state.get("position", 0)) != position:
                return
            if events.is_cancel_requested(ctx["redis_sync"], job_id):
                if _finish(db, job, "cancelled"):
                    _publish(ctx, job_id, {"type": "cancelled"})
                return
            if position >= int(state.get("paper_count", 0)):
                if _finish(db, job, "succeeded"):
                    _publish(
                        ctx,
                        job_id,
                        {
                            "type": "succeeded",
                            "items": state.get("items", 0),
                            "papers": state.get("paper_count", 0),
                        },
                    )
                return
            if stopped.is_set() or _foreground_pending(db):
                return
            attempt = int(state.get("attempt", 0)) + 1
            if attempt > MAX_ATTEMPTS:
                error = {
                    "code": "internal_error",
                    "message": "background indexing retry limit reached",
                }
                if _finish(db, job, "failed", error):
                    _publish(ctx, job_id, {"type": "failed", **error})
                return
            state["attempt"] = attempt
            snapshot_path = job.params["snapshot_path"]
            if not _transition(
                db,
                job,
                result=state,
                status="running",
                started_at=job.started_at or utcnow(),
                error=None,
            ):
                return

        def should_cancel() -> bool:
            if stopped.is_set() or events.is_cancel_requested(
                ctx["redis_sync"], job_id
            ):
                return True
            with SessionLocal() as db:
                row = db.get(Job, job_id)
                return row is None or row.status == "cancelled"

        def emit(event: dict) -> None:
            _publish(ctx, job_id, event)

        try:
            if should_cancel():
                raise ask.PipelineCancelled("background indexing cancelled")
            outcome = ask.index_kb_snapshot(
                snapshot_path, position=position, emit=emit, should_cancel=should_cancel
            )
        except Exception as exc:
            cancelled = isinstance(exc, ask.PipelineCancelled) and not stopped.is_set()
            error = {
                "code": "timeout"
                if stopped.is_set()
                else getattr(exc, "code", "internal_error"),
                "message": f"{type(exc).__name__}: {exc}",
            }
            with SessionLocal() as db:
                job = db.get(Job, job_id)
                if not _owns(job, position, attempt):
                    return
                if cancelled or attempt >= MAX_ATTEMPTS:
                    status = "cancelled" if cancelled else "failed"
                    if not _finish(db, job, status, None if cancelled else error):
                        return
                else:
                    status = "queued"
                    if not _transition(db, job, status=status, error=error):
                        return
            if status != "queued":
                _publish(ctx, job_id, {"type": status, **({} if cancelled else error)})
            return

        with SessionLocal() as db:
            job = db.get(Job, job_id)
            if not _owns(job, position, attempt):
                return
            result = {
                "position": outcome["next_position"],
                "paper_count": outcome["paper_count"],
                "items": int(state.get("items", 0)) + outcome["items"],
                "attempt": 0,
            }
            done = result["position"] >= result["paper_count"]
            if not _transition(
                db,
                job,
                result=result,
                error=None,
                progress={
                    "stage": "kb",
                    "current": result["position"],
                    "total": result["paper_count"],
                },
                status="succeeded" if done else "queued",
                finished_at=utcnow() if done else None,
            ):
                return
        if result["position"] >= result["paper_count"]:
            _publish(
                ctx,
                job_id,
                {
                    "type": "succeeded",
                    "items": result["items"],
                    "papers": result["paper_count"],
                },
            )


def _owns(job: Job | None, position: int, attempt: int) -> bool:
    # 防止旧线程晚提交覆盖取消/终态；游标与已持久化的尝试号共同作为 fencing token。
    return (
        job is not None
        and job.status == "running"
        and (job.result or {}).get("position", 0) == position
        and (job.result or {}).get("attempt") == attempt
    )
