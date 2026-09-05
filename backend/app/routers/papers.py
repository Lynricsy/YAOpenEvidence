"""文献库只读端点。"""
from __future__ import annotations

from fastapi import APIRouter, Depends, Query
from pydantic import BaseModel

from ..auth import require
from ..schemas.common import MarkdownResponse, Page
from ..schemas.papers import Fact, PaperMeta, Paragraph
from ..services import papers as service

router = APIRouter(prefix="/papers", tags=["papers"])
_read = require()


class ParagraphList(BaseModel):
    items: list[Paragraph]


class FactList(BaseModel):
    items: list[Fact]


@router.get("", response_model=Page[PaperMeta], summary="浏览文献库")
def list_papers(q: str = "", limit: int = Query(20, ge=1, le=100),
                offset: int = Query(0, ge=0), _principal=Depends(_read)) -> Page[PaperMeta]:
    items, total = service.list_papers(q=q, limit=limit, offset=offset)
    return Page(items=items, total=total, limit=limit, offset=offset)


@router.get("/{key}", response_model=PaperMeta, summary="读取文献元数据")
def get_paper(key: str, _principal=Depends(_read)) -> dict:
    return service.get_meta(key)


@router.get("/{key}/paragraphs", response_model=ParagraphList, summary="读取全部段落")
def get_paragraphs(key: str, _principal=Depends(_read)) -> dict:
    return {"items": service.get_paragraphs(key)}


@router.get("/{key}/paragraphs/{pid}", response_model=Paragraph, summary="读取单个段落")
def get_paragraph(key: str, pid: int, _principal=Depends(_read)) -> dict:
    return service.get_paragraph(key, pid)


@router.get("/{key}/facts", response_model=FactList, summary="读取原子事实")
def get_facts(key: str, _principal=Depends(_read)) -> dict:
    return {"items": service.get_facts(key)}


@router.get("/{key}/fulltext", response_class=MarkdownResponse, summary="读取带段落锚点的全文")
def get_fulltext(key: str, _principal=Depends(_read)) -> MarkdownResponse:
    path = service.fulltext_path(key)
    with open(path, encoding="utf-8") as f:
        content = f.read()
    return MarkdownResponse(content)
