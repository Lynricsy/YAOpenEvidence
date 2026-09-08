"""问答任务的创建与结果浏览。

创建走 202 + `Location`：流水线要跑几分钟（检索 → 下全文 → 逐篇读 → 综合），
不可能同步返回。answers 行在入队前就建好，`id` 同时是流水线的 run_id，
于是 `answers/<id>.md` 与 `answers/<id>_papers/` 的命名与 HTTP 资源一一对应。
"""
from __future__ import annotations

import os
import shutil

from fastapi import APIRouter, Depends, Path, Query, Response
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from ..auth import Principal, require
from ..deps import get_arq, get_db
from ..errors import ApiError
from ..models import Answer as AnswerRow
from ..schemas.answers import (
    TERMINAL_ANSWER_STATUSES,
    Answer,
    AnswerCreate,
    AnswerPaperDetail,
    AnswerStatus,
    AnswerSummary,
)
from ..schemas.common import MarkdownResponse, Page
from ..services import jobs as jobs_service
from ..services.answers import (
    answer_paths,
    http_answer_markdown,
    paper_artifact_path,
    paper_stems,
    read_json,
)

router = APIRouter(tags=["answers"])


def _row(db: Session, answer_id: str, principal: Principal) -> AnswerRow:
    row = db.get(AnswerRow, answer_id)
    if row is None or not (principal.is_admin or row.user_id == principal.user_id):
        raise ApiError(404, "not_found", f"answer {answer_id!r} not found")
    return row


@router.post("/answers", status_code=202, response_model=Answer, summary="创建问答任务")
async def create_answer(payload: AnswerCreate, response: Response,
                        db: Session = Depends(get_db), arq=Depends(get_arq),  # noqa: ANN001
                        principal: Principal = Depends(require())) -> Answer:
    # 这里必须是 async（enqueue 是协程）；DB 操作都是单行 sqlite 读写，毫秒级，
    # 放在事件循环里可以接受，长查询一律留在 def 路由里
    jobs_service.ensure_capacity(db, principal)
    options = payload.model_dump()
    answer_id = jobs_service.new_id()
    row = AnswerRow(id=answer_id, job_id=None, user_id=principal.user_id, status="queued",
                    question=payload.question, queries=[], options=options, papers=[],
                    citations=[], kb_hits=[])
    await jobs_service.enqueue(arq, db, kind="ask", params={"answer_id": answer_id, **options},
                                     user_id=principal.user_id, fn_name="run_ask_job", answer=row)
    db.refresh(row)
    response.headers["Location"] = f"/v1/answers/{answer_id}"
    return Answer.model_validate(row)


@router.get("/answers", response_model=Page[AnswerSummary], summary="问答任务列表")
def list_answers(status: AnswerStatus | None = None, q: str = "",
                 limit: int = Query(20, ge=1, le=100), offset: int = Query(0, ge=0),
                 db: Session = Depends(get_db),
                 principal: Principal = Depends(require())) -> Page[AnswerSummary]:
    conds = []
    if not principal.is_admin:
        conds.append(AnswerRow.user_id == principal.user_id)
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
               principal: Principal = Depends(require())) -> Answer:
    return Answer.model_validate(_row(db, answer_id, principal))


@router.get("/answers/{answer_id}/markdown", response_class=MarkdownResponse,
            summary="完整渲染稿（Markdown）")
def get_answer_markdown(answer_id: str, db: Session = Depends(get_db),
                        principal: Principal = Depends(require())) -> MarkdownResponse:
    row = _row(db, answer_id, principal)
    if row.status != "ready":
        raise ApiError(409, "not_ready", f"answer {answer_id!r} is {row.status}")
    return MarkdownResponse(http_answer_markdown(row), headers={"Cache-Control": "no-store"})


@router.get("/answers/{answer_id}/papers/{n}/markdown", response_class=MarkdownResponse,
            summary="本次阅读原文快照（含段落锚点的 Markdown）")
def get_answer_paper_markdown(answer_id: str, n: int = Path(ge=1), db: Session = Depends(get_db),
                              principal: Principal = Depends(require())) -> MarkdownResponse:
    row = _row(db, answer_id, principal)
    stem = paper_stems(row).get(n)
    if stem is None:
        raise ApiError(404, "not_found", f"answer {answer_id!r} has no paper #{n}")
    path = paper_artifact_path(answer_id, stem)
    try:
        with open(path, encoding="utf-8") as f:
            return MarkdownResponse(f.read(), headers={"Cache-Control": "no-store"})
    except FileNotFoundError as exc:
        raise ApiError(404, "not_found", f"paper snapshot for {answer_id!r} #{n} is missing") from exc


@router.get("/answers/{answer_id}/papers/{n}", response_model=AnswerPaperDetail,
            summary="本次阅读的第 n 篇（笔记、引文、段落、全文）")
def get_answer_paper(answer_id: str, n: int = Path(ge=1), db: Session = Depends(get_db),
                     principal: Principal = Depends(require())) -> AnswerPaperDetail:
    row = _row(db, answer_id, principal)
    paper = next((p for p in (row.papers or []) if p.get("n") == n), None)
    if paper is None:
        raise ApiError(404, "not_found", f"answer {answer_id!r} has no paper #{n}")
    # 全文和元数据都限制在本次阅读目录，不从可被覆盖的 library 回退。
    stem = paper.get("pmid") or "paper"
    notes_path = paper_artifact_path(answer_id, stem, "_notes.md")
    fulltext_path = paper_artifact_path(answer_id, stem)
    if not (os.path.exists(notes_path) and os.path.exists(fulltext_path)):
        raise ApiError(404, "not_found", f"per-paper files for {answer_id!r} #{n} are missing")
    with open(notes_path, encoding="utf-8") as f:
        notes_md = f.read()
    with open(fulltext_path, encoding="utf-8") as f:
        fulltext_md = f.read()
    paragraphs = read_json(paper_artifact_path(answer_id, stem, "_paragraphs.json"), default=[])
    return AnswerPaperDetail(
        **paper,
        notes_md=notes_md,
        citations=read_json(paper_artifact_path(answer_id, stem, "_citations.json"), default=[]),
        facts=read_json(paper_artifact_path(answer_id, stem, "_facts.json"), default=[]),
        paragraphs=paragraphs,
        fulltext_md=fulltext_md,
    )


@router.delete("/answers/{answer_id}", status_code=204, summary="删除终态答案")
def delete_answer(answer_id: str, db: Session = Depends(get_db),
                        principal: Principal = Depends(require())) -> Response:
    row = _row(db, answer_id, principal)
    if row.status not in TERMINAL_ANSWER_STATUSES:
        raise ApiError(409, "conflict", f"answer {answer_id!r} is {row.status}; cancel its job first")
    md_path, papers_dir = answer_paths(answer_id)
    db.delete(row)
    db.commit()
    shutil.rmtree(papers_dir, ignore_errors=True)
    try:
        os.remove(md_path)
    except FileNotFoundError:
        pass
    return Response(status_code=204)
