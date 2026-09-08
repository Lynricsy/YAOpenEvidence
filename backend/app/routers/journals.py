"""期刊分区只读查询。"""
from __future__ import annotations

import datetime as dt

import journal_rank as jr
from fastapi import APIRouter, Depends

from ..auth import Principal, require
from ..errors import ApiError
from ..schemas.journals import RankInfo, RankQuery, RankResult, RankTable, RankTables

router = APIRouter(prefix="/journals", tags=["journals"])
_read = require()


@router.get("/rank", response_model=RankResult, summary="查询期刊分区")
def rank(issn: str = "", title: str = "",
         _principal: Principal = Depends(_read)) -> RankResult:
    if not issn.strip() and not title.strip():
        raise ApiError(422, "validation_error", "issn or title is required")

    query = RankQuery(issn=issn, title=title)
    info = jr.lookup(issn=issn, title=title)
    if info is None:
        return RankResult(query=query, found=False, rank=None, label=jr.label(None))

    normalized = {**info, "h_index": str(info["h_index"]) if info.get("h_index") is not None else None}
    return RankResult(query=query, found=True, rank=RankInfo.model_validate(normalized),
                      label=jr.label(info))


@router.get("/tables", response_model=RankTables, summary="读取已加载的分区表")
def tables(_principal: Principal = Depends(_read)) -> RankTables:
    """分区筛选的依据。空 tables 说明 Q1–Q4 过滤不会生效，前端据此提示。"""
    s = jr.stats()
    loaded_at = dt.datetime.fromtimestamp(s["loaded_at"], tz=dt.timezone.utc) if s["loaded_at"] else None
    return RankTables(tables=[RankTable(**t) for t in s["tables"]],
                      issns=s["issns"], titles=s["titles"], loaded_at=loaded_at)
