"""应用装配。

启动时把「进程级、创建代价高」的东西一次性建好挂到 app.state：API key 表、
arq 连接池、Redis 客户端、KB 服务、期刊分区表。请求路径上只取用，不新建。
迁移不在启动时自动跑（多副本会打架），用 `yaoe migrate`。
"""
from __future__ import annotations

import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

import journal_rank as jr

from . import __version__
from .auth import load_api_keys
from .config import settings
from .errors import register_handlers
from .routers import health
from .schemas.common import Problem

logger = logging.getLogger("yaoe")

DESCRIPTION = """\
YAOpenEvidence 医学文献证据问答 API。

- 问答任务异步执行：`POST /v1/answers` 返回 202，进度走 `GET /v1/jobs/{id}/events`（SSE）
- 鉴权：`Authorization: Bearer <api_key>`；SSE 也接受 `?access_token=`
- 错误：RFC 9457 Problem Details（`application/problem+json`），按 `code` 分支
"""


@asynccontextmanager
async def lifespan(app: FastAPI):
    from arq.connections import RedisSettings, create_pool
    from redis.asyncio import from_url

    app.state.settings = settings
    app.state.auth_disabled = settings.auth_disabled
    app.state.principals = load_api_keys(settings.api_keys_file, auth_disabled=settings.auth_disabled)
    app.state.arq = await create_pool(RedisSettings.from_dsn(settings.redis_url))
    app.state.redis = from_url(settings.redis_url)
    tables = jr.load()          # 分区表 11MB CSV，预热避免首个请求慢
    logger.info("ranking tables: %s", tables or "none")
    try:
        yield
    finally:
        await app.state.arq.aclose()
        await app.state.redis.aclose()


def create_app() -> FastAPI:
    app = FastAPI(
        title="YAOpenEvidence API",
        version=__version__,
        description=DESCRIPTION,
        openapi_url="/v1/openapi.json",
        docs_url="/v1/docs",
        redoc_url="/v1/redoc",
        lifespan=lifespan,
    )
    if settings.cors_origins:
        app.add_middleware(
            CORSMiddleware,
            allow_origins=settings.cors_origins,
            allow_methods=["*"],
            allow_headers=["Authorization", "Content-Type"],
        )
    register_handlers(app)
    problem_response = {"default": {"model": Problem, "description": "Problem Details (RFC 9457)"}}
    for module in (health,):
        app.include_router(module.router, prefix="/v1", responses=problem_response)
    return app
