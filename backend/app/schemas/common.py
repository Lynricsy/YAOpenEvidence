"""跨资源共用的类型：时间戳序列化、分页信封、错误体。"""
from __future__ import annotations

import datetime as dt
from typing import Annotated, Generic, TypeVar

from pydantic import BaseModel, Field, PlainSerializer

T = TypeVar("T")


def _iso_z(v: dt.datetime) -> str:
    """统一输出 `...Z`：SQLite 读回来的是 naive datetime，一律当 UTC。"""
    v = v.replace(tzinfo=dt.timezone.utc) if v.tzinfo is None else v.astimezone(dt.timezone.utc)
    return v.isoformat(timespec="seconds").replace("+00:00", "Z")


UtcDateTime = Annotated[dt.datetime, PlainSerializer(_iso_z, return_type=str, when_used="json")]


class Page(BaseModel, Generic[T]):
    items: list[T]
    total: int
    limit: int
    offset: int


class Problem(BaseModel):
    """RFC 9457 Problem Details。`code` 是稳定枚举，`detail` 仅供人读。"""

    type: str = Field(examples=["urn:yaoe:error:not_found"])
    title: str = Field(examples=["Not Found"])
    status: int = Field(examples=[404])
    detail: str = Field(examples=["answer 'abc' not found"])
    instance: str = Field(examples=["/v1/answers/abc"])
    code: str = Field(examples=["not_found"])
    errors: list[dict] | None = None


class JobError(BaseModel):
    code: str
    message: str
