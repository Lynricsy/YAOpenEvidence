"""文献库（library/）与知识库（kb/）的读模型。"""
from __future__ import annotations

from pydantic import BaseModel

from .common import UtcDateTime


class Paragraph(BaseModel):
    id: int
    sec: str
    page: int | None = None
    text: str


class Fact(BaseModel):
    fact: str
    fact_zh: str = ""
    kind: str = "finding"
    pid: int | None = None
    sec: str | None = None
    page: int | None = None
    quote: str = ""
    score: float = 0.0
    verified: bool = False


class PaperMeta(BaseModel):
    key: str
    pmid: str = ""
    doi: str = ""
    pmcid: str = ""
    title: str = ""
    year: str = ""
    journal: str = ""
    issn: str = ""
    quartile: str = ""
    authors: str = ""
    source: str = ""
    types: list[str] = []
    indexed_at: UtcDateTime | None = None
    n_paragraphs: int = 0
    n_facts: int = 0


class VerifiedQuote(BaseModel):
    """模型笔记里的一条引文及其核实结果。"""

    claimed_pid: int
    pid: int | None = None
    sec: str | None = None
    page: int | None = None
    quote: str
    score: float = 0.0
    verified: bool = False
    note_section: str | None = None
    key_finding: bool = False
