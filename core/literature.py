#!/usr/bin/env python
"""结构化文献访问层：Semantic Scholar / PubMed / Europe PMC / 本地 PDF。

这里只负责取数与结构化，不做任何面向人类的字符串拼装——格式化各归其位：
MCP 工具（semantic_scholar_mcp.py）拼文本给模型看，backend 拼 JSON 给前端看。
上游不可用统一抛 `UpstreamError`，而不是把错误塞进返回值里，这样调用方
（MCP 的 PubMed 降级、backend 的 502）才能各自决定怎么处理。
"""
from __future__ import annotations

import logging
import os
import re
import time
import xml.etree.ElementTree as ET
from collections.abc import Iterable
from typing import Any, Optional

import httpx

import journal_rank as jr
from picos_paths import PDF_DIR  # noqa: F401  (对外沿用 literature.PDF_DIR)

S2_BASE = "https://api.semanticscholar.org/graph/v1"
S2_RECOMMEND_BASE = "https://api.semanticscholar.org/recommendations/v1"
NCBI = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils"
EPMC = "https://www.ebi.ac.uk/europepmc/webservices/rest"

S2_API_KEY = os.environ.get("S2_API_KEY", "").strip()
NCBI_API_KEY = os.environ.get("NCBI_API_KEY", "").strip()
TIMEOUT = float(os.environ.get("S2_TIMEOUT", "30"))

CONTACT_TOOL = "PICOSGpt-medlit-codex"
CONTACT_EMAIL = "picosgpt@example.com"

PAPER_FIELDS = (
    "paperId,title,year,venue,authors,abstract,tldr,citationCount,"
    "influentialCitationCount,externalIds,url,openAccessPdf,publicationTypes,"
    "publicationDate,fieldsOfStudy"
)
SHORT_FIELDS = (
    "paperId,title,year,venue,authors,citationCount,externalIds,tldr,"
    "publicationTypes,openAccessPdf"
)
# citations / references / recommendations 端点不接受 tldr（S2 返回 400
# "Unrecognized or unsupported fields: [tldr]"），只有 /paper/{id} 与 /paper/search 支持
RELATED_FIELDS = SHORT_FIELDS.replace("tldr,", "")

logging.getLogger("httpx").setLevel(logging.WARNING)


class UpstreamError(Exception):
    """上游文献服务不可用（限流、网络错误、非预期状态码）。

    `source` 取 {"semantic_scholar", "pubmed", "europepmc"}，供调用方决定降级路径。
    """

    def __init__(self, source: str, detail: str):
        super().__init__(f"{source}: {detail}")
        self.source = source
        self.detail = detail


class UpstreamNotFound(UpstreamError):
    """上游明确返回 404，与暂时不可用分开处理。"""


# ---------------------------------------------------------------- Semantic Scholar
def headers() -> dict[str, str]:
    h = {"User-Agent": "PICOSGpt-medlit-codex/1.0"}
    if S2_API_KEY:
        h["x-api-key"] = S2_API_KEY
    return h


def s2_get(path: str, params: dict[str, Any]) -> dict:
    """GET Semantic Scholar Graph API，429/5xx 指数退避重试 3 次。"""
    delay = 1.0
    last = ""
    for _ in range(3):
        try:
            r = httpx.get(S2_BASE + path, params=params, headers=headers(), timeout=TIMEOUT)
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
            raise UpstreamNotFound("semantic_scholar", "not found")
        raise UpstreamError("semantic_scholar", f"HTTP {r.status_code}: {r.text[:300]}")
    raise UpstreamError("semantic_scholar", f"gave up after retries ({last}); rate limited, retry later")


def norm_s2_id(paper_id: str) -> str:
    """把用户给的各种 id 归一成 Semantic Scholar 查询格式。"""
    pid = paper_id.strip()
    up = pid.upper()
    if up.startswith("PMCID:"):
        pid, up = pid[6:], up[6:]
    if up.startswith("PMC") and up[3:].isdigit():
        pmid = pmcid_to_pmid(up)
        return f"PMID:{pmid}" if pmid else pid
    if pid.isdigit():
        return f"PMID:{pid}"
    if pid.startswith("10."):
        return f"DOI:{pid}"
    return pid


def s2_search(query: str, limit: int, year: str = "", publication_types: str = "",
              open_access_only: bool = False, fields_of_study: str = "Medicine",
              zones: Iterable[int] = frozenset()) -> tuple[int, list[dict]]:
    """关键词检索，返回 (上游命中总数, 原始 S2 记录)。分区过滤只能在本地做，故先多取 3 倍。"""
    zones = set(zones)
    params: dict[str, Any] = {"query": query,
                              "limit": max(1, min(int(limit) * (3 if zones else 1), 50)),
                              "fields": SHORT_FIELDS}
    if year:
        params["year"] = year
    if publication_types:
        params["publicationTypes"] = publication_types
    if open_access_only:
        params["openAccessPdf"] = ""
    if fields_of_study:
        params["fieldsOfStudy"] = fields_of_study
    data = s2_get("/paper/search", params)
    items = data.get("data") or []
    if zones:
        items = [p for p in items if jr.passes(jr.lookup(title=p.get("venue") or ""), zones)][:int(limit)]
    return int(data.get("total", len(items)) or 0), items


def s2_paper(paper_id: str) -> dict:
    return s2_get(f"/paper/{paper_id}", {"fields": PAPER_FIELDS})


def s2_citations(paper_id: str, limit: int = 10) -> list[dict]:
    data = s2_get(f"/paper/{paper_id}/citations",
                  {"fields": "isInfluential," + RELATED_FIELDS, "limit": max(1, min(int(limit), 50))})
    return [d.get("citingPaper") or {} for d in (data.get("data") or [])]


def s2_references(paper_id: str, limit: int = 10) -> list[dict]:
    data = s2_get(f"/paper/{paper_id}/references",
                  {"fields": RELATED_FIELDS, "limit": max(1, min(int(limit), 50))})
    items = [d.get("citedPaper") or {} for d in (data.get("data") or [])]
    return [p for p in items if p.get("paperId")]


def s2_recommendations(paper_id: str, limit: int = 10) -> list[dict]:
    """推荐接口不在 graph/v1 下，且限流更狠，单独一套重试。"""
    url = f"{S2_RECOMMEND_BASE}/papers/forpaper/{paper_id}"
    delay = 1.5
    last = ""
    for _ in range(4):
        try:
            r = httpx.get(url, params={"fields": RELATED_FIELDS, "limit": max(1, min(int(limit), 50))},
                          headers=headers(), timeout=TIMEOUT)
        except httpx.HTTPError as e:
            last = f"network error: {e}"
            time.sleep(delay)
            delay *= 2
            continue
        if r.status_code == 200:
            return r.json().get("recommendedPapers") or []
        if r.status_code in (429, 500, 502, 503):
            last = f"HTTP {r.status_code}"
            time.sleep(delay)
            delay *= 2
            continue
        if r.status_code == 404:
            raise UpstreamNotFound("semantic_scholar", "not found")
        raise UpstreamError("semantic_scholar", f"HTTP {r.status_code}: {r.text[:200]}")
    raise UpstreamError("semantic_scholar", f"gave up after retries ({last}); rate limited, retry later")


def s2_authors(name: str, limit: int = 5) -> list[dict]:
    data = s2_get("/author/search", {"query": name, "limit": max(1, min(int(limit), 20)),
                                     "fields": "authorId,name,affiliations,paperCount,citationCount,hIndex"})
    return data.get("data") or []


# ---------------------------------------------------------------- PubMed (NCBI E-utilities)
def _get_optional(source: str, url: str, params: dict[str, Any]) -> Optional[httpx.Response]:
    """仅真实 404 返回 None；暂时故障重试后保留异常语义。"""
    delay = 1.0
    last = ""
    for attempt in range(3):
        try:
            r = httpx.get(url, params=params, timeout=TIMEOUT)
        except httpx.HTTPError as exc:
            last = f"network error: {exc}"
        else:
            if r.status_code == 200:
                return r
            if r.status_code == 404:
                return None
            last = f"HTTP {r.status_code}"
            if r.status_code != 429 and not 500 <= r.status_code < 600:
                raise UpstreamError(source, last)
        if attempt < 2:
            time.sleep(delay)
            delay *= 2
    raise UpstreamError(source, f"gave up after retries ({last})")


def ncbi_get(path: str, params: dict[str, Any]) -> Optional[httpx.Response]:
    """成功返回 Response，404 返回 None，服务故障抛 UpstreamError。"""
    if NCBI_API_KEY:
        params = {**params, "api_key": NCBI_API_KEY}
    params = {**params, "tool": CONTACT_TOOL, "email": CONTACT_EMAIL}
    return _get_optional("pubmed", f"{NCBI}/{path}", params)


def pubmed_fetch_records(pmids: list[str]) -> list[dict]:
    """efetch 一批 PMID -> [{pmid,title,abstract,journal,issn,year,authors,doi,pmc,types}]。"""
    if not pmids:
        return []
    r = ncbi_get("efetch.fcgi", {"db": "pubmed", "id": ",".join(pmids), "retmode": "xml"})
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
        issn = "; ".join(x for x in [art.findtext(".//Journal/ISSN") or "",
                                     art.findtext(".//MedlineJournalInfo/ISSNLinking") or ""] if x)
        out.append({"pmid": pmid, "title": title, "abstract": "\n".join(abs_parts), "journal": journal, "issn": issn,
                    "year": year[:4], "authors": authors, "doi": doi, "pmc": pmc, "types": ptypes})
    return out


def pubmed_search_records(query: str, limit: int = 10, year_from: int = 0, year_to: int = 0,
                          publication_types: Iterable[str] = (), zones: Iterable[int] = frozenset(),
                          journals: Iterable[str] = ()) -> tuple[int, list[dict]]:
    """PubMed 检索，返回 (上游命中总数, 记录)。分区/刊名过滤只能本地做，故先多取 4 倍。"""
    zones, jwords = set(zones), [j.strip().lower() for j in journals if j.strip()]
    ptypes = [t.strip() for t in publication_types if t.strip()]
    term = query
    if ptypes:
        term = f"({term}) AND (" + " OR ".join(f'"{t}"[Publication Type]' for t in ptypes) + ")"
    limit = max(1, min(int(limit), 100))
    fetch_limit = min(limit * 4, 100) if zones or jwords else limit
    params: dict[str, Any] = {"db": "pubmed", "term": term, "retmax": fetch_limit,
                              "sort": "relevance", "retmode": "json"}
    if year_from:
        params["mindate"] = str(year_from)
        params["maxdate"] = str(year_to or year_from)
        params["datetype"] = "pdat"
    r = ncbi_get("esearch.fcgi", params)
    if r is None:
        return 0, []
    js = r.json().get("esearchresult", {})
    ids = js.get("idlist") or []
    total = int(js.get("count") or 0)
    if not ids:
        return total, []
    recs = pubmed_fetch_records(ids)
    if jwords:
        recs = [p for p in recs if any(w in p["journal"].lower() for w in jwords)]
    if zones:
        recs = [p for p in recs if jr.passes(jr.lookup(issn=p.get("issn", ""), title=p["journal"]), zones)]
    return total, recs[:limit]


# ---------------------------------------------------------------- Europe PMC
def _epmc_results(query: str) -> list[dict]:
    r = _get_optional("europepmc", f"{EPMC}/search",
                      {"query": query, "format": "json", "resultType": "lite"})
    if r is None:
        return []
    try:
        return (r.json().get("resultList") or {}).get("result") or []
    except ValueError as exc:
        raise UpstreamError("europepmc", "invalid JSON response") from exc


def _epmc_fulltext(pmcid: str) -> Optional[ET.Element]:
    r = _get_optional("europepmc", f"{EPMC}/{pmcid}/fullTextXML", {})
    if r is None:
        return None
    try:
        return ET.fromstring(r.text)
    except ET.ParseError as exc:
        raise UpstreamError("europepmc", "invalid XML response") from exc


def pmcid_to_pmid(pmcid: str) -> str:
    """PMC id（如 PMC9306514）-> PMID；映射不到返回 ''。"""
    res = _epmc_results(f"PMCID:{pmcid}")
    return (res[0].get("pmid") or "") if res else ""


def resolve_pmcid(ident: str) -> tuple[str, str]:
    """PMID / PMCID / DOI / S2 paperId -> (pmcid, note)；拿不到全文时 note 说明原因。"""
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
        # Semantic Scholar id -> 先查它的 DOI/PMID
        try:
            ext = (s2_get(f"/paper/{ident}", {"fields": "externalIds"}) or {}).get("externalIds") or {}
        except UpstreamNotFound:
            ext = {}
        if ext.get("PubMedCentral"):
            return "PMC" + str(ext["PubMedCentral"]).replace("PMC", ""), ""
        if ext.get("PubMed"):
            q = f"EXT_ID:{ext['PubMed']} AND SRC:MED"
        elif ext.get("DOI"):
            q = f'DOI:"{ext["DOI"]}"'
        else:
            return "", "could not map id to PubMed/DOI"
    res = _epmc_results(q)
    if not res:
        return "", "not found in Europe PMC"
    pmcid = res[0].get("pmcid") or ""
    oa = res[0].get("isOpenAccess")
    return pmcid, "" if pmcid else f"no PMC full text (isOpenAccess={oa}); only abstract is available"


def epmc_citation(pmcid: str) -> str:
    """PMC 文章的一行书目信息（标题、作者、期刊、年份、各种 id）。"""
    res = _epmc_results(f"PMCID:{pmcid}")
    if not res:
        return f"{pmcid}"
    a = res[0]
    return (f"CITATION: {a.get('authorString', '')} ({a.get('pubYear', '')}). {a.get('title', '')} "
            f"{a.get('journalTitle', '')}. PMID:{a.get('pmid', '')} DOI:{a.get('doi', '')} {pmcid}")


def epmc_fulltext_sections(pmcid: str) -> list[tuple[str, str]]:
    """[(章节标题, 整段文本)]；没有 XML 全文时返回 []。"""
    root = _epmc_fulltext(pmcid)
    if root is None:
        return []
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


def epmc_fulltext_paragraphs(pmcid: str) -> list[tuple[str, list[str]]]:
    """同 epmc_fulltext_sections，但保留段落边界：[(章节路径, [段落, ...])]。
    嵌套 <sec> 标题用 ' / ' 连接；表格/图注也算段落。"""
    root = _epmc_fulltext(pmcid)
    if root is None:
        return []
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


# ---------------------------------------------------------------- local PDF
def pdf_text(path: str, max_chars: int) -> str:
    """按页抽取本地 PDF 文本；失败时返回以 'ERROR' 开头的说明（调用方按前缀判断）。"""
    try:
        from pypdf import PdfReader
    except ImportError:
        return "ERROR: pypdf not installed (pip install pypdf)"
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
