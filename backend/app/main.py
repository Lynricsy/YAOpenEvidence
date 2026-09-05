"""应用装配。

启动时把「进程级、创建代价高」的东西一次性建好挂到 app.state：
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
from .config import settings
from .errors import PROBLEM_MEDIA_TYPE, register_handlers
from .routers import answers, auth, health, jobs, journals, kb, literature, papers, users
from .schemas.common import Problem
from .schemas.events import event_schemas

logger = logging.getLogger("yaoe")

DESCRIPTION = """\
YAOpenEvidence 医学文献证据问答 API。

- 问答任务异步执行：`POST /v1/answers` 返回 202，进度走 `GET /v1/jobs/{id}/events`（SSE）
- 鉴权：管理员创建账号，登录后使用 `Authorization: Bearer <access_token>`（包括 SSE）
- 错误：RFC 9457 Problem Details（`application/problem+json`），按 `code` 分支
"""


@asynccontextmanager
async def lifespan(app: FastAPI):
    from arq.connections import RedisSettings, create_pool
    from redis.asyncio import from_url
    from .services.kb import KbService

    app.state.settings = settings
    app.state.arq = await create_pool(RedisSettings.from_dsn(settings.redis_url))
    app.state.redis = from_url(settings.redis_url)
    app.state.kb = KbService()
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
            allow_headers=["Authorization", "Content-Type", "Last-Event-ID"],
            expose_headers=["Location", "Retry-After", "WWW-Authenticate"],
        )
    register_handlers(app)
    # 不传 model：FastAPI 会按成功响应的媒体类型为附加模型自动补 content。
    problem_content = {
        PROBLEM_MEDIA_TYPE: {"schema": {"$ref": "#/components/schemas/Problem"}},
    }
    problem_response = {
        "default": {"description": "Problem Details (RFC 9457)", "content": problem_content},
        422: {"description": "Request validation failed", "content": problem_content},
    }
    for module in (health, auth, users, answers, jobs, papers, kb, journals, literature):
        app.include_router(module.router, prefix="/v1", responses=problem_response)

    original_openapi = app.openapi

    def openapi() -> dict:
        if app.openapi_schema is not None:
            return app.openapi_schema
        schema = original_openapi()
        # 纯 content 引用不会触发 FastAPI 的模型收集，集中注册共享组件。
        components = schema.setdefault("components", {}).setdefault("schemas", {})
        components["Problem"] = Problem.model_json_schema(ref_template="#/components/schemas/{model}")
        components.update(event_schemas())
        return schema

    app.openapi = openapi
    return app
