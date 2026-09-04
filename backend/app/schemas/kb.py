"""知识库检索结果。"""
from __future__ import annotations

from typing import Literal

from pydantic import BaseModel


class KbHit(BaseModel):
    kind: Literal["fact", "paragraph"]
    pmid: str = ""
    doi: str = ""
    pmcid: str = ""
    title: str = ""
    year: str = ""
    journal: str = ""
    quartile: str = ""
    source: str = ""
    authors: str = ""
    pid: int | None = None
    sec: str | None = None
    page: int | None = None
    text: str
    text_zh: str | None = None
    fact_kind: str | None = None
    quote: str | None = None
    verified: bool | None = None
    score: float


class KbSearchResult(BaseModel):
    query: str
    items: list[KbHit]


class KbStats(BaseModel):
    items: int
    papers: int
    by_kind: dict[str, int]
    embedder: str | None = None
    dim: int | None = None
