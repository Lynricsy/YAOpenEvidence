"""知识库检索与重建入口。"""
from __future__ import annotations

from typing import Literal

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session

from ..auth import Principal, require
from ..deps import get_arq, get_db, get_kb
from ..schemas.jobs import Job
from ..schemas.kb import KbSearchResult, KbStats
from ..services.jobs import enqueue
from ..services.kb import KbService

router = APIRouter(prefix="/kb", tags=["kb"])
_read = require()
_admin = require(admin=True)


@router.get("/search", response_model=KbSearchResult, summary="检索知识库")
async def search(q: str, kind: Literal["fact", "paragraph"] | None = None,
                 top_k: int = Query(8, ge=1, le=50),
                 pmid: list[str] = Query(default=[]),
                 _principal: Principal = Depends(_read),
                 kb: KbService = Depends(get_kb)) -> KbSearchResult:
    items = await kb.search(q, kind=kind or "", top_k=top_k, pmids=set(pmid) or None)
    return KbSearchResult(query=q, items=items)


@router.get("/stats", response_model=KbStats, summary="读取知识库统计")
def stats(_principal: Principal = Depends(_read),
          kb: KbService = Depends(get_kb)) -> dict:
    return kb.stats()


@router.post("/reindex", response_model=Job, status_code=status.HTTP_202_ACCEPTED,
             summary="重建知识库索引")
async def reindex(principal: Principal = Depends(_admin), arq=Depends(get_arq),
                  db: Session = Depends(get_db)) -> Job:
    job = await enqueue(arq, db, kind="kb_reindex", params={}, user_id=principal.user_id,
                        fn_name="run_kb_reindex_job")
    return Job.model_validate(job)
