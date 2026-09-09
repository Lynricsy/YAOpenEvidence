"""answers 资源的领域逻辑：入参转换、结果落库形状、历史答案导入。"""
from __future__ import annotations

import datetime as dt
import json
import os
import re
from urllib.parse import unquote, urlsplit

from sqlalchemy import func, select
from sqlalchemy.orm import Session

import journal_rank as jr
from ask import AskOptions, Filters
from picos_paths import ANSWERS_DIR

from ..errors import ApiError
from ..models import Answer
from ..schemas.answers import Answer as AnswerSchema
from ..schemas.answers import AnswerCreate, AnswerSummary

LEGACY_TS_FORMAT = "%Y%m%d_%H%M%S"


def read_json(path: str, default=None):  # noqa: ANN001, ANN201
    """读 JSON 文件；缺文件或内容坏掉都退回 `default`。

    每篇论文的附属文件（facts/citations/paragraphs）在不同选项下可能不存在，
    调用方需要区分「没有」和「读坏了」时再自己判断 default。
    """
    try:
        with open(path, encoding="utf-8") as f:
            return json.load(f)
    except (FileNotFoundError, NotADirectoryError, json.JSONDecodeError):
        return default


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


def to_codex_prompt(opts: AnswerCreate | dict) -> str:
    """HTTP 入参 -> codex 的一条用户消息。

    过滤条件对 codex 是「要求」而非硬闸门：AGENTS.md 已经规定把年份/分区/期刊传给
    对应的 MCP 工具，这里只负责把结构化字段翻成模型能照做的约束。ask 专属的
    max_chars / use_paywall / keep_unranked 不在此列——codex 不走那条流水线。
    """
    o = opts if isinstance(opts, AnswerCreate) else AnswerCreate.model_validate(opts)
    rules = [f"检索至少 {o.papers} 篇相关文献后再作答。"]
    if o.years:
        rules.append(f"只用最近 {o.years} 年发表的文献（对应工具参数 last_years={o.years}）。")
    elif o.year_from:
        rules.append(f"只用 {o.year_from}-{o.year_to or o.year_from} 年发表的文献"
                     f"（对应工具参数 year=\"{o.year_from}-{o.year_to or o.year_from}\"）。")
    if o.quartiles:
        zones = ",".join(f"Q{z}" for z in o.quartiles)
        rules.append(f"只用 {zones} 分区期刊（对应工具参数 quartile=\"{zones}\"）。")
    if o.journals:
        names = ",".join(o.journals)
        rules.append(f"限定期刊 {names}（对应 pubmed_search 的 journal=\"{names}\"）。")
    rules.append("先用 kb_search 查已入库的原子知识，可直接引用。" if o.use_kb
                 else "不要使用 kb_search，只用本次实时检索到的文献。")
    return o.question + "\n\n检索要求：\n" + "\n".join(f"- {r}" for r in rules)


def describe_filters(opts: AnswerCreate | dict) -> str:
    """筛选条件的中文描述；与 ask 流水线共用 `Filters.describe`，两个引擎的标签同源。"""
    o = to_ask_options(opts)
    return Filters(o.years, o.year, o.quartile, o.journal, o.keep_unranked).describe()


def thread_rows(db: Session, row: Answer) -> list[Answer]:
    """一条 codex 会话的全部回合（升序）；没有 thread_id 的行自成一轮。"""
    if not row.thread_id:
        return [row]
    return list(db.scalars(select(Answer).where(Answer.thread_id == row.thread_id)
                           .order_by(Answer.created_at, Answer.id)))


def thread_meta(db: Session, rows: list[Answer]) -> dict[str, tuple[int, str | None]]:
    """批量取每行的 (会话回合数, 根问题)；根问题只对追问行有意义。"""
    ids = {r.thread_id for r in rows if r.thread_id}
    if not ids:
        return {}
    counts = dict(db.execute(select(Answer.thread_id, func.count())
                             .where(Answer.thread_id.in_(ids))
                             .group_by(Answer.thread_id)).all())
    roots = dict(db.execute(select(Answer.thread_id, Answer.question)
                            .where(Answer.thread_id.in_(ids),
                                   Answer.parent_id.is_(None))).all())
    return {r.id: (int(counts.get(r.thread_id, 1)),
                   roots.get(r.thread_id) if r.parent_id else None)
            for r in rows if r.thread_id}


def summaries(db: Session, rows: list[Answer]) -> list[AnswerSummary]:
    meta = thread_meta(db, rows)
    return [AnswerSummary.model_validate(r).model_copy(
        update=dict(zip(("n_turns", "root_question"), meta.get(r.id, (1, None)), strict=True)))
        for r in rows]


def detail(db: Session, row: Answer) -> AnswerSchema:
    n_turns, root_question = thread_meta(db, [row]).get(row.id, (1, None))
    return AnswerSchema.model_validate(row).model_copy(
        update={"n_turns": n_turns, "root_question": root_question})


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
    """只允许答案根目录内的单个资源，拒绝路径和符号链接越界。"""
    if not re.fullmatch(r"[A-Za-z0-9_-]+", answer_id):
        raise ApiError(404, "not_found", "invalid answer artifact")
    root = os.path.realpath(ANSWERS_DIR)
    paths = (os.path.join(root, f"{answer_id}.md"), os.path.join(root, f"{answer_id}_papers"))
    if any(os.path.dirname(os.path.realpath(path)) != root for path in paths):
        raise ApiError(404, "not_found", "invalid answer artifact")
    return paths


def answer_markdown(row: Answer) -> str:
    if row.answer_md:
        return row.answer_md
    path, _ = answer_paths(row.id)
    try:
        with open(path, encoding="utf-8") as f:
            return f.read()
    except FileNotFoundError as exc:
        raise ApiError(404, "not_found", f"rendered markdown for {row.id!r} is missing") from exc


def paper_artifact_path(answer_id: str, stem: str, suffix: str = ".md") -> str:
    """文件名仅来自本次论文映射，不接受任意下载路径。"""
    if not re.fullmatch(r"[A-Za-z0-9_-]+", stem):
        raise ApiError(404, "not_found", "invalid paper artifact")
    _, directory = answer_paths(answer_id)
    path = os.path.join(directory, stem + suffix)
    if os.path.dirname(os.path.realpath(path)) != directory:
        raise ApiError(404, "not_found", "invalid paper artifact")
    return path


def _local_paper_stem(answer_id: str, url: str) -> str | None:
    parsed = urlsplit(url)
    if parsed.scheme not in ("", "file") or parsed.netloc or parsed.query:
        return None
    path = unquote(parsed.path)
    filename = os.path.basename(path)
    if not filename.endswith(".md"):
        return None
    stem = filename[:-3]
    if not re.fullmatch(r"[A-Za-z0-9_-]+", stem):
        return None
    expected = paper_artifact_path(answer_id, stem)
    if path not in (f"{answer_id}_papers/{filename}", f"./{answer_id}_papers/{filename}", expected):
        return None
    return stem


def paper_stems(row: Answer, text: str | None = None) -> dict[int, str]:
    """旧 CLI 答案从参考文献恢复编号，只接受本次目录里的原文链接。"""
    if row.papers:
        return {p["n"]: p.get("pmid") or "paper" for p in row.papers}
    text = answer_markdown(row) if text is None else text
    stems: dict[int, str] = {}
    for match in re.finditer(r"^\[(\d+)\][^\n]*\[原文\]\(([^)\n]+)\)", text, re.MULTILINE):
        stem = _local_paper_stem(row.id, match[2])
        if stem is not None:
            stems[int(match[1])] = stem
    return stems


def http_answer_markdown(row: Answer) -> str:
    """历史持久化稿只重写已知本次论文链接，保留原文段落锚点。"""
    text = answer_markdown(row)
    by_stem = {stem: n for n, stem in paper_stems(row, text).items()}

    def replace(match: re.Match) -> str:
        stem = _local_paper_stem(row.id, match[2])
        n = by_stem.get(stem) if stem is not None else None
        if n is None:
            return match[0]
        fragment = urlsplit(match[2]).fragment
        anchor = f"#{fragment}" if re.fullmatch(r"p[1-9]\d*", fragment) else ""
        return f"[{match[1]}](/v1/answers/{row.id}/papers/{n}/markdown{anchor})"

    return re.sub(r"\[([^\]\n]*)\]\(([^)\n]+)\)", replace, text)


def import_legacy_answers(db: Session) -> int:
    """把 CLI 时代的 answers/<ts>.md 收进 answers 表（幂等），使它们能被浏览。

    没有结构化 papers 时从本次参考文献恢复编号，原文资源仍只读本次快照。
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
        db.add(Answer(id=stem, job_id=None, user_id=None, status="ready", question=question,
                      question_en=None, queries=[], options={}, filters_label=None,
                      n_papers=None, n_fulltext=None, papers=[], body_md=None, answer_md=text,
                      citations=[], kb_hits=[], error=None, created_at=created,
                      started_at=created, finished_at=created))
        known.add(stem)
        added += 1
    db.commit()
    return added
