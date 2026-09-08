"""文献库端点：只读浏览 + 单篇入库（上传 PDF / 按 DOI 取全文）。

入库对任意登录用户开放，并发闸门沿用 `services.jobs.ensure_capacity`
（YAOE_MAX_ACTIVE_JOBS_PER_USER），和问答任务共享同一个额度。
"""
from __future__ import annotations

from fastapi import APIRouter, Depends, File, Form, Query, UploadFile
from pydantic import BaseModel
from sqlalchemy.orm import Session
from starlette.concurrency import run_in_threadpool

from ..auth import Principal, require
from ..config import settings
from ..deps import get_arq, get_db
from ..errors import ApiError
from ..schemas.common import MarkdownResponse, Page
from ..schemas.jobs import Job
from ..schemas.papers import Fact, PaperIngestRequest, PaperMeta, Paragraph
from ..services import jobs as jobs_service
from ..services import literature as literature_service
from ..services import papers as service
from ..services import paywall as paywall_service

router = APIRouter(prefix="/papers", tags=["papers"])
_read = require()


class ParagraphList(BaseModel):
    items: list[Paragraph]


class FactList(BaseModel):
    items: list[Fact]


@router.post("/upload", status_code=202, response_model=Job, summary="上传 PDF 入库")
async def upload_paper(file: UploadFile = File(...),
                       title: str = Form(..., min_length=1, max_length=300),
                       doi: str = Form(""), journal: str = Form(""),
                       year: str = Form(""), authors: str = Form(""),
                       db: Session = Depends(get_db), arq=Depends(get_arq),  # noqa: ANN001
                       principal: Principal = Depends(_read)) -> Job:
    jobs_service.ensure_capacity(db, principal)
    resolved = None
    if doi.strip():
        # 有 DOI 就顺手补全元数据；上游不可达不该挡住入库，退回用户填的字段
        try:
            record = await run_in_threadpool(literature_service.resolve, doi.strip())
            resolved = service.meta_from_record(record, doi.strip())
        except ApiError:
            resolved = None
    # 元数据先组装：merge_user_meta 会因无法派生 library key 抛 422，
    # 放在落盘之前才不会留下没有 job 行的孤儿 PDF。
    meta = service.merge_user_meta(resolved, title=title, doi=doi, journal=journal,
                                   year=year, authors=authors)
    job_id = jobs_service.new_id()
    pdf_path = service.ingest_pdf_path(job_id)
    await service.save_upload(file, pdf_path, settings.upload_max_mb)
    job = await jobs_service.enqueue(
        arq, db, kind="paper_ingest",
        params={"source": "upload", "pdf_path": pdf_path, "doi": meta["doi"], "meta": meta},
        user_id=principal.user_id, fn_name="run_paper_ingest_job", job_id=job_id)
    return Job.model_validate(job)


@router.post("/ingest", status_code=202, response_model=Job, summary="按 DOI 经机构访问入库")
async def ingest_doi(body: PaperIngestRequest,
                     db: Session = Depends(get_db), arq=Depends(get_arq),  # noqa: ANN001
                     principal: Principal = Depends(_read)) -> Job:
    jobs_service.ensure_capacity(db, principal)
    st = paywall_service.status()
    if not (st["configured"] and st["playwright_available"]):
        raise ApiError(409, "conflict", "机构访问未配置，无法按 DOI 获取全文")
    record = await run_in_threadpool(literature_service.resolve, body.doi)
    meta = service.meta_from_record(record, body.doi)
    job_id = jobs_service.new_id()
    job = await jobs_service.enqueue(
        arq, db, kind="paper_ingest",
        params={"source": "doi", "pdf_path": service.ingest_pdf_path(job_id),
                "doi": body.doi, "meta": meta},
        user_id=principal.user_id, fn_name="run_paper_ingest_job", job_id=job_id)
    return Job.model_validate(job)


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
