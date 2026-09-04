"""任务事件流（Redis Stream）与取消标记。

用 Stream 而不是 Pub/Sub：SSE 客户端断线重连要能带 `Last-Event-ID` 续传，
Pub/Sub 没有历史。entry id 直接当 SSE 的 `id:`，两边天然对齐。
流按 MAXLEN 截断并设 TTL（默认 7 天），过期后终态由 DB 合成一条事件补上。

取消是一个带 TTL 的 key：worker 在阶段边界轮询它（流水线跑在线程里，
没法用 asyncio 取消），排队中的任务则在开跑前就发现自己已被取消。
"""
from __future__ import annotations

import json
from collections.abc import AsyncIterator
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    import redis
    import redis.asyncio as aioredis

TERMINAL = frozenset({"succeeded", "failed", "cancelled"})


def stream_key(job_id: str) -> str:
    return f"yaoe:job:{job_id}:events"


def cancel_key(job_id: str) -> str:
    return f"yaoe:job:{job_id}:cancel"


def publish(r: redis.Redis, job_id: str, event: dict, *, maxlen: int, ttl_s: int) -> str:
    """同步发布一条事件（在流水线线程里调用），返回 entry id。"""
    payload = {k: v for k, v in event.items() if k != "type"}
    key = stream_key(job_id)
    entry_id = r.xadd(key, {"type": event.get("type", "log"),
                            "data": json.dumps(payload, ensure_ascii=False)},
                      maxlen=maxlen, approximate=True)
    r.expire(key, ttl_s)
    return entry_id.decode() if isinstance(entry_id, bytes) else str(entry_id)


def _decode(fields: dict) -> tuple[str, dict]:
    def s(v: object) -> str:
        return v.decode() if isinstance(v, bytes) else str(v)

    raw = {s(k): s(v) for k, v in fields.items()}
    try:
        data = json.loads(raw.get("data") or "{}")
    except json.JSONDecodeError:
        data = {}
    return raw.get("type", "log"), data


async def subscribe(r: aioredis.Redis, job_id: str, last_id: str = "0-0",
                    *, block_ms: int = 5000) -> AsyncIterator[tuple[str, str, dict]]:
    """从 `last_id` 之后逐条 yield (entry_id, type, data)，遇终态事件即结束。"""
    key = stream_key(job_id)
    cursor = last_id or "0-0"
    while True:
        batch = await r.xread({key: cursor}, count=100, block=block_ms)
        if not batch:
            continue
        for _stream, entries in batch:
            for entry_id, fields in entries:
                cursor = entry_id.decode() if isinstance(entry_id, bytes) else str(entry_id)
                kind, data = _decode(fields)
                yield cursor, kind, data
                if kind in TERMINAL:
                    return


async def has_stream(r: aioredis.Redis, job_id: str) -> bool:
    return bool(await r.exists(stream_key(job_id)))


async def request_cancel(r: aioredis.Redis, job_id: str, ttl_s: int) -> None:
    await r.set(cancel_key(job_id), "1", ex=ttl_s)


def is_cancel_requested(r: redis.Redis, job_id: str) -> bool:
    return bool(r.exists(cancel_key(job_id)))
