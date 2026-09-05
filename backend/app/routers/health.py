"""存活与就绪探针（免鉴权）。

/health 只回答「进程活着」；/health/ready 逐项探 db / redis / llm / kb / ranks，
db 或 redis 挂了才返回 503——LLM 或 kb 不可用时 API 仍能提供只读浏览，
所以只标 degraded，让编排系统别把整个服务摘掉。
"""
from __future__ import annotations

import datetime as dt
from typing import Literal

import httpx
from fastapi import APIRouter, Request, Response
from pydantic import BaseModel
from sqlalchemy import text
from starlette.concurrency import run_in_threadpool

import ask
import journal_rank as jr
import knowledge_store as ks
from picos_paths import KB_DIR

from .. import __version__
from ..db import SessionLocal
from ..schemas.common import UtcDateTime

router = APIRouter(tags=["health"])


class HealthResponse(BaseModel):
    status: Literal["ok"]
    version: str
    time: UtcDateTime


class DependencyCheck(BaseModel):
    ok: bool
    detail: str


class ReadinessChecks(BaseModel):
    db: DependencyCheck
    redis: DependencyCheck
    llm: DependencyCheck
    kb: DependencyCheck
    ranks: DependencyCheck


class ReadinessResponse(BaseModel):
    status: Literal["ok", "degraded"]
    checks: ReadinessChecks


def _now() -> str:
    return dt.datetime.now(dt.timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z")


@router.get("/health", response_model=HealthResponse, summary="存活探针")
def health() -> dict:
    return {"status": "ok", "version": __version__, "time": _now()}


def _check_db() -> dict:
    with SessionLocal() as db:
        db.execute(text("SELECT 1"))
    return {"ok": True, "detail": "ok"}


def _check_kb() -> dict:
    """只读索引头（不加载向量矩阵）：探针不该为了报个数字去读几 MB。"""
    info = ks.index_info(KB_DIR)
    if info is None:
        return {"ok": False, "detail": "no kb index (knowledge base empty)"}
    items = int(info.get("items") or 0)
    return {"ok": items > 0,
            "detail": f"embedder={info.get('embedder')} dim={info.get('dim')} items={items}"}


def _check_ranks() -> dict:
    files = jr.load()
    return {"ok": bool(files), "detail": ", ".join(files) or "no ranking table in data/journal_ranks/"}


async def _check_llm() -> dict:
    try:
        async with httpx.AsyncClient(timeout=3) as client:
            r = await client.get(f"{ask.LLM_BASE}/models",
                                 headers={"Authorization": f"Bearer {ask.LLM_KEY}"})
        if r.status_code != 200:
            return {"ok": False, "detail": f"{ask.LLM_BASE} returned HTTP {r.status_code}"}
        ids = [m.get("id") for m in (r.json().get("data") or [])]
        if ask.LLM_MODEL not in ids:
            return {"ok": False, "detail": f"model {ask.LLM_MODEL} not served; available: {ids}"}
        return {"ok": True, "detail": f"{ask.LLM_MODEL} @ {ask.LLM_BASE}"}
    except Exception as e:  # noqa: BLE001
        return {"ok": False, "detail": f"{ask.LLM_BASE} unreachable: {e}"}


@router.get("/health/ready", response_model=ReadinessResponse, summary="就绪探针",
            responses={503: {"model": ReadinessResponse, "description": "Database or Redis unavailable"}})
async def ready(request: Request, response: Response) -> dict:
    checks: dict[str, dict] = {}
    try:
        checks["db"] = await run_in_threadpool(_check_db)
    except Exception as e:  # noqa: BLE001
        checks["db"] = {"ok": False, "detail": str(e)}
    try:
        await request.app.state.redis.ping()
        checks["redis"] = {"ok": True, "detail": "ok"}
    except Exception as e:  # noqa: BLE001
        checks["redis"] = {"ok": False, "detail": str(e)}
    checks["llm"] = await _check_llm()
    for name, fn in (("kb", _check_kb), ("ranks", _check_ranks)):
        try:
            checks[name] = await run_in_threadpool(fn)
        except Exception as e:  # noqa: BLE001
            checks[name] = {"ok": False, "detail": str(e)}

    hard_down = not (checks["db"]["ok"] and checks["redis"]["ok"])
    if hard_down:
        response.status_code = 503
    status = "ok" if all(c["ok"] for c in checks.values()) else "degraded"
    return {"status": status, "checks": checks}
