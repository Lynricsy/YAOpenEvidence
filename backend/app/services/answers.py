"""answers 资源的领域逻辑：入参转换、结果落库形状、历史答案导入。"""
from __future__ import annotations

import datetime as dt
import os

from sqlalchemy import select
from sqlalchemy.orm import Session

import journal_rank as jr
from ask import AskOptions
from picos_paths import ANSWERS_DIR

from ..models import Answer
from ..schemas.answers import AnswerCreate

LEGACY_TS_FORMAT = "%Y%m%d_%H%M%S"


def to_ask_options(opts: AnswerCreate | dict) -> AskOptions:
    """HTTP 入参 -> 流水线入参。

    协议层用结构化字段（year_from/year_to、quartiles 列表），core 沿用 CLI 的
    字符串形式（"2020-2024"、"Q1,Q2"），转换只在这一处发生。
    """
    o = opts if isinstance(opts, AnswerCreate) else AnswerCreate.model_validate(opts)
    year = f"{o.year_from}-{o.year_to or o.year_from}" if o.year_from else ""
    return AskOptions(
        question=o.question,
        papers=o.papers,
        max_chars=o.max_chars,
        use_paywall=o.use_paywall,
        years=o.years or 0,
        year=year,
        quartile=",".join(f"Q{z}" for z in o.quartiles),
        journal=",".join(o.journals),
        keep_unranked=o.keep_unranked,
        use_kb=o.use_kb,
        kb_hits=o.kb_hits,
    )


def to_answer_paper(p: dict) -> dict:
    """流水线内部 paper dict -> 对外 AnswerPaper（丢掉全文、段落等大块中间产物）。"""
    cites = p.get("cites") or []
    return {
        "n": p.get("n", 0),
        "pmid": p.get("pmid") or "",
        "doi": p.get("doi") or "",
        "pmcid": p.get("pmcid") or "",
        "title": p.get("title") or "",
        "year": str(p.get("year") or ""),
        "journal": p.get("journal") or "",
        "issn": p.get("issn") or "",
        "authors": p.get("authors") or "",
        "quartile": p.get("quartile") or "",
        "rank_label": jr.label(p.get("rank")),
        "source": p.get("source") or "abstract",
        "relevance": p.get("relevance"),
        "n_paragraphs": len(p.get("paras") or []),
        "n_citations": len(cites),
        "n_citations_verified": sum(1 for c in cites if c.get("verified")),
    }


def answer_paths(answer_id: str) -> tuple[str, str]:
    """(answers/<id>.md, answers/<id>_papers/)"""
    return os.path.join(ANSWERS_DIR, f"{answer_id}.md"), os.path.join(ANSWERS_DIR, f"{answer_id}_papers")


def import_legacy_answers(db: Session) -> int:
    """把 CLI 时代的 answers/<ts>.md 收进 answers 表（幂等），使它们能被浏览。

    这些答案没有结构化数据（papers/citations 为空），只有渲染稿；因此
    /markdown 可用，/papers/{n} 会 404。
    """
    if not os.path.isdir(ANSWERS_DIR):
        return 0
    known = set(db.scalars(select(Answer.id)).all())
    added = 0
    for name in sorted(os.listdir(ANSWERS_DIR)):
        if not name.endswith(".md"):
            continue
        stem = name[:-3]
        if stem in known:
            continue
        path = os.path.join(ANSWERS_DIR, name)
        text = ""
        try:
            with open(path, encoding="utf-8") as f:
                text = f.read()
        except OSError:
            continue
        first = text.splitlines()[0].strip() if text else ""
        question = first[5:].strip() if first.startswith("# Q: ") else stem
        try:
            created = dt.datetime.strptime(stem, LEGACY_TS_FORMAT).replace(tzinfo=dt.timezone.utc)
        except ValueError:
            created = dt.datetime.fromtimestamp(os.path.getmtime(path), dt.timezone.utc)
        db.add(Answer(id=stem, job_id=None, api_key_id=None, status="ready", question=question,
                      question_en=None, queries=[], options={}, filters_label=None,
                      n_papers=None, n_fulltext=None, papers=[], body_md=None, answer_md=text,
                      citations=[], kb_hits=[], error=None, created_at=created,
                      started_at=created, finished_at=created))
        known.add(stem)
        added += 1
    db.commit()
    return added
