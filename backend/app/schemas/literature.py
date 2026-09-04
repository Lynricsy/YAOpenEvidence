"""上游文献检索的透传模型（PubMed / Semantic Scholar / Europe PMC）。"""
from __future__ import annotations

from typing import Literal

from pydantic import BaseModel

from .journals import RankInfo

LiteratureSource = Literal["pubmed", "s2"]


class LiteratureRecord(BaseModel):
    source: LiteratureSource
    id: str
    pmid: str | None = None
    pmcid: str | None = None
    doi: str | None = None
    s2_id: str | None = None
    title: str = ""
    abstract: str | None = None
    year: str | None = None
    journal: str | None = None
    issn: str | None = None
    authors: list[str] = []
    types: list[str] = []
    cited_by: int | None = None
    open_access_pdf: str | None = None
    tldr: str | None = None
    rank: RankInfo | None = None


class LiteratureSearchResult(BaseModel):
    source: LiteratureSource
    total: int
    items: list[LiteratureRecord]
    fallback_reason: str | None = None


class FulltextSection(BaseModel):
    title: str
    chars: int


class FulltextResult(BaseModel):
    pmcid: str
    citation: str
    sections: list[FulltextSection]
    abstract: str = ""
    section: str | None = None
    text: str | None = None
    truncated: bool = False


class LiteratureRecordList(BaseModel):
    items: list[LiteratureRecord]
