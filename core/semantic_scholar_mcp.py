#!/usr/bin/env python
"""Semantic Scholar MCP server (stdio) for Codex.

Exposes literature-search tools backed by the Semantic Scholar Graph API
(https://api.semanticscholar.org). Set S2_API_KEY for higher rate limits.
"""
from __future__ import annotations

import logging
import os
import re
import time
import xml.etree.ElementTree as ET
from typing import Any, Optional

import sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "vendor"))

import httpx
from mcp.server.fastmcp import FastMCP
from mcp.types import ToolAnnotations

import journal_rank as jr  # local journal quartile tables (data/journal_ranks/)

BASE = "https://api.semanticscholar.org/graph/v1"
API_KEY = os.environ.get("S2_API_KEY", "").strip()
TIMEOUT = float(os.environ.get("S2_TIMEOUT", "30"))

PAPER_FIELDS = (
    "paperId,title,year,venue,authors,abstract,tldr,citationCount,"
    "influentialCitationCount,externalIds,url,openAccessPdf,publicationTypes,"
    "publicationDate,fieldsOfStudy"
)
SHORT_FIELDS = (
    "paperId,title,year,venue,authors,citationCount,externalIds,tldr,"
    "publicationTypes,openAccessPdf"
)

logging.getLogger("httpx").setLevel(logging.WARNING)

mcp = FastMCP("semantic_scholar")
RO = ToolAnnotations(readOnlyHint=True, destructiveHint=False, idempotentHint=True, openWorldHint=True)

NCBI = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils"
EPMC = "https://www.ebi.ac.uk/europepmc/webservices/rest"
NCBI_KEY = os.environ.get("NCBI_API_KEY", "").strip()


def _headers() -> dict[str, str]:
    h = {"User-Agent": "PICOSGpt-medlit-codex/1.0"}
    if API_KEY:
        h["x-api-key"] = API_KEY
    return h


def _get(path: str, params: dict[str, Any]) -> Any:
    """GET with retry/backoff on 429/5xx."""
    delay = 1.0
    last: Optional[str] = None
    for attempt in range(3):
        try:
            r = httpx.get(BASE + path, params=params, headers=_headers(), timeout=TIMEOUT)
        except httpx.HTTPError as e:
            last = f"network error: {e}"
            time.sleep(delay)
            delay *= 2
            continue
        if r.status_code == 200:
            return r.json()
        if r.status_code in (429, 500, 502, 503, 504):
            last = f"HTTP {r.status_code}"
            time.sleep(delay)
            delay *= 2
            continue
        if r.status_code == 404:
            return {"error": "not found"}
        return {"error": f"HTTP {r.status_code}: {r.text[:300]}"}
    return {"error": f"gave up after retries ({last}). Semantic Scholar rate limit - wait and retry."}


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


def _pmcid_to_pmid(pmcid: str) -> str:
    """Map a PMC id (e.g. PMC9306514) to its PMID via Europe PMC; '' if unknown."""
    try:
        r = httpx.get(f"{EPMC}/search", params={"query": f"PMCID:{pmcid}", "format": "json", "resultType": "lite"},
                      timeout=TIMEOUT)
        res = (r.json().get("resultList") or {}).get("result") or []
        return (res[0].get("pmid") or "") if res else ""
    except Exception:  # noqa: BLE001
        return ""


def _norm_s2_id(paper_id: str) -> str:
    """Normalise user-supplied ids into Semantic Scholar lookup format."""
    pid = paper_id.strip()
    up = pid.upper()
    if up.startswith("PMCID:"):
        pid, up = pid[6:], up[6:]
    if up.startswith("PMC") and up[3:].isdigit():
        pmid = _pmcid_to_pmid(up)
        return f"PMID:{pmid}" if pmid else pid
    if pid.isdigit():
        return f"PMID:{pid}"
    if pid.startswith("10."):
        return f"DOI:{pid}"
    return pid


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
    params: dict[str, Any] = {"query": query, "limit": max(1, min(int(limit) * (3 if zones else 1), 50)), "fields": SHORT_FIELDS}
    if year:
        params["year"] = year
    if publication_types:
        params["publicationTypes"] = publication_types
    if open_access_only:
        params["openAccessPdf"] = ""
    if fields_of_study:
        params["fieldsOfStudy"] = fields_of_study
    data = _get("/paper/search", params)
    if "error" in data:
        fb = pubmed_search(query, limit=limit, year=year, quartile=quartile)
        return f"Semantic Scholar unavailable ({data['error']}); fell back to PubMed.\n" + fb
    items = data.get("data") or []
    if zones:
        items = [p for p in items if jr.passes(jr.lookup(title=p.get("venue") or ""), zones)][:int(limit)]
    if not items:
        return f"No results for query: {query!r} (total={data.get('total', 0)}). Try broader/English terms."
    head = f"{data.get('total', len(items))} total matches; showing {len(items)} for {query!r}\n"
    return head + "\n\n".join(_fmt_short(i + 1, p) for i, p in enumerate(items))


@mcp.tool(annotations=RO)
def get_paper(paper_id: str) -> str:
    """Get full details (abstract, venue, IDs, citation counts) for one paper.

    Args:
        paper_id: Semantic Scholar paperId, or "DOI:10.xxx/..", "PMID:12345", "PMC1234567", "ARXIV:2101.00001".
    Returns abstract only. For the full text of an open-access paper use get_fulltext.
    """
    paper_id = _norm_s2_id(paper_id)
    data = _get(f"/paper/{paper_id}", {"fields": PAPER_FIELDS})
    if "error" in data:
        if paper_id.upper().startswith("PMID:"):
            return "Semantic Scholar unavailable; PubMed record instead.\n" + pubmed_fetch(paper_id[5:])
        return f"ERROR: {data['error']} (tip: if you have a PMID use pubmed_fetch)"
    return _fmt_full(data)


@mcp.tool(annotations=RO)
def get_citations(paper_id: str, limit: int = 10) -> str:
    """List papers that CITE the given paper (newer follow-up work), most influential first."""
    data = _get(
        f"/paper/{paper_id}/citations",
        {"fields": "isInfluential," + SHORT_FIELDS.replace("paperId", "paperId"), "limit": max(1, min(int(limit), 50))},
    )
    if "error" in data:
        return f"ERROR: {data['error']}"
    items = [d.get("citingPaper", {}) for d in (data.get("data") or [])]
    if not items:
        return "No citations found."
    return "\n\n".join(_fmt_short(i + 1, p) for i, p in enumerate(items))


@mcp.tool(annotations=RO)
def get_references(paper_id: str, limit: int = 10) -> str:
    """List papers the given paper CITES (its bibliography / background work)."""
    data = _get(
        f"/paper/{paper_id}/references",
        {"fields": SHORT_FIELDS, "limit": max(1, min(int(limit), 50))},
    )
    if "error" in data:
        return f"ERROR: {data['error']}"
    items = [d.get("citedPaper", {}) for d in (data.get("data") or [])]
    items = [p for p in items if p and p.get("paperId")]
    if not items:
        return "No references found."
    return "\n\n".join(_fmt_short(i + 1, p) for i, p in enumerate(items))


@mcp.tool(annotations=RO)
def get_recommendations(paper_id: str, limit: int = 10) -> str:
    """Get papers similar to the given one (Semantic Scholar recommendations)."""
    url = f"https://api.semanticscholar.org/recommendations/v1/papers/forpaper/{paper_id}"
    delay = 1.5
    for _ in range(4):
        try:
            r = httpx.get(url, params={"fields": SHORT_FIELDS, "limit": max(1, min(int(limit), 50))},
                          headers=_headers(), timeout=TIMEOUT)
        except httpx.HTTPError as e:
            time.sleep(delay); delay *= 2; continue
        if r.status_code == 200:
            items = r.json().get("recommendedPapers") or []
            if not items:
                return "No recommendations."
            return "\n\n".join(_fmt_short(i + 1, p) for i, p in enumerate(items))
        if r.status_code in (429, 500, 502, 503):
            time.sleep(delay); delay *= 2; continue
        return f"ERROR: HTTP {r.status_code}: {r.text[:200]}"
    return "ERROR: rate limited, retry later."


# ---------------------------------------------------------------- PubMed fallback
def _ncbi(path: str, params: dict[str, Any]) -> Optional[httpx.Response]:
    if NCBI_KEY:
        params = {**params, "api_key": NCBI_KEY}
    params = {**params, "tool": "PICOSGpt-medlit-codex", "email": "picosgpt@example.com"}
    delay = 1.0
    for _ in range(3):
        try:
            r = httpx.get(f"{NCBI}/{path}", params=params, timeout=TIMEOUT)
        except httpx.HTTPError:
            time.sleep(delay); delay *= 2; continue
        if r.status_code == 200:
            return r
        if r.status_code in (429, 500, 502, 503):
            time.sleep(delay); delay *= 2; continue
        return None
    return None


def _pubmed_fetch_records(pmids: list[str]) -> list[dict]:
    if not pmids:
        return []
    r = _ncbi("efetch.fcgi", {"db": "pubmed", "id": ",".join(pmids), "retmode": "xml"})
    if r is None:
        return []
    out = []
    root = ET.fromstring(r.text)
    for art in root.findall(".//PubmedArticle"):
        pmid = art.findtext("./MedlineCitation/PMID") or ""
        t_el = art.find(".//ArticleTitle")
        title = "".join(t_el.itertext()).strip() if t_el is not None else ""
        abs_parts = []
        for ab in art.findall(".//Abstract/AbstractText"):
            label = ab.get("Label")
            txt = "".join(ab.itertext()).strip()
            abs_parts.append(f"{label}: {txt}" if label else txt)
        journal = art.findtext(".//Journal/Title") or art.findtext(".//MedlineTA") or ""
        year = art.findtext(".//JournalIssue/PubDate/Year") or art.findtext(".//PubDate/MedlineDate") or ""
        authors = []
        for a in art.findall(".//AuthorList/Author"):
            ln, ini = a.findtext("LastName"), a.findtext("Initials")
            if ln:
                authors.append(f"{ln} {ini or ''}".strip())
            elif a.findtext("CollectiveName"):
                authors.append(a.findtext("CollectiveName").strip())
        # only the article's own ids (./PubmedData/ArticleIdList), NOT ids inside its reference list
        doi, pmc = "", ""
        for aid in art.findall("./PubmedData/ArticleIdList/ArticleId"):
            if aid.get("IdType") == "doi" and not doi:
                doi = (aid.text or "").strip()
            elif aid.get("IdType") == "pmc" and not pmc:
                pmc = (aid.text or "").strip()
        if not doi:
            for eid in art.findall(".//Article/ELocationID"):
                if eid.get("EIdType") == "doi":
                    doi = (eid.text or "").strip()
        ptypes = [pt.text for pt in art.findall(".//PublicationTypeList/PublicationType") if pt.text]
        issn = "; ".join(x for x in [art.findtext(".//Journal/ISSN") or "", art.findtext(".//MedlineJournalInfo/ISSNLinking") or ""] if x)
        out.append({"pmid": pmid, "title": title, "abstract": "\n".join(abs_parts), "journal": journal, "issn": issn,
                    "year": year[:4], "authors": authors, "doi": doi, "pmc": pmc, "types": ptypes})
    return out


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
    term = query
    if not year and last_years:
        import datetime as _dt
        y1 = _dt.date.today().year
        year = f"{y1 - int(last_years) + 1}-{y1}"
    zones = jr.parse_quartile_arg(quartile)
    jwords = [j.strip().lower() for j in journal.split(",") if j.strip()]
    if zones or jwords:
        limit = min(int(limit) * 4, 100)   # post-filtering needs a bigger pool
    if publication_types:
        pts = " OR ".join(f'"{t.strip()}"[Publication Type]' for t in publication_types.split(",") if t.strip())
        term = f"({term}) AND ({pts})"
    params: dict[str, Any] = {"db": "pubmed", "term": term, "retmax": max(1, min(int(limit), 100)),
                              "sort": "relevance", "retmode": "json"}
    if year:
        y = year.replace("-", ":") if "-" in year else f"{year}:{year}"
        params["mindate"], params["maxdate"] = y.split(":")
        params["datetype"] = "pdat"
    r = _ncbi("esearch.fcgi", params)
    if r is None:
        return "ERROR: PubMed search failed (network/rate limit). Retry shortly."
    js = r.json().get("esearchresult", {})
    ids = js.get("idlist") or []
    if not ids:
        return f"No PubMed results for {term!r}. Try broader terms or drop filters."
    recs = _pubmed_fetch_records(ids)
    note = ""
    if zones or jwords:
        n0 = len(recs)
        if jwords:
            recs = [p for p in recs if any(w in p["journal"].lower() for w in jwords)]
        if zones:
            recs = [p for p in recs if jr.passes(jr.lookup(issn=p.get("issn", ""), title=p["journal"]), zones)]
        note = f" (filters quartile={quartile!r} journal={journal!r}: {len(recs)}/{n0} kept)"
        if not recs:
            return f"No PubMed results after filtering{note}. Relax the quartile/journal filter."
    head = f"PubMed: {js.get('count')} total matches; showing {len(recs)} for {term!r}{note}\n"
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
            mapped = _pmcid_to_pmid(x.upper())
            if not mapped:
                return f"{x} is a PMC id, not a PMID, and could not be mapped. Use get_fulltext('{x}') instead."
            x = mapped
        ids.append(x)
    recs = _pubmed_fetch_records(ids[:20])
    if not recs:
        return "No records found (check PMIDs) or PubMed unreachable."
    return "\n\n".join(_fmt_pubmed(i + 1, p, with_abstract=True) for i, p in enumerate(recs))


# ---------------------------------------------------------------- full text
PDF_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "pdfs")


def _resolve_pmcid(ident: str) -> tuple[str, str]:
    """Return (pmcid, note) for a PMID / PMCID / DOI / S2 paperId via Europe PMC search."""
    ident = ident.strip()
    up = ident.upper()
    if up.startswith("PMCID:"):
        ident, up = ident[6:], up[6:]
    if up.startswith("PMC") and up[3:].isdigit():
        return up, ""
    if up.startswith("PMID:"):
        q = f"EXT_ID:{ident[5:]} AND SRC:MED"
    elif ident.isdigit():
        q = f"EXT_ID:{ident} AND SRC:MED"
    elif up.startswith("DOI:"):
        q = f'DOI:"{ident[4:]}"'
    elif ident.startswith("10."):
        q = f'DOI:"{ident}"'
    else:
        # Semantic Scholar id -> look up its DOI/PMID first
        data = _get(f"/paper/{ident}", {"fields": "externalIds"})
        ext = (data or {}).get("externalIds") or {}
        if ext.get("PubMedCentral"):
            return "PMC" + str(ext["PubMedCentral"]).replace("PMC", ""), ""
        if ext.get("PubMed"):
            q = f"EXT_ID:{ext['PubMed']} AND SRC:MED"
        elif ext.get("DOI"):
            q = f'DOI:"{ext["DOI"]}"'
        else:
            return "", "could not map id to PubMed/DOI"
    try:
        r = httpx.get(f"{EPMC}/search", params={"query": q, "format": "json", "resultType": "lite"}, timeout=TIMEOUT)
        res = (r.json().get("resultList") or {}).get("result") or []
    except Exception as e:  # noqa: BLE001
        return "", f"Europe PMC lookup failed: {e}"
    if not res:
        return "", "not found in Europe PMC"
    pmcid = res[0].get("pmcid") or ""
    oa = res[0].get("isOpenAccess")
    return pmcid, "" if pmcid else f"no PMC full text (isOpenAccess={oa}); only abstract is available"


def _epmc_citation(pmcid: str) -> str:
    """One-line bibliographic header for a PMC article (title, authors, journal, year, ids)."""
    try:
        r = httpx.get(f"{EPMC}/search", params={"query": f"PMCID:{pmcid}", "format": "json", "resultType": "lite"},
                      timeout=TIMEOUT)
        res = (r.json().get("resultList") or {}).get("result") or []
    except Exception:  # noqa: BLE001
        res = []
    if not res:
        return f"{pmcid}"
    a = res[0]
    return (f"CITATION: {a.get('authorString', '')} ({a.get('pubYear', '')}). {a.get('title', '')} "
            f"{a.get('journalTitle', '')}. PMID:{a.get('pmid', '')} DOI:{a.get('doi', '')} {pmcid}")


def _epmc_fulltext_sections(pmcid: str) -> list[tuple[str, str]]:
    r = httpx.get(f"{EPMC}/{pmcid}/fullTextXML", timeout=TIMEOUT)
    if r.status_code != 200 or not r.text.strip().startswith("<"):
        return []
    root = ET.fromstring(r.text)
    sections: list[tuple[str, str]] = []
    abstract = root.find(".//abstract")
    if abstract is not None:
        sections.append(("Abstract", " ".join(abstract.itertext()).strip()))
    body = root.find(".//body")
    if body is not None:
        for sec in body.findall("./sec"):
            title = " ".join((sec.find("title").itertext() if sec.find("title") is not None else [])).strip() or "Section"
            text = " ".join(t.strip() for t in sec.itertext() if t.strip())
            if sec.find("title") is not None:
                text = text[len(title):].strip() if text.startswith(title) else text
            sections.append((title, text))
        if not sections or len(sections) == 1:
            text = " ".join(t.strip() for t in body.itertext() if t.strip())
            sections.append(("Body", text))
    return sections


def _epmc_fulltext_paragraphs(pmcid: str) -> list[tuple[str, list[str]]]:
    """Like _epmc_fulltext_sections but keeps paragraph boundaries: [(section path, [paragraph, ...])].
    Nested <sec> titles are joined with ' / '; tables/figures captions are included as paragraphs."""
    try:
        r = httpx.get(f"{EPMC}/{pmcid}/fullTextXML", timeout=TIMEOUT)
    except httpx.HTTPError:
        return []
    if r.status_code != 200 or not r.text.strip().startswith("<"):
        return []
    root = ET.fromstring(r.text)
    out: list[tuple[str, list[str]]] = []

    def txt(el: ET.Element) -> str:
        return " ".join(t.strip() for t in el.itertext() if t.strip())

    abstract = root.find(".//abstract")
    if abstract is not None:
        ps = [txt(p) for p in abstract.iter("p")] or [txt(abstract)]
        out.append(("Abstract", [p for p in ps if p]))

    def walk(sec: ET.Element, path: str) -> None:
        t_el = sec.find("title")
        title = txt(t_el) if t_el is not None else "Section"
        full = f"{path} / {title}" if path else title
        paras: list[str] = []
        for child in sec:
            tag = child.tag
            if tag == "p":
                paras.append(txt(child))
            elif tag in ("table-wrap", "fig", "boxed-text", "list", "disp-quote", "supplementary-material"):
                cap = child.find(".//caption")
                lab = child.find("label")
                s = " ".join(x for x in [txt(lab) if lab is not None else "", txt(cap) if cap is not None else ""] if x)
                if tag == "table-wrap" and not s:
                    s = txt(child)[:2000]
                if s:
                    paras.append(s)
        if paras:
            out.append((full, [p for p in paras if p]))
        for sub in sec.findall("sec"):
            walk(sub, full)

    body = root.find(".//body")
    if body is not None:
        secs = body.findall("./sec")
        if secs:
            for sec in secs:
                walk(sec, "")
        else:
            ps = [txt(p) for p in body.iter("p")]
            out.append(("Body", [p for p in ps if p]))
    return out


def _pdf_text(path: str, max_chars: int) -> str:
    try:
        from pypdf import PdfReader
    except ImportError:
        return "ERROR: pypdf not installed (pip install --target vendor pypdf)"
    try:
        reader = PdfReader(path)
    except Exception as e:  # noqa: BLE001
        return f"ERROR: cannot open PDF: {e}"
    out, n = [], 0
    for i, page in enumerate(reader.pages):
        t = page.extract_text() or ""
        t = re.sub(r"[ \t]+", " ", t)
        out.append(f"--- page {i+1} ---\n{t}")
        n += len(t)
        if n >= max_chars:
            out.append(f"... truncated at {max_chars} chars ({len(reader.pages)} pages total)")
            break
    return "\n".join(out)


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
    pmcid, note = _resolve_pmcid(paper_id)
    if not pmcid:
        # try Semantic Scholar open-access PDF as a fallback
        data = _get(f"/paper/{paper_id}", {"fields": "openAccessPdf,title"})
        url = ((data or {}).get("openAccessPdf") or {}).get("url")
        if url:
            os.makedirs(PDF_DIR, exist_ok=True)
            fn = os.path.join(PDF_DIR, re.sub(r"[^A-Za-z0-9]+", "_", paper_id)[:80] + ".pdf")
            try:
                with httpx.stream("GET", url, follow_redirects=True, timeout=60, headers=_headers()) as r:
                    if r.status_code == 200 and "pdf" in r.headers.get("content-type", ""):
                        with open(fn, "wb") as f:
                            for chunk in r.iter_bytes():
                                f.write(chunk)
                        return f"(no PMC version; downloaded open-access PDF {url} -> {fn})\n" + _pdf_text(fn, max_chars)
            except Exception as e:  # noqa: BLE001
                note += f"; OA pdf download failed: {e}"
        return f"Full text not available: {note}. The abstract (get_paper / pubmed_fetch) is the best you can get without institutional access."
    secs = _epmc_fulltext_sections(pmcid)
    if not secs:
        return f"{pmcid} exists but Europe PMC has no XML full text (may be embargoed). Try get_paper for the abstract."
    if not section:
        titles = "\n".join(f"  - {t} ({len(x)} chars)" for t, x in secs)
        abstract = next((x for t, x in secs if t == "Abstract"), "")
        return (f"{_epmc_citation(pmcid)}\nFull text available. Sections:\n{titles}\n\n"
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
    return f"{_epmc_citation(pmcid)}\n" + text


@mcp.tool(annotations=RO)
def read_pdf(path: str, max_chars: int = 20000, pages: str = "") -> str:
    """Extract text from a local PDF (e.g. a paywalled paper downloaded through institutional access).

    Args:
        path: absolute path, or a filename inside the project's pdfs/ folder.
        max_chars: cap on returned characters.
        pages: optional page range like "1-3" (1-based) to read only part of the document.
    """
    if not os.path.isabs(path):
        path = os.path.join(PDF_DIR, path)
    if not os.path.exists(path):
        listing = ", ".join(sorted(os.listdir(PDF_DIR))) if os.path.isdir(PDF_DIR) else "(pdfs/ folder empty)"
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
            out = _pdf_text(tmp, max_chars)
            os.remove(tmp)
            return out
        except Exception as e:  # noqa: BLE001
            return f"ERROR: {e}"
    return _pdf_text(path, max_chars)


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


@mcp.tool(annotations=RO)
def search_authors(name: str, limit: int = 5) -> str:
    """Find authors by name; returns authorId, affiliations, paper/citation counts and h-index."""
    data = _get("/author/search", {"query": name, "limit": max(1, min(int(limit), 20)),
                                   "fields": "authorId,name,affiliations,paperCount,citationCount,hIndex"})
    if "error" in data:
        return f"ERROR: {data['error']}"
    items = data.get("data") or []
    if not items:
        return "No authors found."
    return "\n".join(
        f"[{i+1}] {a.get('name')}  authorId={a.get('authorId')}  aff={'; '.join(a.get('affiliations') or []) or 'n/a'}"
        f"  papers={a.get('paperCount')} citations={a.get('citationCount')} h={a.get('hIndex')}"
        for i, a in enumerate(items)
    )


if __name__ == "__main__":
    mcp.run(transport="stdio")
