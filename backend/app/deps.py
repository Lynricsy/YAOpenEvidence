"""FastAPI 依赖：配置、DB session、Redis/arq 连接、KB 服务。

Redis/arq/KB 都挂在 `app.state` 上（lifespan 建、关闭时收），依赖只做取用，
不在请求路径上新建连接。
"""
from __future__ import annotations

from typing import TYPE_CHECKING

from fastapi import Request

from .config import Settings, get_settings  # noqa: F401  (re-export 给路由用)
from .db import get_db  # noqa: F401

if TYPE_CHECKING:
    from arq.connections import ArqRedis
    from redis.asyncio import Redis

    from .services.kb import KbService


def get_arq(request: Request) -> ArqRedis:
    return request.app.state.arq


def get_redis(request: Request) -> Redis:
    return request.app.state.redis


def get_kb(request: Request) -> KbService:
    return request.app.state.kb
