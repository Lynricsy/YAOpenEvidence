#!/usr/bin/env python
"""Semantic Scholar MCP server (stdio) for Codex.

Exposes literature-search tools backed by the Semantic Scholar Graph API
(https://api.semanticscholar.org). Set S2_API_KEY for higher rate limits.

取数逻辑住在 literature.py；这里只剩 MCP 工具声明与「给模型看的文本」格式化。
"""
from __future__ import annotations

import os
import re

import httpx
from mcp.server.fastmcp import FastMCP
from mcp.types import ToolAnnotations

import journal_rank as jr  # local journal quartile tables (data/journal_ranks/)
import literature as lit

mcp = FastMCP("semantic_scholar")
RO = ToolAnnotations(readOnlyHint=True, destructiveHint=False, idempotentHint=True, openWorldHint=True)


# ---------------------------------------------------------------- formatting
def _authors(p: dict) -> str:
    names = [a.get("name", "") for a in (p.get("authors") or [])]
    if len(names) > 4:
        return ", ".join(names[:3]) + f", … (+{len(names) - 3})"
    return ", ".join(names)


def _ids(p: dict) -> str:
    ext = p.get("externalIds") or {}
    parts = []
    if ext.get("DOI"):
        parts.append(f"DOI:{ext['DOI']}")
    if ext.get("PubMed"):
        parts.append(f"PMID:{ext['PubMed']}")
    if ext.get("PubMedCentral"):
        parts.append(f"PMCID:{ext['PubMedCentral']}")
    return " ".join(parts)


def _fmt_short(i: int, p: dict) -> str:
    tldr = (p.get("tldr") or {}).get("text") or ""
    pub = ",".join(p.get("publicationTypes") or [])
    oa = (p.get("openAccessPdf") or {}).get("url") or ""
    rank = jr.lookup(title=p.get("venue") or "")
    lines = [
        f"[{i}] {p.get('title')} ({p.get('year')}) — {p.get('venue') or 'n/a'}" + (f" 〔{jr.label(rank)}〕" if rank else ""),
        f"    authors: {_authors(p)}",
        f"    paperId: {p.get('paperId')}  {_ids(p)}  cited_by: {p.get('citationCount')}"
        + (f"  type: {pub}" if pub else ""),
    ]
    if tldr:
        lines.append(f"    tldr: {tldr}")
    if oa:
        lines.append(f"    open_access_pdf: {oa}")
    return "\n".join(lines)


def _fmt_full(p: dict) -> str:
    tldr = (p.get("tldr") or {}).get("text") or ""
    oa = (p.get("openAccessPdf") or {}).get("url") or ""
    out = [
        f"Title: {p.get('title')}",
        f"Year: {p.get('year')}   Date: {p.get('publicationDate')}   Venue: {p.get('venue')}",
        f"Authors: {_authors(p)}",
        f"paperId: {p.get('paperId')}  {_ids(p)}",
        f"Citations: {p.get('citationCount')} (influential: {p.get('influentialCitationCount')})",
        f"Types: {','.join(p.get('publicationTypes') or [])}   Fields: {','.join(p.get('fieldsOfStudy') or [])}",
        f"URL: {p.get('url')}" + (f"   PDF: {oa}" if oa else ""),
    ]
    if tldr:
        out.append(f"TL;DR: {tldr}")
    out.append("Abstract: " + (p.get("abstract") or "(no abstract available)"))
    return "\n".join(out)


def _fmt_pubmed(i: int, p: dict, with_abstract: bool) -> str:
    au = p["authors"]
    au_s = ", ".join(au[:3]) + (f", … (+{len(au)-3})" if len(au) > 3 else "")
    ids = f"PMID:{p['pmid']}" + (f" DOI:{p['doi']}" if p["doi"] else "") + (f" PMCID:{p['pmc']}" if p["pmc"] else "")
    types = ",".join(t for t in p["types"] if t not in ("Journal Article",))
    rank = jr.label(jr.lookup(issn=p.get("issn", ""), title=p["journal"]))
    lines = [f"[{i}] {p['title']} ({p['year']}) — {p['journal']} 〔{rank}〕", f"    authors: {au_s}",
             f"    {ids}" + (f"  type: {types}" if types else "")]
    if with_abstract:
        lines.append("    abstract: " + (p["abstract"] or "(none)"))
    return "\n".join(lines)


def _year_range(year: str) -> tuple[int, int]:
    """'2020' / '2018-2024' -> (2018, 2024)；空串 -> (0, 0)。"""
    m = re.fullmatch(r"\s*(\d{4})\s*(?:[-~:至]\s*(\d{4}))?\s*", year or "")
    if not m:
        return 0, 0
    return int(m.group(1)), int(m.group(2) or m.group(1))


# ---------------------------------------------------------------- Semantic Scholar tools
@mcp.tool(annotations=RO)
def search_papers(
    query: str,
    limit: int = 10,
    year: str = "",
    publication_types: str = "",
    open_access_only: bool = False,
    fields_of_study: str = "Medicine",
    quartile: str = "",
) -> str:
    """Search Semantic Scholar for papers by keyword.

    Args:
        query: free-text query (English works best), e.g. "SGLT2 inhibitors heart failure mortality".
        limit: number of results (1-50).
        year: year or range, e.g. "2020" or "2018-2024".
        publication_types: comma list, e.g. "Review,MetaAnalysis,ClinicalTrial,JournalArticle".
        open_access_only: only return papers with a free PDF.
        fields_of_study: comma list, default "Medicine"; use "" for all fields.
        quartile: journal quartile filter (分区), e.g. "Q1,Q2" / "1-3"; matched on venue name (unranked venues dropped).
    Returns a numbered list with paperId, DOI/PMID, citation count and TL;DR.
    """
    zones = jr.parse_quartile_arg(quartile)
    try:
        total, items = lit.s2_search(query, limit, year=year, publication_types=publication_types,
                                     open_access_only=open_access_only, fields_of_study=fields_of_study, zones=zones)
    except lit.UpstreamError as e:
        fb = pubmed_search(query, limit=limit, year=year, quartile=quartile)
        return f"Semantic Scholar unavailable ({e.detail}); fell back to PubMed.\n" + fb
    if not items:
        return f"No results for query: {query!r} (total={total}). Try broader/English terms."
    head = f"{total or len(items)} total matches; showing {len(items)} for {query!r}\n"
    return head + "\n\n".join(_fmt_short(i + 1, p) for i, p in enumerate(items))


@mcp.tool(annotations=RO)
def get_paper(paper_id: str) -> str:
    """Get full details (abstract, venue, IDs, citation counts) for one paper.

    Args:
        paper_id: Semantic Scholar paperId, or "DOI:10.xxx/..", "PMID:12345", "PMC1234567", "ARXIV:2101.00001".
    Returns abstract only. For the full text of an open-access paper use get_fulltext.
    """
    try:
        paper_id = lit.norm_s2_id(paper_id)
        return _fmt_full(lit.s2_paper(paper_id))
    except lit.UpstreamError as e:
        if paper_id.upper().startswith("PMID:"):
            return "Semantic Scholar unavailable; PubMed record instead.\n" + pubmed_fetch(paper_id[5:])
        return f"ERROR: {e.detail} (tip: if you have a PMID use pubmed_fetch)"


@mcp.tool(annotations=RO)
def get_citations(paper_id: str, limit: int = 10) -> str:
    """List papers that CITE the given paper (newer follow-up work), most influential first."""
    try:
        items = lit.s2_citations(paper_id, limit)
    except lit.UpstreamError as e:
        return f"ERROR: {e.detail}"
    if not items:
        return "No citations found."
    return "\n\n".join(_fmt_short(i + 1, p) for i, p in enumerate(items))


@mcp.tool(annotations=RO)
def get_references(paper_id: str, limit: int = 10) -> str:
    """List papers the given paper CITES (its bibliography / background work)."""
    try:
        items = lit.s2_references(paper_id, limit)
    except lit.UpstreamError as e:
        return f"ERROR: {e.detail}"
    if not items:
        return "No references found."
    return "\n\n".join(_fmt_short(i + 1, p) for i, p in enumerate(items))


@mcp.tool(annotations=RO)
def get_recommendations(paper_id: str, limit: int = 10) -> str:
    """Get papers similar to the given one (Semantic Scholar recommendations)."""
    try:
        items = lit.s2_recommendations(paper_id, limit)
    except lit.UpstreamError as e:
        return f"ERROR: {e.detail}"
    if not items:
        return "No recommendations."
    return "\n\n".join(_fmt_short(i + 1, p) for i, p in enumerate(items))


@mcp.tool(annotations=RO)
def search_authors(name: str, limit: int = 5) -> str:
    """Find authors by name; returns authorId, affiliations, paper/citation counts and h-index."""
    try:
        items = lit.s2_authors(name, limit)
    except lit.UpstreamError as e:
        return f"ERROR: {e.detail}"
    if not items:
        return "No authors found."
    return "\n".join(
        f"[{i+1}] {a.get('name')}  authorId={a.get('authorId')}  aff={'; '.join(a.get('affiliations') or []) or 'n/a'}"
        f"  papers={a.get('paperCount')} citations={a.get('citationCount')} h={a.get('hIndex')}"
        for i, a in enumerate(items)
    )


# ---------------------------------------------------------------- PubMed fallback
@mcp.tool(annotations=RO)
def pubmed_search(query: str, limit: int = 10, year: str = "", publication_types: str = "",
                  quartile: str = "", journal: str = "", last_years: int = 0) -> str:
    """Search PubMed (NCBI) — use this when Semantic Scholar is rate-limited or for clinical queries.
    Returns titles, PMID/DOI, journal quartile (分区) and full abstracts.

    Args:
        query: PubMed query; boolean/MeSH syntax allowed, e.g. "SGLT2 inhibitors AND heart failure".
        limit: 1-30 results.
        year: "2020" or "2018-2024" (publication date range).
        last_years: e.g. 3 -> only the last 3 years (ignored when `year` is given).
        publication_types: comma list like "Meta-Analysis,Randomized Controlled Trial,Review,Systematic Review".
        quartile: journal quartile filter (SCImago SJR best quartile / 分区): "Q1", "Q1,Q2", "1-3", "一区,二区".
                  Journals missing from the ranking table are dropped when this is set.
        journal: comma list of journal-name substrings, e.g. "Nature,Lancet" (matches Nature 子刊 too).
    """
    if not year and last_years:
        import datetime as _dt
        y1 = _dt.date.today().year
        year = f"{y1 - int(last_years) + 1}-{y1}"
    y0, y1 = _year_range(year)
    zones = jr.parse_quartile_arg(quartile)
    jwords = [j.strip() for j in journal.split(",") if j.strip()]
    try:
        total, recs = lit.pubmed_search_records(
            query, limit=limit, year_from=y0, year_to=y1,
            publication_types=[t for t in publication_types.split(",") if t.strip()],
            zones=zones, journals=jwords)
    except lit.UpstreamError as e:
        return f"ERROR: PubMed search failed ({e.detail}). Retry shortly."
    if not total:
        return f"No PubMed results for {query!r}. Try broader terms or drop filters."
    note = ""
    if zones or jwords:
        note = f" (filters quartile={quartile!r} journal={journal!r}: {len(recs)} kept)"
        if not recs:
            return f"No PubMed results after filtering{note}. Relax the quartile/journal filter."
    if not recs:
        return f"No PubMed results for {query!r}. Try broader terms or drop filters."
    head = f"PubMed: {total} total matches; showing {len(recs)} for {query!r}{note}\n"
    return head + "\n\n".join(_fmt_pubmed(i + 1, p, with_abstract=True) for i, p in enumerate(recs))


@mcp.tool(annotations=RO)
def pubmed_fetch(pmids: str) -> str:
    """Fetch PubMed records (abstract, journal, DOI) for one or more PMIDs, comma-separated.
    PMIDs are plain numbers (e.g. 36041474). A "PMC..." id is NOT a PMID (it is mapped automatically)."""
    ids = []
    for x in pmids.split(","):
        x = x.strip().replace("PMID:", "").replace("PMCID:", "")
        if not x:
            continue
        if x.upper().startswith("PMC"):
            try:
                mapped = lit.pmcid_to_pmid(x.upper())
            except lit.UpstreamError as e:
                return f"ERROR: {e}"
            if not mapped:
                return f"{x} is a PMC id, not a PMID, and could not be mapped. Use get_fulltext('{x}') instead."
            x = mapped
        ids.append(x)
    try:
        recs = lit.pubmed_fetch_records(ids[:20])
    except lit.UpstreamError as e:
        return f"ERROR: {e}"
    if not recs:
        return "No records found (check PMIDs)."
    return "\n\n".join(_fmt_pubmed(i + 1, p, with_abstract=True) for i, p in enumerate(recs))


# ---------------------------------------------------------------- full text
@mcp.tool(annotations=RO)
def get_fulltext(paper_id: str, section: str = "", max_chars: int = 20000) -> str:
    """Get the FULL TEXT (Methods/Results/Discussion...) of an open-access paper via PubMed Central.
    USE THIS whenever the user asks about full text, methods, sample size, detailed results, or gives a
    PMC id like "PMC9306514". Other tools only return abstracts.

    Args:
        paper_id: PMID (e.g. "PMID:36041474" or "36041474"), PMCID ("PMC9306514"), DOI ("10.1016/..."), or S2 paperId.
        section: "" -> return the list of section titles plus the Abstract; give a section title
                 (e.g. "Results", "Methods", "Discussion") or "all" to get that text.
        max_chars: cap on returned characters (context window is limited; keep <= 20000).
    Works only for open-access papers in PMC. Paywalled papers: use read_pdf on a locally downloaded file.
    """
    try:
        pmcid, note = lit.resolve_pmcid(paper_id)
    except lit.UpstreamError as e:
        pmcid, note = "", str(e)
    if not pmcid:
        # try Semantic Scholar open-access PDF as a fallback
        try:
            data = lit.s2_get(f"/paper/{paper_id}", {"fields": "openAccessPdf,title"})
        except lit.UpstreamError as e:
            data, note = {}, note + f"; Semantic Scholar unavailable: {e.detail}"
        url = (data.get("openAccessPdf") or {}).get("url")
        if url:
            os.makedirs(lit.PDF_DIR, exist_ok=True)
            fn = os.path.join(lit.PDF_DIR, re.sub(r"[^A-Za-z0-9]+", "_", paper_id)[:80] + ".pdf")
            try:
                with httpx.stream("GET", url, follow_redirects=True, timeout=60, headers=lit.headers()) as r:
                    if r.status_code == 200 and "pdf" in r.headers.get("content-type", ""):
                        with open(fn, "wb") as f:
                            for chunk in r.iter_bytes():
                                f.write(chunk)
                        return f"(no PMC version; downloaded open-access PDF {url} -> {fn})\n" + lit.pdf_text(fn, max_chars)
            except Exception as e:  # noqa: BLE001
                note += f"; OA pdf download failed: {e}"
        return f"Full text not available: {note}. The abstract (get_paper / pubmed_fetch) is the best you can get without institutional access."
    try:
        secs = lit.epmc_fulltext_sections(pmcid)
    except lit.UpstreamError as e:
        return f"ERROR: {e}"
    if not secs:
        return f"{pmcid} exists but Europe PMC has no XML full text (may be embargoed). Try get_paper for the abstract."
    try:
        citation = lit.epmc_citation(pmcid)
    except lit.UpstreamError as e:
        citation = f"{pmcid} (citation unavailable: {e})"
    if not section:
        titles = "\n".join(f"  - {t} ({len(x)} chars)" for t, x in secs)
        abstract = next((x for t, x in secs if t == "Abstract"), "")
        return (f"{citation}\nFull text available. Sections:\n{titles}\n\n"
                f"Call get_fulltext again with section=<title> (or 'all') to read.\n\nAbstract: {abstract[:3000]}")
    if section.lower() == "all":
        text = "\n\n".join(f"## {t}\n{x}" for t, x in secs)
    else:
        matches = [(t, x) for t, x in secs if section.lower() in t.lower()]
        if not matches:
            return f"No section matching {section!r}. Available: " + ", ".join(t for t, _ in secs)
        text = "\n\n".join(f"## {t}\n{x}" for t, x in matches)
    if len(text) > max_chars:
        text = text[:max_chars] + f"\n... truncated at {max_chars} chars; ask for a narrower section."
    return f"{citation}\n" + text


@mcp.tool(annotations=RO)
def read_pdf(path: str, max_chars: int = 20000, pages: str = "") -> str:
    """Extract text from a local PDF (e.g. a paywalled paper downloaded through institutional access).

    Args:
        path: absolute path, or a filename inside the project's pdfs/ folder.
        max_chars: cap on returned characters.
        pages: optional page range like "1-3" (1-based) to read only part of the document.
    """
    if not os.path.isabs(path):
        path = os.path.join(lit.PDF_DIR, path)
    if not os.path.exists(path):
        listing = ", ".join(sorted(os.listdir(lit.PDF_DIR))) if os.path.isdir(lit.PDF_DIR) else "(pdfs/ folder empty)"
        return f"File not found: {path}. Available in pdfs/: {listing}"
    if pages:
        try:
            from pypdf import PdfReader, PdfWriter
            a, _, b = pages.partition("-")
            a, b = int(a), int(b or a)
            reader = PdfReader(path)
            w = PdfWriter()
            for i in range(a - 1, min(b, len(reader.pages))):
                w.add_page(reader.pages[i])
            tmp = path + f".p{a}-{b}.pdf"
            with open(tmp, "wb") as f:
                w.write(f)
            out = lit.pdf_text(tmp, max_chars)
            os.remove(tmp)
            return out
        except Exception as e:  # noqa: BLE001
            return f"ERROR: {e}"
    return lit.pdf_text(path, max_chars)


@mcp.tool(annotations=RO)
def kb_search(query: str, top_k: int = 8, kind: str = "fact") -> str:
    """Search the LOCAL knowledge base built by earlier `ask.py` runs: atomic facts (one sentence each, with exact
    numbers) and full-text paragraphs, each linked to its paper (PMID, journal, quartile) and paragraph number ¶n.
    Use it to reuse evidence already read, or to locate the exact passage behind a claim.

    Args:
        query: natural-language question or keywords (English or Chinese).
        top_k: number of hits (1-30).
        kind: "fact" (default), "paragraph", or "" for both.
    """
    try:
        import knowledge_store as ks
        store = ks.KnowledgeStore()
        hits = store.search(query, top_k=max(1, min(int(top_k), 30)), kind=kind)
        st = store.stats()
        return f"knowledge base: {st['papers']} papers, {st['items']} items (embedder {st.get('embedder')})\n" + ks.format_hits(hits)
    except Exception as e:  # noqa: BLE001
        return f"ERROR: knowledge base unavailable: {e}"


if __name__ == "__main__":
    mcp.run(transport="stdio")
