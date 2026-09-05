"""文献检索、标识符解析与 Europe PMC 全文读取。"""
from __future__ import annotations

import datetime as dt
import re
from collections.abc import Iterable

import journal_rank as jr
import literature as lit

from ..errors import ApiError
from ..schemas.journals import RankInfo
from ..schemas.literature import (
    FulltextResult,
    FulltextSection,
    LiteratureRecord,
    LiteratureSearchResult,
)


def _rank_info(info: dict | None) -> RankInfo | None:
    if info is None:
        return None
    data = dict(info)
    h_index = data.get("h_index")
    data["h_index"] = str(h_index) if h_index is not None else None
    return RankInfo.model_validate(data)


def _upstream_error(exc: lit.UpstreamError) -> ApiError:
    if isinstance(exc, lit.UpstreamNotFound):
        return ApiError(404, "not_found", f"{exc.source}: {exc.detail}")
    return ApiError(502, "upstream_unavailable", f"{exc.source}: {exc.detail}")


def from_pubmed(rec: dict) -> LiteratureRecord:
    """把 core 的 PubMed 记录收敛为稳定的 API 模型。"""
    pmid = rec["pmid"]
    journal = rec.get("journal", "")
    issn = rec.get("issn", "")
    return LiteratureRecord(
        source="pubmed",
        id=pmid,
        pmid=pmid,
        pmcid=rec["pmc"] or None,
        doi=rec["doi"] or None,
        s2_id=None,
        title=rec["title"],
        abstract=rec["abstract"],
        year=rec["year"],
        journal=rec["journal"],
        issn=rec["issn"],
        authors=rec["authors"],
        types=rec["types"],
        cited_by=None,
        open_access_pdf=None,
        tldr=None,
        rank=_rank_info(jr.lookup(issn=issn, title=journal)),
    )


def from_s2(p: dict) -> LiteratureRecord:
    """把 Semantic Scholar 的嵌套字段展开为稳定的 API 模型。"""
    external_ids = p.get("externalIds") or {}
    pmcid = external_ids.get("PubMedCentral")
    if pmcid:
        pmcid = str(pmcid)
        if not pmcid.upper().startswith("PMC"):
            pmcid = f"PMC{pmcid}"
    venue = p.get("venue") or ""
    paper_id = p["paperId"]
    return LiteratureRecord(
        source="s2",
        id=paper_id,
        pmid=external_ids.get("PubMed"),
        pmcid=pmcid or None,
        doi=external_ids.get("DOI"),
        s2_id=paper_id,
        title=p.get("title") or "",
        abstract=p.get("abstract"),
        year=str(p["year"]) if p.get("year") else None,
        journal=p.get("venue"),
        issn=None,
        authors=[a["name"] for a in (p.get("authors") or [])],
        types=p.get("publicationTypes") or [],
        cited_by=p.get("citationCount"),
        open_access_pdf=(p.get("openAccessPdf") or {}).get("url"),
        tldr=(p.get("tldr") or {}).get("text"),
        rank=_rank_info(jr.lookup(title=venue)),
    )


def _year_range(years: int | None, year_from: int | None,
                year_to: int | None) -> tuple[int, int, str]:
    if years is not None:
        current = dt.date.today().year
        year_from, year_to = current - years + 1, current
    start = year_from or 0
    end = year_to or (start if start else 0)
    return start, end, f"{start}-{end}" if start else ""


def _search_pubmed(*, q: str, limit: int, year_from: int, year_to: int,
                   publication_types: Iterable[str], quartiles: Iterable[int],
                   journals: Iterable[str]) -> tuple[int, list[LiteratureRecord]]:
    total, records = lit.pubmed_search_records(
        q,
        limit=limit,
        year_from=year_from,
        year_to=year_to,
        publication_types=publication_types,
        zones=set(quartiles),
        journals=journals,
    )
    return total, [from_pubmed(record) for record in records]


def _search_s2(*, q: str, limit: int, year: str,
               publication_types: Iterable[str], quartiles: Iterable[int],
               journals: Iterable[str], open_access_only: bool) -> tuple[int, list[LiteratureRecord]]:
    total, papers = lit.s2_search(
        q,
        limit,
        year=year,
        publication_types=",".join(publication_types),
        open_access_only=open_access_only,
        zones=set(quartiles),
    )
    journal_terms = [term.strip().lower() for term in journals if term.strip()]
    if journal_terms:
        papers = [
            paper for paper in papers
            if any(term in (paper.get("venue") or "").lower() for term in journal_terms)
        ]
    return total, [from_s2(paper) for paper in papers[:limit] if paper.get("paperId")]


def search(*, q: str, source: str = "auto", limit: int = 10,
           years: int | None = None, year_from: int | None = None,
           year_to: int | None = None, publication_types: Iterable[str] = (),
           quartiles: Iterable[int] = (), journals: Iterable[str] = (),
           open_access_only: bool = False) -> LiteratureSearchResult:
    """检索文献；auto 只在 S2 不可用时降级到 PubMed。"""
    start, end, s2_year = _year_range(years, year_from, year_to)
    if source in {"auto", "s2"}:
        try:
            total, items = _search_s2(
                q=q,
                limit=limit,
                year=s2_year,
                publication_types=publication_types,
                quartiles=quartiles,
                journals=journals,
                open_access_only=open_access_only,
            )
            return LiteratureSearchResult(source="s2", total=total, items=items)
        except lit.UpstreamError as exc:
            if source == "s2":
                raise _upstream_error(exc) from exc
            fallback_reason = str(exc)
    else:
        fallback_reason = None

    try:
        total, items = _search_pubmed(
            q=q,
            limit=limit,
            year_from=start,
            year_to=end,
            publication_types=publication_types,
            quartiles=quartiles,
            journals=journals,
        )
    except lit.UpstreamError as exc:
        raise _upstream_error(exc) from exc
    return LiteratureSearchResult(
        source="pubmed",
        total=total,
        items=items,
        fallback_reason=fallback_reason,
    )


def _pubmed_record(pmid: str, requested: str) -> LiteratureRecord:
    try:
        records = lit.pubmed_fetch_records([pmid])
    except lit.UpstreamError as exc:
        raise _upstream_error(exc) from exc
    if not records:
        raise ApiError(404, "not_found", f"literature '{requested}' not found")
    return from_pubmed(records[0])


def resolve(ident: str) -> LiteratureRecord:
    """按 PMID、PMCID、DOI、S2 paperId 的优先级解析单篇文献。"""
    ident = ident.strip()
    if ident.isdigit():
        return _pubmed_record(ident, ident)

    if re.fullmatch(r"PMC\d+", ident, flags=re.IGNORECASE):
        pmcid = ident.upper()
        try:
            pmid = lit.pmcid_to_pmid(pmcid)
        except lit.UpstreamError as exc:
            raise _upstream_error(exc) from exc
        if not pmid:
            raise ApiError(404, "not_found", f"literature '{ident}' not found")
        return _pubmed_record(pmid, ident)

    if ident.lower().startswith("10."):
        s2_error = None
        try:
            paper = lit.s2_paper(f"DOI:{ident}")
            if paper.get("paperId"):
                return from_s2(paper)
        except lit.UpstreamNotFound:
            pass
        except lit.UpstreamError as exc:
            s2_error = exc
        try:
            pmcid, _ = lit.resolve_pmcid(ident)
            pmid = lit.pmcid_to_pmid(pmcid) if pmcid else ""
        except lit.UpstreamError as exc:
            raise _upstream_error(exc) from exc
        if pmid:
            return _pubmed_record(pmid, ident)
        if s2_error is not None:
            raise _upstream_error(s2_error) from s2_error
        raise ApiError(404, "not_found", f"literature '{ident}' not found")

    try:
        paper = lit.s2_paper(lit.norm_s2_id(ident))
    except lit.UpstreamError as exc:
        raise _upstream_error(exc) from exc
    if not paper.get("paperId"):
        raise ApiError(404, "not_found", f"literature '{ident}' not found")
    return from_s2(paper)


def _related(ident: str, limit: int, fetch) -> list[LiteratureRecord]:
    try:
        paper_id = lit.norm_s2_id(ident)
        papers = fetch(paper_id, limit)
    except lit.UpstreamError as exc:
        raise _upstream_error(exc) from exc
    return [from_s2(paper) for paper in papers if paper.get("paperId")]


def citations(ident: str, limit: int) -> list[LiteratureRecord]:
    return _related(ident, limit, lit.s2_citations)


def references(ident: str, limit: int) -> list[LiteratureRecord]:
    return _related(ident, limit, lit.s2_references)


def recommendations(ident: str, limit: int) -> list[LiteratureRecord]:
    return _related(ident, limit, lit.s2_recommendations)


def fulltext(ident: str, section: str = "", max_chars: int = 20000) -> FulltextResult:
    """读取 Europe PMC 全文；无 section 时只返回章节目录和摘要。"""
    try:
        pmcid, note = lit.resolve_pmcid(ident)
        if not pmcid:
            raise ApiError(404, "fulltext_unavailable", note or "no PMC full text")
        source_sections = lit.epmc_fulltext_sections(pmcid)
    except lit.UpstreamError as exc:
        raise _upstream_error(exc) from exc
    if not source_sections:
        raise ApiError(404, "fulltext_unavailable", f"full text unavailable for {pmcid}")

    sections = [FulltextSection(title=title, chars=len(text)) for title, text in source_sections]
    abstract = next((text for title, text in source_sections if title == "Abstract"), "")
    selected_section: str | None = None
    text: str | None = None
    if section:
        section_query = section.lower()
        if section_query == "all":
            selected_section = "all"
            text = "\n\n".join(f"## {title}\n{body}" for title, body in source_sections)
        else:
            match = next((item for item in source_sections if section_query in item[0].lower()), None)
            if match is None:
                raise ApiError(404, "not_found", f"section '{section}' not found")
            selected_section, body = match
            text = f"## {selected_section}\n{body}"

    truncated = text is not None and len(text) > max_chars
    if truncated:
        text = text[:max_chars]
    try:
        citation = lit.epmc_citation(pmcid)
    except lit.UpstreamError as exc:
        raise _upstream_error(exc) from exc
    return FulltextResult(
        pmcid=pmcid,
        citation=citation,
        sections=sections,
        abstract=abstract,
        section=selected_section,
        text=text,
        truncated=truncated,
    )
