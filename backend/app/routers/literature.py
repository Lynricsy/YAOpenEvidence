"""文献上游透传的只读 HTTP 路由。"""
from __future__ import annotations

from typing import Literal

from fastapi import APIRouter, Depends, Query

from ..auth import Principal, require
from ..errors import ApiError
from ..schemas.literature import (
    FulltextResult,
    LiteratureRecord,
    LiteratureRecordList,
    LiteratureSearchResult,
)
from ..services import literature as service

router = APIRouter(prefix="/literature", tags=["literature"])


def _validate_filters(*, years: int | None, year_from: int | None,
                      year_to: int | None, quartiles: list[int]) -> None:
    if years is not None and year_from is not None:
        raise ApiError(422, "validation_error", "years and year_from are mutually exclusive")
    if year_to is not None and year_from is None:
        raise ApiError(422, "validation_error", "year_to requires year_from")
    if year_from is not None and year_to is not None and year_to < year_from:
        raise ApiError(422, "validation_error", "year_to must be greater than or equal to year_from")
    if any(quartile not in range(1, 5) for quartile in quartiles):
        raise ApiError(422, "validation_error", "quartiles must contain only values from 1 to 4")


@router.get("/search", response_model=LiteratureSearchResult, summary="检索上游文献")
def search(
    q: str = Query(..., min_length=1),
    source: Literal["auto", "pubmed", "s2"] = "auto",
    limit: int = Query(10, ge=1, le=30),
    years: int | None = Query(None, ge=1, le=50),
    year_from: int | None = Query(None, ge=1900, le=2100),
    year_to: int | None = Query(None, ge=1900, le=2100),
    publication_types: list[str] = Query(default=[]),
    quartiles: list[int] = Query(default=[]),
    journals: list[str] = Query(default=[]),
    open_access_only: bool = False,
    _principal: Principal = Depends(require("read")),
) -> LiteratureSearchResult:
    _validate_filters(years=years, year_from=year_from, year_to=year_to, quartiles=quartiles)
    return service.search(
        q=q,
        source=source,
        limit=limit,
        years=years,
        year_from=year_from,
        year_to=year_to,
        publication_types=publication_types,
        quartiles=quartiles,
        journals=journals,
        open_access_only=open_access_only,
    )


@router.get("/fulltext", response_model=FulltextResult, summary="读取 PMC 全文")
def get_fulltext(
    ident: str = Query(..., min_length=1),
    section: str = "",
    max_chars: int = Query(20000, ge=1000, le=100000),
    _principal: Principal = Depends(require("read")),
) -> FulltextResult:
    return service.fulltext(ident, section=section, max_chars=max_chars)


@router.get("/citations", response_model=LiteratureRecordList, summary="获取引用文献")
def get_citations(
    ident: str = Query(..., min_length=1),
    limit: int = Query(10, ge=1, le=50),
    _principal: Principal = Depends(require("read")),
) -> LiteratureRecordList:
    return LiteratureRecordList(items=service.citations(ident, limit))


@router.get("/references", response_model=LiteratureRecordList, summary="获取参考文献")
def get_references(
    ident: str = Query(..., min_length=1),
    limit: int = Query(10, ge=1, le=50),
    _principal: Principal = Depends(require("read")),
) -> LiteratureRecordList:
    return LiteratureRecordList(items=service.references(ident, limit))


@router.get("/recommendations", response_model=LiteratureRecordList, summary="获取推荐文献")
def get_recommendations(
    ident: str = Query(..., min_length=1),
    limit: int = Query(10, ge=1, le=50),
    _principal: Principal = Depends(require("read")),
) -> LiteratureRecordList:
    return LiteratureRecordList(items=service.recommendations(ident, limit))


@router.get("/resolve", response_model=LiteratureRecord, summary="获取单篇文献")
def get_literature(
    ident: str = Query(..., min_length=1),
    _principal: Principal = Depends(require("read")),
) -> LiteratureRecord:
    return service.resolve(ident)
