"""问答任务的创建与结果浏览。

创建走 202 + `Location`：流水线要跑几分钟（检索 → 下全文 → 逐篇读 → 综合），
不可能同步返回。answers 行在入队前就建好，`id` 同时是流水线的 run_id，
于是 `answers/<id>.md` 与 `answers/<id>_papers/` 的命名与 HTTP 资源一一对应。
"""
from __future__ import annotations

import os
import shutil

from fastapi import APIRouter, Depends, Path, Query, Response
from fastapi.responses import PlainTextResponse
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from picos_paths import LIB_DIR

from ..auth import Principal, require
from ..config import settings
from ..deps import get_arq, get_db, get_redis
from ..errors import ApiError
from ..models import Answer as AnswerRow
from ..models import Job as JobRow
from ..schemas.answers import (
    TERMINAL_ANSWER_STATUSES,
    Answer,
    AnswerCreate,
    AnswerPaperDetail,
    AnswerStatus,
    AnswerSummary,
)
from ..schemas.common import Page
from ..services import jobs as jobs_service
from ..services.answers import answer_paths, read_json

router = APIRouter(tags=["answers"])

MARKDOWN = "text/markdown; charset=utf-8"


def _row(db: Session, answer_id: str) -> AnswerRow:
    row = db.get(AnswerRow, answer_id)
    if row is None:
        raise ApiError(404, "not_found", f"answer {answer_id!r} not found")
    return row


@router.post("/answers", status_code=202, response_model=Answer, summary="创建问答任务")
async def create_answer(payload: AnswerCreate, response: Response,
                        db: Session = Depends(get_db), arq=Depends(get_arq),  # noqa: ANN001
                        principal: Principal = Depends(require("write"))) -> Answer:
    # 这里必须是 async（enqueue 是协程）；DB 操作都是单行 sqlite 读写，毫秒级，
    # 放在事件循环里可以接受，长查询一律留在 def 路由里
    active = jobs_service.active_job_count(db, principal.key_id)
    if active >= settings.max_active_jobs_per_key:
        raise ApiError(429, "too_many_jobs",
                       f"{active} active job(s) for this key; limit is {settings.max_active_jobs_per_key}")
    options = payload.model_dump()
    answer_id = jobs_service.new_id()
    row = AnswerRow(id=answer_id, job_id=None, api_key_id=principal.key_id, status="queued",
                    question=payload.question, queries=[], options=options, papers=[],
                    citations=[], kb_hits=[])
    db.add(row)
    db.commit()
    job = await jobs_service.enqueue(arq, db, kind="ask", params={"answer_id": answer_id, **options},
                                     api_key_id=principal.key_id, fn_name="run_ask_job")
    row.job_id = job.id
    db.commit()
    db.refresh(row)
    response.headers["Location"] = f"/v1/answers/{answer_id}"
    return Answer.model_validate(row)


@router.get("/answers", response_model=Page[AnswerSummary], summary="问答任务列表")
def list_answers(status: AnswerStatus | None = None, q: str = "",
                 limit: int = Query(20, ge=1, le=100), offset: int = Query(0, ge=0),
                 db: Session = Depends(get_db),
                 principal: Principal = Depends(require("read"))) -> Page[AnswerSummary]:
    conds = []
    if status:
        conds.append(AnswerRow.status == status)
    if q.strip():
        conds.append(AnswerRow.question.like(f"%{q.strip()}%"))
    total = int(db.scalar(select(func.count(AnswerRow.id)).where(*conds)) or 0)
    rows = db.scalars(select(AnswerRow).where(*conds)
                      .order_by(AnswerRow.created_at.desc(), AnswerRow.id.desc())
                      .limit(limit).offset(offset)).all()
    return Page[AnswerSummary](items=[AnswerSummary.model_validate(r) for r in rows],
                               total=total, limit=limit, offset=offset)


@router.get("/answers/{answer_id}", response_model=Answer, summary="问答任务详情")
def get_answer(answer_id: str, db: Session = Depends(get_db),
               principal: Principal = Depends(require("read"))) -> Answer:
    return Answer.model_validate(_row(db, answer_id))


@router.get("/answers/{answer_id}/markdown", response_class=PlainTextResponse,
            summary="完整渲染稿（Markdown）")
def get_answer_markdown(answer_id: str, db: Session = Depends(get_db),
                        principal: Principal = Depends(require("read"))) -> PlainTextResponse:
    row = _row(db, answer_id)
    if row.status != "ready":
        raise ApiError(409, "not_ready", f"answer {answer_id!r} is {row.status}")
    text = row.answer_md
    if not text:                                  # legacy 导入的行只有文件，没有落库
        path, _ = answer_paths(answer_id)
        if not os.path.exists(path):
            raise ApiError(404, "not_found", f"rendered markdown for {answer_id!r} is missing")
        with open(path, encoding="utf-8") as f:
            text = f.read()
    return PlainTextResponse(text, media_type=MARKDOWN)


@router.get("/answers/{answer_id}/papers/{n}", response_model=AnswerPaperDetail,
            summary="本次阅读的第 n 篇（笔记、引文、段落、全文）")
def get_answer_paper(answer_id: str, n: int = Path(ge=1), db: Session = Depends(get_db),
                     principal: Principal = Depends(require("read"))) -> AnswerPaperDetail:
    row = _row(db, answer_id)
    paper = next((p for p in (row.papers or []) if p.get("n") == n), None)
    if paper is None:
        raise ApiError(404, "not_found", f"answer {answer_id!r} has no paper #{n}")
    _, papers_dir = answer_paths(answer_id)
    stem = paper.get("pmid") or "paper"
    notes_path = os.path.join(papers_dir, f"{stem}_notes.md")
    fulltext_path = os.path.join(papers_dir, f"{stem}.md")
    if not (os.path.exists(notes_path) and os.path.exists(fulltext_path)):
        raise ApiError(404, "not_found", f"per-paper files for {answer_id!r} #{n} are missing")
    with open(notes_path, encoding="utf-8") as f:
        notes_md = f.read()
    with open(fulltext_path, encoding="utf-8") as f:
        fulltext_md = f.read()
    paragraphs = read_json(os.path.join(papers_dir, f"{stem}_paragraphs.json"), default=None)
    if paragraphs is None:                        # 早期运行只在 library 里留了段落
        paragraphs = read_json(os.path.join(LIB_DIR, stem, "paragraphs.json"), default=[])
    return AnswerPaperDetail(
        **paper,
        notes_md=notes_md,
        citations=read_json(os.path.join(papers_dir, f"{stem}_citations.json"), default=[]),
        facts=read_json(os.path.join(papers_dir, f"{stem}_facts.json"), default=[]),
        paragraphs=paragraphs,
        fulltext_md=fulltext_md,
    )


@router.delete("/answers/{answer_id}", status_code=204, summary="取消任务或删除结果")
async def delete_answer(answer_id: str, db: Session = Depends(get_db), redis=Depends(get_redis),  # noqa: ANN001
                        principal: Principal = Depends(require("write"))) -> Response:
    row = _row(db, answer_id)
    if not (principal.is_admin or row.api_key_id == principal.key_id):
        raise ApiError(403, "forbidden", "not your answer")
    if row.status not in TERMINAL_ANSWER_STATUSES:
        # 还在跑：删除等于取消，结果文件由 worker 自己收尾
        job = db.get(JobRow, row.job_id) if row.job_id else None
        if job is None:
            raise ApiError(409, "conflict", f"answer {answer_id!r} is {row.status} but has no job")
        await jobs_service.cancel(job, redis, principal)
        return Response(status_code=204)
    md_path, papers_dir = answer_paths(answer_id)
    db.delete(row)
    db.commit()
    shutil.rmtree(papers_dir, ignore_errors=True)
    try:
        os.remove(md_path)
    except FileNotFoundError:
        pass
    return Response(status_code=204)
