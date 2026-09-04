"""期刊分区只读查询。"""
from __future__ import annotations

import journal_rank as jr
from fastapi import APIRouter, Depends

from ..auth import Principal, require
from ..errors import ApiError
from ..schemas.journals import RankInfo, RankQuery, RankResult

router = APIRouter(prefix="/journals", tags=["journals"])
_read = require("read")


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
