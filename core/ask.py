#!/usr/bin/env python
"""Question -> literature search -> full-text download -> per-paper reading -> cited answer.

Usage:
    python ask.py "SGLT2抑制剂对HFpEF患者有什么获益？"
    python ask.py --years 3 --quartile Q1,Q2 "..."          # last 3 years, SCImago Q1/Q2 journals only
    python ask.py --year 2018-2023 --zone 1-3 "..."          # custom year range, 一区~三区
    python ask.py --journal "Nature,Lancet,JAMA" "..."       # journal-family filter (e.g. Nature 子刊)
    python ask.py --papers 8 --no-kb "..."                   # skip atomic-fact extraction / vector indexing
Outputs:
    answers/<ts>.md              answer with [n] / [n¶k] citations + "原文定位" appendix
    answers/<ts>_papers/         per paper: <pmid>.md (anchored full text), _notes.md, _facts.json, _citations.json
    library/<pmid>/              persistent copy (fulltext.md, paragraphs.json, facts.json, meta.json)
    kb/                          vector store of atomic facts + paragraphs (python knowledge_store.py search "...")
"""
from __future__ import annotations

import argparse
import concurrent.futures as cf
import datetime as dt
import json
import os
import re
import time

import httpx

import journal_rank as jr
import knowledge_store as ks
import picos_paths
import literature as lit
from picos_paths import ANSWERS_DIR

try:
    import paywall_fetch  # noqa: E402  institutional-access downloader (SPIDER_PROJECT login state)
except Exception:  # noqa: BLE001  (playwright missing etc.)
    paywall_fetch = None
PAYWALL_STATE = os.environ.get("SD_STATE_PATH") or os.path.join(picos_paths.DATA_ROOT, "sd_state.json")
PAYWALL_MAX = int(os.environ.get("PAYWALL_MAX_PER_RUN", "5"))

LLM_BASE = os.environ.get("LLM_BASE", "http://127.0.0.1:4000/v1")
LLM_KEY = os.environ.get("LOCAL_QWEN_KEY", "sk-123456")
LLM_MODEL = os.environ.get("LLM_MODEL", "qwen3-14b")
UNPAYWALL_EMAIL = os.environ.get("UNPAYWALL_EMAIL", "picosgpt@example.com")


def log(msg: str) -> None:
    print(f"[{dt.datetime.now():%H:%M:%S}] {msg}", flush=True)


# ------------------------------------------------------------------ LLM
def llm(system: str, user: str, max_tokens: int = 2000, think: bool = False, temperature: float = 0.2) -> str:
    body = {
        "model": LLM_MODEL,
        "messages": [{"role": "system", "content": system}, {"role": "user", "content": user}],
        "max_tokens": max_tokens,
        "temperature": temperature,
        "chat_template_kwargs": {"enable_thinking": think},
    }
    for attempt in range(3):
        try:
            r = httpx.post(f"{LLM_BASE}/chat/completions", json=body,
                           headers={"Authorization": f"Bearer {LLM_KEY}"}, timeout=600)
            r.raise_for_status()
            txt = r.json()["choices"][0]["message"]["content"] or ""
            return re.sub(r"<think>.*?</think>", "", txt, flags=re.S).strip()
        except Exception as e:  # noqa: BLE001
            log(f"LLM error ({e}); retry {attempt+1}")
            time.sleep(3)
    return ""


# ------------------------------------------------------------------ filters
class Filters:
    """Year range / journal quartile / journal-name filters (Google-Scholar-like)."""

    def __init__(self, years: int = 0, year: str = "", quartile: str = "", journal: str = "", keep_unranked: bool = False):
        self.y0 = self.y1 = 0
        now = dt.date.today().year
        if year:
            m = re.fullmatch(r"\s*(\d{4})\s*(?:[-~至:]\s*(\d{4}))?\s*", year)
            if not m:
                raise SystemExit(f"--year must be YYYY or YYYY-YYYY, got {year!r}")
            self.y0, self.y1 = int(m.group(1)), int(m.group(2) or m.group(1))
        elif years:
            self.y0, self.y1 = now - years + 1, now
        self.zones = jr.parse_quartile_arg(quartile)
        self.journals = [j.strip().lower() for j in re.split(r"[,，;]", journal) if j.strip()]
        self.keep_unranked = keep_unranked
        self.dropped: dict[str, int] = {"year": 0, "quartile": 0, "unranked": 0, "journal": 0}

    @property
    def active(self) -> bool:
        return bool(self.y0 or self.zones or self.journals)

    def describe(self) -> str:
        parts = []
        if self.y0:
            parts.append(f"年份 {self.y0}-{self.y1}")
        if self.zones:
            parts.append("分区 " + "/".join(f"Q{z}" for z in sorted(self.zones)) + ("（含未收录）" if self.keep_unranked else ""))
        if self.journals:
            parts.append("期刊含 " + "|".join(self.journals))
        return "; ".join(parts) or "无"

    def pubmed_year_params(self) -> dict:
        return {"mindate": str(self.y0), "maxdate": str(self.y1), "datetype": "pdat"} if self.y0 else {}

    def epmc_year_clause(self) -> str:
        return f" AND PUB_YEAR:[{self.y0} TO {self.y1}]" if self.y0 else ""

    def annotate(self, p: dict) -> None:
        info = jr.lookup(issn=p.get("issn", ""), title=p.get("journal", ""))
        p["rank"] = info
        p["quartile"] = info["quartile"] if info else ""
        p["zone"] = info["zone"] if info else 0

    def keep(self, p: dict) -> bool:
        if self.y0:
            try:
                y = int(str(p.get("year", ""))[:4])
            except ValueError:
                y = 0
            if not (self.y0 <= y <= self.y1):
                self.dropped["year"] += 1
                return False
        if self.journals and not any(j in (p.get("journal") or "").lower() for j in self.journals):
            self.dropped["journal"] += 1
            return False
        if self.zones:
            if not p.get("rank"):
                if not self.keep_unranked:
                    self.dropped["unranked"] += 1
                    return False
            elif p["zone"] not in self.zones:
                self.dropped["quartile"] += 1
                return False
        return True


# ------------------------------------------------------------------ 1. queries
def make_queries(question: str) -> tuple[list[str], str]:
    sysmsg = ("You are a medical librarian. Convert the user's question into PubMed search queries. "
              "Return ONLY JSON: {\"english_question\": str, \"queries\": [str, str, str]}. "
              "Queries must be English, 3-8 words, use synonyms/MeSH-like terms, no boolean operators, no quotes.")
    out = llm(sysmsg, question, max_tokens=400)
    m = re.search(r"\{.*\}", out, re.S)
    try:
        js = json.loads(m.group(0))
        qs = [q.strip() for q in js.get("queries", []) if q.strip()][:3]
        return qs or [question], js.get("english_question", question)
    except Exception:  # noqa: BLE001
        return [question], question


# ------------------------------------------------------------------ 2. search
def epmc_search(query: str, limit: int, fulltext_only: bool, flt: Filters) -> list[dict]:
    q = query + (" AND HAS_FT:y AND OPEN_ACCESS:y" if fulltext_only else "") + flt.epmc_year_clause()
    try:
        r = httpx.get(f"{lit.EPMC}/search", params={"query": q, "format": "json", "pageSize": limit,
                                                     "resultType": "lite", "sort": "CITED desc"}, timeout=30)
        res = (r.json().get("resultList") or {}).get("result") or []
    except Exception:  # noqa: BLE001
        return []
    out = []
    for a in res:
        if a.get("source") != "MED":
            continue
        out.append({"pmid": a.get("pmid", ""), "pmcid": a.get("pmcid", ""), "doi": a.get("doi", ""),
                    "title": a.get("title", ""), "year": str(a.get("pubYear", "")), "journal": a.get("journalTitle", ""),
                    "issn": a.get("journalIssn", ""),
                    "authors": a.get("authorString", ""), "cited": int(a.get("citedByCount", 0) or 0),
                    "types": [], "abstract": ""})
    return out


def pubmed_search(query: str, limit: int, flt: Filters) -> list[dict]:
    params = {"db": "pubmed", "term": query, "retmax": limit, "sort": "relevance", "retmode": "json", **flt.pubmed_year_params()}
    r = lit.ncbi_get("esearch.fcgi", params)
    if r is None:
        return []
    ids = r.json().get("esearchresult", {}).get("idlist") or []
    recs = lit.pubmed_fetch_records(ids)
    return [{"pmid": p["pmid"], "pmcid": p["pmc"], "doi": p["doi"], "title": p["title"], "year": p["year"],
             "journal": p["journal"], "issn": p.get("issn", ""),
             "authors": ", ".join(p["authors"][:3]) + (" et al." if len(p["authors"]) > 3 else ""),
             "cited": 0, "types": p["types"], "abstract": p["abstract"]} for p in recs]


def rank_key(p: dict) -> tuple:
    t = " ".join(p.get("types", [])).lower()
    quality = 3 if "meta-analysis" in t or "systematic review" in t else 2 if "randomized" in t else 1 if "review" in t or "guideline" in t else 0
    zone_bonus = (5 - p["zone"]) if p.get("zone") else 0   # Q1 -> 4 ... Q4 -> 1, unknown -> 0
    return (quality, zone_bonus, 1 if p.get("pmcid") else 0, p.get("cited", 0), p.get("year", ""))


def search_all(queries: list[str], n_papers: int, flt: Filters) -> list[dict]:
    seen: dict[str, dict] = {}
    # a filter shrinks the pool, so fetch a bigger candidate set first
    n_pm, n_ep = (30, 25) if flt.active else (10, 8)
    for q in queries:
        for rec in pubmed_search(q, n_pm, flt) + epmc_search(q, n_ep, True, flt):
            key = rec["pmid"] or rec["doi"] or rec["title"]
            if key and key not in seen:
                seen[key] = rec
            elif key:
                cur = seen[key]
                for k in ("pmcid", "doi", "abstract", "types", "issn"):
                    if not cur.get(k) and rec.get(k):
                        cur[k] = rec[k]
                cur["cited"] = max(cur.get("cited", 0), rec.get("cited", 0))
    cands = list(seen.values())
    for p in cands:
        flt.annotate(p)
    kept = [p for p in cands if flt.keep(p)]
    log(f"candidates: {len(cands)} found, {len(kept)} pass filters "
        f"(dropped: " + ", ".join(f"{k} {v}" for k, v in flt.dropped.items() if v) + ")" if flt.active else f"candidates: {len(cands)}")
    papers = sorted(kept, key=rank_key, reverse=True)
    return papers[:n_papers]


# ------------------------------------------------------------------ 3. full text
def unpaywall_pdf(doi: str) -> str:
    if not doi:
        return ""
    try:
        r = httpx.get(f"https://api.unpaywall.org/v2/{doi}", params={"email": UNPAYWALL_EMAIL}, timeout=20)
        if r.status_code == 200:
            loc = r.json().get("best_oa_location") or {}
            return loc.get("url_for_pdf") or ""
    except Exception:  # noqa: BLE001
        pass
    return ""


SKIP_SECS = ("references", "associated data", "supporting information", "supplementary material", "acknowledgements",
             "acknowledgments", "funding", "conflict of interest", "competing interests", "author contributions")


def fetch_fulltext(p: dict, outdir: str, max_chars: int) -> dict:
    """Fill p['paras'] (numbered paragraphs), p['text'] (model-facing numbered text) and p['source']."""
    pmid = p["pmid"]
    paras: list[dict] = []
    source = "abstract"
    if p.get("pmcid"):
        secs = lit.epmc_fulltext_paragraphs(p["pmcid"])
        if secs:
            keep = [(t, ps) for t, ps in secs if not any(t.lower().startswith(s) for s in SKIP_SECS)]
            paras = ks.paragraphs_from_sections(keep)
            source = "pmc" if paras else "abstract"
    if not paras:
        url = unpaywall_pdf(p.get("doi", ""))
        if url:
            fn = os.path.join(outdir, f"{pmid or 'paper'}.pdf")
            try:
                with httpx.stream("GET", url, follow_redirects=True, timeout=60,
                                  headers={"User-Agent": "Mozilla/5.0 PICOSGpt-medlit"}) as r:
                    if r.status_code == 200 and "pdf" in r.headers.get("content-type", "").lower():
                        with open(fn, "wb") as f:
                            for chunk in r.iter_bytes():
                                f.write(chunk)
                        t = lit.pdf_text(fn, max_chars * 2)
                        if not t.startswith("ERROR"):
                            paras = ks.paragraphs_from_pdf_text(t)
                            source = "pdf" if paras else "abstract"
            except Exception:  # noqa: BLE001
                pass
    if not paras and p.get("doi") and paywall_fetch and os.path.exists(PAYWALL_STATE) and p.get("_paywall_ok"):
        fn = os.path.join(outdir, f"{pmid or 'paper'}.pdf")
        ok, note = paywall_fetch.download_pdf(p["doi"], fn, PAYWALL_STATE)
        log(f"  institutional {'OK ' if ok else 'no '} DOI:{p['doi']} — {note}")
        if ok:
            t = lit.pdf_text(fn, max_chars * 2)
            if not t.startswith("ERROR") and len(t) > 2000:
                paras = ks.paragraphs_from_pdf_text(t)
                source = "inst" if paras else "abstract"
    if not paras:
        if not p.get("abstract") and pmid:
            recs = lit.pubmed_fetch_records([pmid])
            if recs:
                p["abstract"] = recs[0]["abstract"]
                p["types"] = recs[0]["types"]
                p["issn"] = p.get("issn") or recs[0].get("issn", "")
        paras = ks.paragraphs_from_abstract(p.get("abstract", ""))
        source = "abstract"
    # cap the model-facing text; keep the full paragraph list for locating / indexing
    text = ks.numbered_text(paras)
    if len(text) > max_chars:
        text = text[:max_chars] + "\n[... truncated: later paragraphs not shown to the reader model ...]"
    p["paras"], p["text"], p["source"] = paras, text, source
    p["md_file"] = f"{pmid or 'paper'}.md"
    header = (f"# {p['title']}\n\n{p['authors']} ({p['year']}) *{p['journal']}* {jr.label(p.get('rank'))}  \n"
              f"PMID:{pmid} DOI:{p.get('doi','')} PMCID:{p.get('pmcid','')}  \nsource: {source} · {len(paras)} paragraphs\n\n")
    p["fulltext_md"] = header + ks.anchored_markdown(paras)
    with open(os.path.join(outdir, p["md_file"]), "w", encoding="utf-8") as f:
        f.write(p["fulltext_md"])
    return p


# ------------------------------------------------------------------ 4. read
READ_SYS = """You are a meticulous clinical research analyst. You will be given ONE paper (full text or abstract,
already converted to plain text; every paragraph is prefixed with a number like [¶12]) and a research question.
Extract ONLY what the paper itself reports.
Return Markdown with EXACTLY these headings, following the PICOS framework:
### Relevance (0-3)
### P — Patient / 研究对象  (population, disease/condition, inclusion & exclusion criteria, age/sex, setting, sample size n per arm)
### I — Intervention / 干预措施  (drug/procedure/exposure, dose, frequency, route, duration)
### C — Comparator / 对照方式  (placebo / standard care / active control / no treatment; dose & duration)
### O — Outcome / 结局指标  (primary and secondary outcomes with exact numbers: HR/RR/OR with 95% CI, p values,
    absolute event rates, mean differences; follow-up time; adverse events)
### S — Study design / 研究设计  (RCT / meta-analysis / cohort / case-control / cross-sectional / review; blinding,
    randomization, number of centres, registration, follow-up duration)
### Key findings relevant to the question
    Bullets. EVERY bullet must end with its source location in this exact form:  (¶12: "8-20 verbatim words copied from that paragraph")
    Use the paragraph number shown in the text; quote must be copied exactly, no paraphrase.
### Limitations stated by the authors  (each bullet also ends with (¶n: "verbatim quote"))
Rules: never add information that is not in the text; write "Not reported" for any PICOS item the paper does not state;
if the paper is not relevant say Relevance 0 and stop."""


def read_paper(i: int, p: dict, question_en: str) -> dict:
    if not p.get("text"):
        p["notes"] = "### Relevance (0-3)\n0 (no text available)"
        p["cites"] = []
        return p
    user = f"QUESTION: {question_en}\n\nPAPER [{i}] {p['title']} ({p['year']}, {p['journal']}) — source: {p['source']}\n\n{p['text']}"
    p["notes"] = llm(READ_SYS, user, max_tokens=2000)
    m = re.search(r"Relevance.*?(\d)", p["notes"], re.S)
    p["relevance"] = int(m.group(1)) if m else 1
    p["cites"] = ks.verify_citations(p["notes"], p["paras"])
    # rewrite the notes so the synthesis model sees corrected/verified paragraph ids: (¶12: "...") -> [n¶12]
    def _fix(m: re.Match) -> str:
        claimed, quote = int(m.group(1)), m.group(2).strip()
        c = next((c for c in p["cites"] if c["claimed_pid"] == claimed and c["quote"] == quote), None)
        if c and c["verified"]:
            return f'[{i}¶{c["pid"]}]'
        return f"[{i}¶{claimed}?]"
    p["notes_for_synthesis"] = ks.CITE_RE.sub(_fix, p["notes"])
    return p


# ------------------------------------------------------------------ 5. synthesize
SYN_SYS = """You are a medical literature assistant writing an evidence summary for a clinician-researcher.
You are given PICOS reading notes for several papers, each labelled [n]. Inside the notes, markers like [3¶12] mean
"paper 3, paragraph 12" — a verified location in the original text. Write the answer in the SAME LANGUAGE as the
user's question, using ONLY facts from the notes. Cite every factual claim. PREFER the paragraph markers over plain [n]:
whenever the note line you are using carries a marker like [3¶12], cite [3¶12] (copy it exactly as given; never invent
paragraph numbers); use plain [n] only for facts whose note line has no marker. Do not invent numbers, studies or citations; if the notes are insufficient, say what is missing.
Format:
**结论 / Bottom line** — 2-4 sentences.
**证据 / Evidence** — bullets, each with study type, n, effect sizes, ending with [n] or [n¶k].
**PICOS 证据表 / PICOS table** — a Markdown table with columns: [n] | P 研究对象 | I 干预措施 | C 对照方式 | O 结局指标 | S 研究设计.
One row per paper with Relevance >= 1; keep each cell concise (<= 25 words); write "未报告" if not reported.
**局限 / Caveats** — bullets.
Do NOT write the reference list; it will be appended automatically."""


def synthesize(question: str, papers: list[dict]) -> str:
    notes = "\n\n".join(f"[{p['n']}] {p['title']} ({p['year']}) — {p['journal']} {jr.label(p.get('rank'))} — text source: {p['source']}\n"
                        f"{p.get('notes_for_synthesis') or p['notes']}" for p in papers)
    return llm(SYN_SYS, f"USER QUESTION: {question}\n\nREADING NOTES:\n{notes}", max_tokens=2800, think=True)


def _short_authors(a: str) -> str:
    names = [x.strip() for x in a.replace(" et al.", "").split(",") if x.strip()]
    return ", ".join(names[:3]) + (" et al." if len(names) > 3 else "")


def ref_line(p: dict, papers_dir_rel: str) -> str:
    p["authors"] = _short_authors(p["authors"])
    ids = " ".join(x for x in [f"PMID:{p['pmid']}" if p["pmid"] else "", f"DOI:{p['doi']}" if p.get("doi") else "",
                               p.get("pmcid", "")] if x)
    src = {"pmc": "全文(PMC)", "pdf": "全文(OA PDF)", "inst": "全文(机构订阅)", "abstract": "仅摘要"}[p["source"]]
    rank = jr.label(p.get("rank"))
    return (f"[{p['n']}] {p['authors']} ({p['year']}). {p['title']} *{p['journal']}* 〔{rank}〕. {ids} 〔{src}〕 "
            f"[原文]({papers_dir_rel}/{p['md_file']})")


MARK_GROUP_RE = re.compile(r"\[((?:\d{1,2}¶\d{1,4}\??|\d{1,2})(?:\s*[,，;]\s*(?:\d{1,2}¶\d{1,4}\??|\d{1,2}))*)\]")
MARK_RE = re.compile(r"(\d{1,2})¶(\d{1,4})(\??)")


def link_markers(body: str, by_n: dict[int, dict], papers_dir_rel: str) -> tuple[str, list[tuple[int, int]]]:
    """Turn [3¶12] / [3¶26, 3¶29] / [2¶4, 5] into clickable links to paragraph anchors; collect (n, pid) pairs."""
    used: list[tuple[int, int]] = []

    def _one(tok: str) -> str:
        m = MARK_RE.fullmatch(tok)
        if not m:
            return f"[{tok}]"
        n, pid = int(m.group(1)), int(m.group(2))
        p = by_n.get(n)
        if not p or not any(q["id"] == pid for q in p["paras"]):
            return f"[{n}]"  # unknown paragraph: degrade to a plain paper citation
        if (n, pid) not in used:
            used.append((n, pid))
        return f"[{n}¶{pid}]({papers_dir_rel}/{p['md_file']}#p{pid})"

    def _group(m: re.Match) -> str:
        toks = [t.strip() for t in re.split(r"[,，;]", m.group(1)) if t.strip()]
        if not any("¶" in t for t in toks):
            return m.group(0)
        return " ".join(_one(t) for t in toks)
    return MARK_GROUP_RE.sub(_group, body), used


def location_appendix(used: list[tuple[int, int]], by_n: dict[int, dict], papers_dir_rel: str) -> str:
    """'原文定位' section: for every cited paragraph show where it is and the verified quote / paragraph text."""
    lines = ["**原文定位 / Source passages**（点击 ¶ 链接可跳到原文段落；完整核实清单见各篇 `_citations.json`）"]
    by_paper: dict[int, list[int]] = {}
    for n, pid in used:
        by_paper.setdefault(n, [])
        if pid not in by_paper[n]:
            by_paper[n].append(pid)
    # papers cited only as [n]: show the 3 key-finding quotes the reader verified, so every paper is locatable
    for n, p in by_n.items():
        if by_paper.get(n):
            continue
        vc = [c for c in p.get("cites", []) if c["verified"]]
        for c in ([c for c in vc if c.get("key_finding")] + [c for c in vc if not c.get("key_finding")])[:3]:
            if c["pid"] not in by_paper.setdefault(n, []):
                by_paper[n].append(c["pid"])
    for n in sorted(by_paper):
        p = by_n[n]
        paras = {q["id"]: q for q in p["paras"]}
        lines.append(f"\n[{n}] {p['title'][:100]} — {p['journal']} ({p['year']}) 〔{p['source']}〕")
        for pid in sorted(by_paper[n]):
            q = paras.get(pid)
            if not q:
                continue
            quotes = [c["quote"] for c in p.get("cites", []) if c["verified"] and c["pid"] == pid]
            loc = q["sec"] + (f", p.{q['page']}" if q.get("page") else "")
            link = f"{papers_dir_rel}/{p['md_file']}#p{pid}"
            if quotes:
                for qu in quotes[:2]:
                    lines.append(f"- [¶{pid}]({link}) {loc}: “{qu}”")
            else:
                lines.append(f"- [¶{pid}]({link}) {loc}: {q['text'][:220]}{'…' if len(q['text']) > 220 else ''}")
        bad = [c for c in p.get("cites", []) if not c["verified"]]
        if bad:
            lines.append(f"- ⚠ {len(bad)} 条模型引文未能在原文中核实（见 {p['pmid'] or 'paper'}_citations.json）")
    return "\n".join(lines)


# ------------------------------------------------------------------ main
def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("question")
    ap.add_argument("--papers", type=int, default=8, help="max papers to read")
    ap.add_argument("--max-chars", type=int, default=28000, help="max chars of text fed per paper")
    ap.add_argument("--workers", type=int, default=4)
    ap.add_argument("--no-paywall", action="store_true", help="skip institutional-access downloads")
    g = ap.add_argument_group("filters (Google-Scholar-like)")
    g.add_argument("--years", type=int, default=0, help="only papers from the last N years (e.g. 3)")
    g.add_argument("--year", default="", help="custom range YYYY-YYYY or a single YYYY (overrides --years)")
    g.add_argument("--quartile", "--zone", dest="quartile", default="",
                   help="journal quartile / 分区: 'Q1,Q2', '1-3', '一区,二区' (SCImago SJR best quartile; add your own CAS table in data/journal_ranks/)")
    g.add_argument("--journal", default="", help="comma list of journal-name substrings, e.g. 'Nature,Lancet' (matches Nature 子刊 too)")
    g.add_argument("--keep-unranked", action="store_true", help="with --quartile, keep journals absent from the ranking tables")
    k = ap.add_argument_group("knowledge base")
    k.add_argument("--no-kb", action="store_true", help="skip atomic-fact extraction and vector indexing")
    k.add_argument("--kb-hits", type=int, default=0, help="also feed the top-N knowledge-base hits from earlier runs into the synthesis (0 = off)")
    args = ap.parse_args()

    flt = Filters(args.years, args.year, args.quartile, args.journal, args.keep_unranked)
    tables = jr.load()
    if flt.zones and not tables:
        log("WARNING: --quartile given but no ranking table in data/journal_ranks/ (run: python journal_rank.py download)")
    ts = dt.datetime.now().strftime("%Y%m%d_%H%M%S")
    outdir = os.path.join(ANSWERS_DIR, f"{ts}_papers")
    papers_dir_rel = f"{ts}_papers"
    os.makedirs(outdir, exist_ok=True)

    log(f"Q: {args.question}")
    log(f"filters: {flt.describe()}" + (f"   ranking tables: {', '.join(tables)}" if tables else ""))
    queries, q_en = make_queries(args.question)
    log(f"queries: {queries}")

    papers = search_all(queries, args.papers, flt)
    for p in papers:
        log(f"  - {p['title'][:80]} ({p['year']}) {p['journal'][:30]} 〔{jr.label(p.get('rank'))}〕 PMID:{p['pmid']} {'PMC✔' if p.get('pmcid') else ''}")
    if not papers:
        log("no papers pass the filters; relax --years/--quartile/--journal or add --keep-unranked")
        return

    log("downloading full texts (open access) ...")
    with cf.ThreadPoolExecutor(args.workers) as ex:
        papers = list(ex.map(lambda p: fetch_fulltext(p, outdir, args.max_chars), papers))
    if paywall_fetch and os.path.exists(PAYWALL_STATE) and not args.no_paywall:
        todo = [p for p in papers if p["source"] == "abstract" and p.get("doi")][:PAYWALL_MAX]
        if todo:
            log(f"institutional access: trying {len(todo)} paywalled paper(s) serially (polite delay) ...")
            for p in todo:  # serial on purpose: one browser at a time, delay between requests
                p["_paywall_ok"] = True
                fetch_fulltext(p, outdir, args.max_chars)
    elif not args.no_paywall:
        log("institutional access: skipped (no sd_state.json — run paywall_fetch.py login to enable)")
    for p in papers:
        log(f"  {p['source']:8s} {len(p['paras']):4d} paragraphs {len(p['text']):6d} chars  PMID:{p['pmid']}")

    log("reading papers with the model ...")
    for i, p in enumerate(papers, 1):
        p["n"] = i
    with cf.ThreadPoolExecutor(args.workers) as ex:
        papers = list(ex.map(lambda ip: read_paper(ip[0], ip[1], q_en), [(p["n"], p) for p in papers]))
    for p in papers:
        with open(os.path.join(outdir, f"{p['pmid'] or 'paper'}_notes.md"), "w", encoding="utf-8") as f:
            f.write(p["notes"])
        with open(os.path.join(outdir, f"{p['pmid'] or 'paper'}_citations.json"), "w", encoding="utf-8") as f:
            json.dump(p.get("cites", []), f, ensure_ascii=False, indent=1)
        nv = sum(c["verified"] for c in p.get("cites", []))
        log(f"  [{p['n']}] relevance {p.get('relevance', '?')}  quotes verified {nv}/{len(p.get('cites', []))}  PMID:{p['pmid']}")
    used = [p for p in papers if p.get("relevance", 1) > 0]
    log(f"relevant papers: {len(used)}/{len(papers)}")

    store = None
    if not args.no_kb:
        log("extracting atomic knowledge + indexing into kb/ ...")
        store = ks.KnowledgeStore()
        with cf.ThreadPoolExecutor(args.workers) as ex:   # LLM calls in parallel; store.add_paper is done serially below
            facts_done = list(ex.map(lambda p: (p, ks.extract_facts(p["paras"], lambda s, u, mt: llm(s, u, max_tokens=mt), q_en) if p.get("paras") else []), papers))
        for p, facts in facts_done:
            p["facts"] = facts
            with open(os.path.join(outdir, f"{p['pmid'] or 'paper'}_facts.json"), "w", encoding="utf-8") as f:
                json.dump(facts, f, ensure_ascii=False, indent=1)
            meta = {k: p.get(k) for k in ("pmid", "doi", "pmcid", "title", "year", "journal", "issn", "quartile", "authors", "source", "types")}
            meta.update({"indexed_at": dt.datetime.now().isoformat(timespec="seconds"), "n_paragraphs": len(p["paras"]), "n_facts": len(facts)})
            p["library_dir"] = ks.save_to_library(meta, p["paras"], facts, p["fulltext_md"])
            try:
                n_items = store.add_paper(meta, p["paras"], facts)
            except Exception as e:  # noqa: BLE001
                log(f"  kb index failed for PMID:{p['pmid']}: {e}"); n_items = 0
            nv = sum(f["verified"] for f in facts)
            log(f"  [{p['n']}] {len(facts)} facts ({nv} located) + {len(p['paras'])} paragraphs -> kb ({n_items} items)  library/{os.path.basename(p['library_dir'])}")
        st = store.stats()
        log(f"kb now holds {st['items']} items from {st['papers']} papers (embedder: {st.get('embedder')})")

    if not used:
        log("nothing relevant found; aborting")
        return

    log("synthesizing answer ...")
    by_n = {p["n"]: p for p in used}
    body = synthesize(args.question, used)
    body, used_marks = link_markers(body, by_n, papers_dir_rel)
    refs = "\n".join(ref_line(p, papers_dir_rel) for p in used)
    n_full = sum(p["source"] != "abstract" for p in used)
    kb_note = ""
    if store is not None and args.kb_hits:
        hits = store.search(q_en, top_k=args.kb_hits, kind="fact", pmids=None)
        hits = [h for h in hits if h.get("pmid") not in {p["pmid"] for p in used}]
        if hits:
            kb_note = "\n\n**知识库相关事实（来自以往检索，未纳入本次综合）**\n" + "\n".join(
                f"- {h['text']} — {h.get('title', '')[:80]} ({h.get('year')}) PMID:{h.get('pmid')} ¶{h.get('pid')}" for h in hits)
    answer = (f"# Q: {args.question}\n\n筛选条件：{flt.describe()}　|　阅读 {len(used)} 篇（{n_full} 篇全文）\n\n{body}\n\n"
              f"**参考文献 / References**（{n_full}/{len(used)} 篇读了全文）\n{refs}\n\n"
              f"{location_appendix(used_marks, by_n, papers_dir_rel)}{kb_note}\n\n"
              f"*This is a literature summary for research/educational use, not medical advice.*\n")
    out = os.path.join(ANSWERS_DIR, f"{ts}.md")
    with open(out, "w", encoding="utf-8") as f:
        f.write(answer)
    print("\n" + "=" * 80 + "\n" + answer)
    log(f"saved: {out}\nfull texts + notes + facts: {outdir}")


if __name__ == "__main__":
    main()
