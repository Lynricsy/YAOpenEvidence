"""任务事件流（Redis Stream）与取消标记。

用 Stream 而不是 Pub/Sub：SSE 客户端断线重连要能带 `Last-Event-ID` 续传，
Pub/Sub 没有历史。entry id 直接当 SSE 的 `id:`，两边天然对齐。
流按 MAXLEN 截断并设 TTL（默认 7 天），过期后终态由 DB 合成一条事件补上。

取消是一个带 TTL 的 key：worker 在阶段边界轮询它（流水线跑在线程里，
没法用 asyncio 取消），排队中的任务则在开跑前就发现自己已被取消。
"""
from __future__ import annotations

import json
from collections.abc import AsyncIterator, Awaitable, Callable
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
                    *, block_ms: int = 5000,
                    terminal: Callable[[], Awaitable[tuple[str, dict] | None]] | None = None,
                    ) -> AsyncIterator[tuple[str, str, dict]]:
    """按游标回放；空读时核对 DB，补齐发布失败或已过期的终态。"""
    key = stream_key(job_id)
    cursor = last_id or "0-0"
    pending_terminal = await terminal() if terminal is not None else None
    while True:
        # DB 已终态时先排空并发到达的事件，保持真实 Stream 的顺序和 ID。
        batch = await r.xread({key: cursor}, count=100,
                              block=None if pending_terminal else block_ms)
        if not batch:
            if pending_terminal is not None:
                yield cursor, pending_terminal[0], pending_terminal[1]
                return
            if terminal is not None:
                pending_terminal = await terminal()
            continue
        for _stream, entries in batch:
            for entry_id, fields in entries:
                cursor = entry_id.decode() if isinstance(entry_id, bytes) else str(entry_id)
                kind, data = _decode(fields)
                yield cursor, kind, data
                if kind in TERMINAL:
                    return


async def request_cancel(r: aioredis.Redis, job_id: str, ttl_s: int) -> None:
    await r.set(cancel_key(job_id), "1", ex=ttl_s)


def is_cancel_requested(r: redis.Redis, job_id: str) -> bool:
    return bool(r.exists(cancel_key(job_id)))
