"""任务状态查询、取消与 SSE 进度流。

进度用 SSE 而不是轮询：一条问答任务会产生几十条阶段/逐篇事件，轮询既慢又
浪费。事件存在 Redis Stream 里，`id:` 就是 entry id，客户端重连带
`Last-Event-ID` 即可续传；流过期（7 天）后只能从 DB 合成一条终态事件。
"""
from __future__ import annotations

import json

from fastapi import APIRouter, Depends, Query, Request, Response
from sqlalchemy import func, select
from sqlalchemy.orm import Session
from sse_starlette.sse import EventSourceResponse
from starlette.concurrency import run_in_threadpool

from ..auth import Principal, require
from ..deps import get_db, get_redis
from ..errors import ApiError
from ..models import Job as JobRow
from ..schemas.common import Page
from ..schemas.jobs import TERMINAL_JOB_STATUSES, Job, JobKind, JobStatus
from ..services import events
from ..services import jobs as jobs_service

router = APIRouter(tags=["jobs"])

HEARTBEAT_S = 15


def _visible(db: Session, job_id: str, principal: Principal) -> JobRow:
    """别人的任务一律当不存在：404 比 403 更少泄露信息（连是否存在都不透露）。"""
    row = db.get(JobRow, job_id)
    if row is None or not (principal.is_admin or row.api_key_id == principal.key_id):
        raise ApiError(404, "not_found", f"job {job_id!r} not found")
    return row


@router.get("/jobs", response_model=Page[Job], summary="任务列表")
def list_jobs(kind: JobKind | None = None, status: JobStatus | None = None,
              limit: int = Query(20, ge=1, le=100), offset: int = Query(0, ge=0),
              db: Session = Depends(get_db),
              principal: Principal = Depends(require("read"))) -> Page[Job]:
    conds = []
    if not principal.is_admin:
        conds.append(JobRow.api_key_id == principal.key_id)
    if kind:
        conds.append(JobRow.kind == kind)
    if status:
        conds.append(JobRow.status == status)
    total = int(db.scalar(select(func.count(JobRow.id)).where(*conds)) or 0)
    rows = db.scalars(select(JobRow).where(*conds)
                      .order_by(JobRow.created_at.desc(), JobRow.id.desc())
                      .limit(limit).offset(offset)).all()
    return Page[Job](items=[Job.model_validate(r) for r in rows], total=total,
                     limit=limit, offset=offset)


@router.get("/jobs/{job_id}", response_model=Job, summary="任务详情")
def get_job(job_id: str, db: Session = Depends(get_db),
            principal: Principal = Depends(require("read"))) -> Job:
    return Job.model_validate(_visible(db, job_id, principal))


@router.delete("/jobs/{job_id}", status_code=204, summary="取消任务")
async def cancel_job(job_id: str, db: Session = Depends(get_db), redis=Depends(get_redis),  # noqa: ANN001
                     principal: Principal = Depends(require("write"))) -> Response:
    job = _visible(db, job_id, principal)
    await jobs_service.cancel(job, redis, principal)
    return Response(status_code=204)


def _terminal_payload(job: JobRow) -> dict:
    if job.status == "succeeded":
        return job.result or {}
    if job.status == "failed":
        return job.error or {"code": "internal_error", "message": "job failed"}
    return {}


@router.get("/jobs/{job_id}/events", summary="任务进度流（SSE）",
            response_class=EventSourceResponse,
            responses={200: {"content": {"text/event-stream": {}}},
                       404: {"description": "job not found"}})
async def job_events(job_id: str, request: Request, db: Session = Depends(get_db),
                     redis=Depends(get_redis),  # noqa: ANN001
                     principal: Principal = Depends(require("read", allow_query=True))):
    # 依赖的 session 会活到 SSE 结束，必须先归还连接；轮询另用短事务。
    bind = db.get_bind()
    await run_in_threadpool(_visible, db, job_id, principal)
    await run_in_threadpool(db.close)

    def terminal_snapshot():
        with Session(bind=bind) as snapshot:
            job = _visible(snapshot, job_id, principal)
            if job.status in TERMINAL_JOB_STATUSES:
                return job.status, _terminal_payload(job)
        return None

    async def terminal():
        return await run_in_threadpool(terminal_snapshot)

    last_id = request.headers.get("last-event-id") or "0-0"

    async def stream():
        async for entry_id, kind, data in events.subscribe(redis, job_id, last_id, terminal=terminal):
            if await request.is_disconnected():
                return
            yield {"id": entry_id, "event": kind, "data": json.dumps(data, ensure_ascii=False)}

    return EventSourceResponse(stream(), ping=HEARTBEAT_S)
