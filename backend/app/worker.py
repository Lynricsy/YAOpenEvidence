"""arq worker：在独立进程里跑 core 的流水线，并把进度推进 Redis 事件流。

流水线是同步且 CPU/IO 混合的（线程池里跑 LLM 请求与解析），所以放
`asyncio.to_thread` 里；因此也无法被 asyncio 取消——取消一律走协作式的
取消标记，worker 只负责把它翻译成 should_cancel。

DB 写入分两类：终态在一个事务里同时落 jobs 与 answers；进度用独立短事务，
免得长跑任务把连接占着（SQLite 尤其怕长事务）。
"""
from __future__ import annotations

import asyncio
import datetime as dt
import logging
import os

from arq import cron
from sqlalchemy import select
from sqlalchemy.orm import Session

import ask
import ingest
import journal_rank as jr
import knowledge_store as ks
from picos_paths import RANK_DIR

from .config import settings
from .db import SessionLocal
from .models import JOB_TO_ANSWER_STATUS, Answer, Job, utcnow
from .services import events
from .services.answers import to_answer_paper, to_ask_options

logger = logging.getLogger("yaoe.worker")


def _publish(ctx: dict, job_id: str, event: dict) -> str:
    return events.publish(ctx["redis_sync"], job_id, event,
                          maxlen=settings.events_maxlen, ttl_s=settings.events_ttl_s)


def _job(db: Session, job_id: str) -> Job | None:
    return db.get(Job, job_id)


def _answer_of(db: Session, job: Job) -> Answer | None:
    answer_id = (job.params or {}).get("answer_id")
    if answer_id:
        return db.get(Answer, answer_id)
    return db.scalars(select(Answer).where(Answer.job_id == job.id)).first()


def _set_status(db: Session, job: Job, answer: Answer | None, status: str, *,
                error: dict | None = None, result: dict | None = None,
                finished: bool = False) -> None:
    job.status = status
    job.error = error
    if result is not None:
        job.result = result
    if finished:
        job.finished_at = utcnow()
    if answer is not None:
        answer.status = JOB_TO_ANSWER_STATUS[status]
        answer.error = error
        if finished:
            answer.finished_at = utcnow()
    db.commit()


def _terminate(ctx: dict, job_id: str, status: str, error: dict | None = None) -> None:
    """先提交数据库终态，再发布事件；发布丢失由 SSE 根据数据库补齐。"""
    with SessionLocal() as db:
        job = _job(db, job_id)
        if job is not None:
            _set_status(db, job, _answer_of(db, job), status, error=error, finished=True)
    _publish(ctx, job_id, {"type": status, **(error or {})})


async def run_ask_job(ctx: dict, job_id: str) -> None:
    # 先在一个短事务里判定「能不能跑」，出了 with 再落终态：_terminate 另开
    # session，两个写事务同时开着会在 SQLite 上互相等锁
    with SessionLocal() as db:
        job = _job(db, job_id)
        if job is None:
            logger.warning("job %s not found in db; dropping", job_id)
            return
        answer = _answer_of(db, job)
        cancelled = events.is_cancel_requested(ctx["redis_sync"], job_id)
        if answer is not None and not cancelled:
            job.started_at = answer.started_at = utcnow()
            _set_status(db, job, answer, "running")
            answer_id, options = answer.id, dict(answer.options or {})
    if answer is None:
        _terminate(ctx, job_id, "failed", {"code": "internal_error", "message": "answer row missing"})
        return
    if cancelled:
        _terminate(ctx, job_id, "cancelled")
        return

    def emit(event: dict) -> None:
        _publish(ctx, job_id, event)
        if event.get("type") in ("stage", "progress"):
            with SessionLocal() as pdb:                     # 独立短事务，不占长连接
                row = pdb.get(Job, job_id)
                if row is not None:
                    row.progress = {"stage": event.get("stage"), "current": event.get("current"),
                                    "total": event.get("total")}
                    pdb.commit()

    def should_cancel() -> bool:
        return events.is_cancel_requested(ctx["redis_sync"], job_id)

    opts = to_ask_options(options)
    try:
        res = await asyncio.to_thread(ask.run_ask, opts, run_id=answer_id, emit=emit,
                                      should_cancel=should_cancel,
                                      paper_urls={n: f"/v1/answers/{answer_id}/papers/{n}/markdown"
                                                  for n in range(1, opts.papers + 1)})
    except ask.PipelineCancelled:
        _terminate(ctx, job_id, "cancelled")
        return
    except ask.PipelineError as e:
        _terminate(ctx, job_id, "failed", {"code": e.code, "message": str(e)})
        return
    except (asyncio.TimeoutError, asyncio.CancelledError):
        # arq 超时：线程还在跑，置取消标记让它在下一个边界自己退出
        await events.request_cancel(ctx["redis_async"], job_id, settings.events_ttl_s)
        _terminate(ctx, job_id, "failed",
                   {"code": "timeout", "message": f"job exceeded {settings.job_timeout_s}s"})
        raise
    except Exception as e:  # noqa: BLE001
        logger.exception("ask job %s failed", job_id)
        _terminate(ctx, job_id, "failed", {"code": "internal_error", "message": f"{type(e).__name__}: {e}"})
        return

    used = set(res.used_n)
    papers = [to_answer_paper(p) for p in res.papers if p.get("n") in used]
    papers.sort(key=lambda p: p["n"])
    with SessionLocal() as db:
        job = _job(db, job_id)
        answer = _answer_of(db, job) if job is not None else None
        if answer is not None:
            answer.question_en = res.question_en
            answer.queries = list(res.queries)
            answer.filters_label = res.filters_label
            answer.n_papers = len(used)
            answer.n_fulltext = res.n_fulltext
            answer.papers = papers
            answer.body_md = res.body_md
            answer.answer_md = res.answer_md
            answer.citations = res.citations
            answer.kb_hits = res.kb_hits
        if job is not None:
            _set_status(db, job, answer, "succeeded", result={"answer_id": answer_id}, finished=True)
    _publish(ctx, job_id, {"type": "succeeded", "answer_id": answer_id})


async def run_kb_reindex_job(ctx: dict, job_id: str) -> None:
    with SessionLocal() as db:
        job = _job(db, job_id)
        if job is None:
            logger.warning("job %s not found in db; dropping", job_id)
            return
        cancelled = events.is_cancel_requested(ctx["redis_sync"], job_id)
        if not cancelled:
            job.started_at = utcnow()
            _set_status(db, job, None, "running")
    if cancelled:
        _terminate(ctx, job_id, "cancelled")
        return

    def emit(event: dict) -> None:
        _publish(ctx, job_id, event)

    def should_cancel() -> bool:
        return events.is_cancel_requested(ctx["redis_sync"], job_id)

    try:
        items, papers = await asyncio.to_thread(ks.reindex, emit, should_cancel)
    except ks.ReindexCancelled:
        # 线上索引没被动过：重建全程在临时目录里进行
        _terminate(ctx, job_id, "cancelled")
        return
    except (asyncio.TimeoutError, asyncio.CancelledError):
        # CancelledError 是 BaseException，不会落进下面的 except Exception；
        # 不显式处理的话这行会永远停在 running
        await events.request_cancel(ctx["redis_async"], job_id, settings.events_ttl_s)
        _terminate(ctx, job_id, "failed",
                   {"code": "timeout", "message": f"job exceeded {settings.job_timeout_s}s"})
        raise
    except Exception as e:  # noqa: BLE001
        logger.exception("kb reindex job %s failed", job_id)
        _terminate(ctx, job_id, "failed", {"code": "internal_error", "message": f"{type(e).__name__}: {e}"})
        return

    with SessionLocal() as db:
        job = _job(db, job_id)
        if job is not None:
            _set_status(db, job, None, "succeeded", result={"items": items, "papers": papers}, finished=True)
    _publish(ctx, job_id, {"type": "succeeded", "items": items, "papers": papers})


async def run_paper_ingest_job(ctx: dict, job_id: str) -> None:
    with SessionLocal() as db:
        job = _job(db, job_id)
        if job is None:
            logger.warning("job %s not found in db; dropping", job_id)
            return
        params = dict(job.params or {})
        cancelled = events.is_cancel_requested(ctx["redis_sync"], job_id)
        if not cancelled:
            job.started_at = utcnow()
            _set_status(db, job, None, "running")
    if cancelled:
        _terminate(ctx, job_id, "cancelled")
        return

    def emit(event: dict) -> None:
        _publish(ctx, job_id, event)
        if event.get("type") in ("stage", "progress"):
            with SessionLocal() as pdb:                     # 独立短事务，不占长连接
                row = pdb.get(Job, job_id)
                if row is not None:
                    row.progress = {"stage": event.get("stage"), "current": event.get("current"),
                                    "total": event.get("total")}
                    pdb.commit()

    def should_cancel() -> bool:
        return events.is_cancel_requested(ctx["redis_sync"], job_id)

    src = ingest.IngestSource(kind=params.get("source", "upload"), pdf_path=params.get("pdf_path", ""),
                              doi=params.get("doi", ""), meta=params.get("meta") or {})
    try:
        res = await asyncio.to_thread(ingest.run_ingest, src, emit=emit, should_cancel=should_cancel)
    except ask.PipelineCancelled:
        _terminate(ctx, job_id, "cancelled")
        return
    except ask.PipelineError as e:
        _terminate(ctx, job_id, "failed", {"code": e.code, "message": str(e)})
        return
    except (asyncio.TimeoutError, asyncio.CancelledError):
        await events.request_cancel(ctx["redis_async"], job_id, settings.events_ttl_s)
        _terminate(ctx, job_id, "failed",
                   {"code": "timeout", "message": f"job exceeded {settings.job_timeout_s}s"})
        raise
    except Exception as e:  # noqa: BLE001
        logger.exception("paper ingest job %s failed", job_id)
        _terminate(ctx, job_id, "failed", {"code": "internal_error", "message": f"{type(e).__name__}: {e}"})
        return

    result = {"key": res.key, "n_paragraphs": res.n_paragraphs, "n_facts": res.n_facts, "items": res.items}
    with SessionLocal() as db:
        job = _job(db, job_id)
        if job is not None:
            _set_status(db, job, None, "succeeded", result=result, finished=True)
    _publish(ctx, job_id, {"type": "succeeded", **result})


async def refresh_journal_ranks(ctx: dict) -> None:
    """每月拉一次上一年度 SCImago 表；已存在就跳过。

    落盘后不需要通知任何进程：api 与 worker 的 journal_rank 靠文件签名在下一次
    load()/lookup() 时自行重载。
    """
    year = dt.date.today().year - 1
    dest = os.path.join(RANK_DIR, f"scimagojr_{year}.csv")
    if os.path.exists(dest):
        logger.info("ranking table %s already present; skip", dest)
        return
    try:
        path = await asyncio.to_thread(jr.download_scimago, year)
    except Exception:  # noqa: BLE001  playwright 缺失、Cloudflare 未通过都只记日志，不影响 worker
        logger.exception("scimago %s download failed", year)
        return
    logger.info("ranking table saved: %s -> %s", path, jr.load(force=True))


async def on_startup(ctx: dict) -> None:
    import redis
    import redis.asyncio as aioredis

    ctx["redis_sync"] = redis.Redis.from_url(settings.redis_url)
    ctx["redis_async"] = aioredis.from_url(settings.redis_url)
    logger.info("worker up: redis=%s db=%s", settings.redis_url, settings.database_url)


async def on_shutdown(ctx: dict) -> None:
    sync = ctx.get("redis_sync")
    if sync is not None:
        sync.close()
    async_client = ctx.get("redis_async")
    if async_client is not None:
        await async_client.aclose()


def _redis_settings():
    from arq.connections import RedisSettings

    return RedisSettings.from_dsn(settings.redis_url)


class WorkerSettings:
    functions = [run_ask_job, run_kb_reindex_job, run_paper_ingest_job]
    # 每月 1 日 03:00（容器时区 UTC）；arq 默认 unique=True，多 worker 只会跑一份
    cron_jobs = [cron(refresh_journal_ranks, day=1, hour=3, minute=0, timeout=900)]
    redis_settings = _redis_settings()
    max_jobs = settings.worker_max_jobs
    job_timeout = settings.job_timeout_s
    keep_result = 3600
    on_startup = on_startup
    on_shutdown = on_shutdown


def run() -> None:
    from arq import run_worker

    run_worker(WorkerSettings)  # type: ignore[arg-type]


__all__ = ["WorkerSettings", "refresh_journal_ranks", "run", "run_ask_job", "run_kb_reindex_job",
           "run_paper_ingest_job"]
