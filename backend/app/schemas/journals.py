"""期刊分区查询与已加载分区表。"""
from __future__ import annotations

from typing import Literal

from pydantic import BaseModel

from .common import UtcDateTime


class RankInfo(BaseModel):
    title: str = ""
    issns: list[str] = []
    zone: int
    quartile: str
    sjr: float | None = None
    h_index: str | None = None
    categories: str = ""
    top: bool = False
    source: str = ""


class RankQuery(BaseModel):
    issn: str = ""
    title: str = ""


class RankResult(BaseModel):
    query: RankQuery
    found: bool
    rank: RankInfo | None = None
    label: str


class RankTable(BaseModel):
    """已加载的一张分区表。`year` 从文件名推断，推不出来就是 None。"""

    file: str
    year: int | None = None
    journals: int
    source: Literal["scimago", "custom"]


class RankTables(BaseModel):
    tables: list[RankTable]
    issns: int
    titles: int
    loaded_at: UtcDateTime | None = None
