"""期刊分区查询。"""
from __future__ import annotations

from pydantic import BaseModel


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
