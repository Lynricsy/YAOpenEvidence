#!/usr/bin/env python
"""Question -> literature search -> full-text download -> per-paper reading -> cited answer.

Usage:
    python ask.py "SGLT2抑制剂对HFpEF患者有什么获益？"
    python ask.py --papers 8 --fulltext-min 4 "..."
Outputs: answers/<ts>.md (answer), answers/<ts>_papers/ (full texts + reading notes), stdout progress.
"""
from __future__ import annotations

import argparse
import concurrent.futures as cf
import datetime as dt
import json
import os
import re
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import httpx  # noqa: E402

import semantic_scholar_mcp as lit  # noqa: E402  (reuse the MCP tool implementations)

try:
    import paywall_fetch  # noqa: E402  institutional-access downloader (SPIDER_PROJECT login state)
except Exception:  # noqa: BLE001  (playwright missing etc.)
    paywall_fetch = None
PAYWALL_STATE = os.environ.get("SD_STATE_PATH", os.path.join(os.path.dirname(os.path.abspath(__file__)), "sd_state.json"))
PAYWALL_MAX = int(os.environ.get("PAYWALL_MAX_PER_RUN", "5"))

LLM_BASE = os.environ.get("LLM_BASE", "http://127.0.0.1:4000/v1")
LLM_KEY = os.environ.get("LOCAL_QWEN_KEY", "sk-123456")
LLM_MODEL = os.environ.get("LLM_MODEL", "qwen3-14b")
ROOT = os.path.dirname(os.path.abspath(__file__))
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
def epmc_search(query: str, limit: int, fulltext_only: bool) -> list[dict]:
    q = query + (" AND HAS_FT:y AND OPEN_ACCESS:y" if fulltext_only else "")
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
                    "authors": a.get("authorString", ""), "cited": int(a.get("citedByCount", 0) or 0),
                    "types": [], "abstract": ""})
    return out


def pubmed_search(query: str, limit: int) -> list[dict]:
    params = {"db": "pubmed", "term": query, "retmax": limit, "sort": "relevance", "retmode": "json"}
    r = lit._ncbi("esearch.fcgi", params)
    if r is None:
        return []
    ids = r.json().get("esearchresult", {}).get("idlist") or []
    recs = lit._pubmed_fetch_records(ids)
    return [{"pmid": p["pmid"], "pmcid": p["pmc"], "doi": p["doi"], "title": p["title"], "year": p["year"],
             "journal": p["journal"], "authors": ", ".join(p["authors"][:3]) + (" et al." if len(p["authors"]) > 3 else ""),
             "cited": 0, "types": p["types"], "abstract": p["abstract"]} for p in recs]


def rank_key(p: dict) -> tuple:
    t = " ".join(p.get("types", [])).lower()
    quality = 3 if "meta-analysis" in t or "systematic review" in t else 2 if "randomized" in t else 1 if "review" in t or "guideline" in t else 0
    return (quality, 1 if p.get("pmcid") else 0, p.get("cited", 0), p.get("year", ""))


def search_all(queries: list[str], n_papers: int) -> list[dict]:
    seen: dict[str, dict] = {}
    for q in queries:
        for rec in pubmed_search(q, 10) + epmc_search(q, 8, fulltext_only=True):
            key = rec["pmid"] or rec["doi"] or rec["title"]
            if key and key not in seen:
                seen[key] = rec
            elif key:
                cur = seen[key]
                for k in ("pmcid", "doi", "abstract", "types"):
                    if not cur.get(k) and rec.get(k):
                        cur[k] = rec[k]
                cur["cited"] = max(cur.get("cited", 0), rec.get("cited", 0))
    papers = sorted(seen.values(), key=rank_key, reverse=True)
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


def fetch_fulltext(p: dict, outdir: str, max_chars: int) -> dict:
    """Fill p['text'] and p['source'] ('pmc' | 'pdf' | 'abstract')."""
    pmid = p["pmid"]
    text, source = "", "abstract"
    if p.get("pmcid"):
        secs = lit._epmc_fulltext_sections(p["pmcid"])
        if secs:
            keep = [(t, x) for t, x in secs if t.lower() not in ("references", "associated data", "supporting information")]
            text = "\n\n".join(f"## {t}\n{x}" for t, x in keep)
            source = "pmc"
    if not text:
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
                        text = lit._pdf_text(fn, max_chars * 2)
                        source = "pdf" if not text.startswith("ERROR") else "abstract"
                        if source == "abstract":
                            text = ""
            except Exception:  # noqa: BLE001
                pass
    if not text and p.get("doi") and paywall_fetch and os.path.exists(PAYWALL_STATE) and p.get("_paywall_ok"):
        fn = os.path.join(outdir, f"{pmid or 'paper'}.pdf")
        ok, note = paywall_fetch.download_pdf(p["doi"], fn, PAYWALL_STATE)
        log(f"  institutional {'OK ' if ok else 'no '} DOI:{p['doi']} — {note}")
        if ok:
            t = lit._pdf_text(fn, max_chars * 2)
            if not t.startswith("ERROR") and len(t) > 2000:
                text, source = t, "inst"
    if not text:
        if not p.get("abstract") and pmid:
            recs = lit._pubmed_fetch_records([pmid])
            if recs:
                p["abstract"] = recs[0]["abstract"]
                p["types"] = recs[0]["types"]
        text = p.get("abstract", "")
        source = "abstract"
    if len(text) > max_chars:
        text = text[:max_chars] + "\n[... truncated ...]"
    p["text"], p["source"] = text, source
    with open(os.path.join(outdir, f"{pmid or 'paper'}.md"), "w", encoding="utf-8") as f:
        f.write(f"# {p['title']}\n\n{p['authors']} ({p['year']}) {p['journal']} PMID:{pmid} DOI:{p.get('doi','')} "
                f"PMCID:{p.get('pmcid','')}\nsource: {source}\n\n{text}")
    return p


# ------------------------------------------------------------------ 4. read
READ_SYS = """You are a meticulous clinical research analyst. You will be given ONE paper (full text or abstract,
already converted from PDF/XML to plain text) and a research question. Extract ONLY what the paper itself reports.
Return Markdown with EXACTLY these headings, following the PICOS framework:
### Relevance (0-3)
### P — Patient / 研究对象  (population, disease/condition, inclusion & exclusion criteria, age/sex, setting, sample size n per arm)
### I — Intervention / 干预措施  (drug/procedure/exposure, dose, frequency, route, duration)
### C — Comparator / 对照方式  (placebo / standard care / active control / no treatment; dose & duration)
### O — Outcome / 结局指标  (primary and secondary outcomes with exact numbers: HR/RR/OR with 95% CI, p values,
    absolute event rates, mean differences; follow-up time; adverse events)
### S — Study design / 研究设计  (RCT / meta-analysis / cohort / case-control / cross-sectional / review; blinding,
    randomization, number of centres, registration, follow-up duration)
### Key findings relevant to the question  (bullets; quote short phrases with exact numbers)
### Limitations stated by the authors
Rules: never add information that is not in the text; write "Not reported" for any PICOS item the paper does not state;
if the paper is not relevant say Relevance 0 and stop."""


def read_paper(i: int, p: dict, question_en: str) -> dict:
    if not p.get("text"):
        p["notes"] = "### Relevance (0-3)\n0 (no text available)"
        return p
    user = f"QUESTION: {question_en}\n\nPAPER [{i}] {p['title']} ({p['year']}, {p['journal']}) — source: {p['source']}\n\n{p['text']}"
    p["notes"] = llm(READ_SYS, user, max_tokens=1800)
    m = re.search(r"Relevance.*?(\d)", p["notes"], re.S)
    p["relevance"] = int(m.group(1)) if m else 1
    return p


# ------------------------------------------------------------------ 5. synthesize
SYN_SYS = """You are a medical literature assistant writing an evidence summary for a clinician-researcher.
You are given PICOS reading notes for several papers, each labelled [n]. Write the answer in the SAME LANGUAGE as the
user's question, using ONLY facts from the notes. Cite every factual claim with its [n]. Do not invent numbers,
studies or citations; if the notes are insufficient, say what is missing.
Format:
**结论 / Bottom line** — 2-4 sentences.
**证据 / Evidence** — bullets, each with study type, n, effect sizes, ending with [n].
**PICOS 证据表 / PICOS table** — a Markdown table with columns: [n] | P 研究对象 | I 干预措施 | C 对照方式 | O 结局指标 | S 研究设计.
One row per paper with Relevance >= 1; keep each cell concise (<= 25 words); write "未报告" if not reported.
**局限 / Caveats** — bullets.
Do NOT write the reference list; it will be appended automatically."""


def synthesize(question: str, papers: list[dict]) -> str:
    notes = "\n\n".join(f"[{p['n']}] {p['title']} ({p['year']}) — {p['journal']} — text source: {p['source']}\n{p['notes']}"
                        for p in papers)
    return llm(SYN_SYS, f"USER QUESTION: {question}\n\nREADING NOTES:\n{notes}", max_tokens=2600, think=True)


def _short_authors(a: str) -> str:
    names = [x.strip() for x in a.replace(" et al.", "").split(",") if x.strip()]
    return ", ".join(names[:3]) + (" et al." if len(names) > 3 else "")


def ref_line(p: dict) -> str:
    p["authors"] = _short_authors(p["authors"])
    ids = " ".join(x for x in [f"PMID:{p['pmid']}" if p["pmid"] else "", f"DOI:{p['doi']}" if p.get("doi") else "",
                               p.get("pmcid", "")] if x)
    src = {"pmc": "全文(PMC)", "pdf": "全文(OA PDF)", "inst": "全文(机构订阅)", "abstract": "仅摘要"}[p["source"]]
    return f"[{p['n']}] {p['authors']} ({p['year']}). {p['title']} *{p['journal']}*. {ids} 〔{src}〕"


# ------------------------------------------------------------------ main
def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("question")
    ap.add_argument("--papers", type=int, default=8, help="max papers to read")
    ap.add_argument("--max-chars", type=int, default=28000, help="max chars of text fed per paper")
    ap.add_argument("--workers", type=int, default=4)
    ap.add_argument("--no-paywall", action="store_true", help="skip institutional-access downloads")
    args = ap.parse_args()

    ts = dt.datetime.now().strftime("%Y%m%d_%H%M%S")
    outdir = os.path.join(ROOT, "answers", f"{ts}_papers")
    os.makedirs(outdir, exist_ok=True)

    log(f"Q: {args.question}")
    queries, q_en = make_queries(args.question)
    log(f"queries: {queries}")

    papers = search_all(queries, args.papers)
    log(f"candidates: {len(papers)}")
    for p in papers:
        log(f"  - {p['title'][:90]} ({p['year']}) PMID:{p['pmid']} {'PMC✔' if p.get('pmcid') else ''}")

    log("downloading full texts (open access) ...")
    with cf.ThreadPoolExecutor(args.workers) as ex:
        papers = list(ex.map(lambda p: fetch_fulltext(p, outdir, args.max_chars), papers))
    if paywall_fetch and os.path.exists(PAYWALL_STATE) and not args.no_paywall:
        todo = [p for p in papers if p["source"] == "abstract" and p.get("doi")][:PAYWALL_MAX]
        if todo:
            log(f"institutional access: trying {len(todo)} paywalled paper(s) serially (polite delay) ...")
            for p in todo:  # serial on purpose: one browser at a time, delay between requests
                p["_paywall_ok"] = True
                p["abstract"] = p.get("text") or p.get("abstract")
                p["text"] = ""
                fetch_fulltext(p, outdir, args.max_chars)
    elif not args.no_paywall:
        log("institutional access: skipped (no sd_state.json — run paywall_fetch.py login to enable)")
    for p in papers:
        log(f"  {p['source']:8s} {len(p['text']):6d} chars  PMID:{p['pmid']}")

    log("reading papers with the model ...")
    for i, p in enumerate(papers, 1):
        p["n"] = i
    with cf.ThreadPoolExecutor(args.workers) as ex:
        papers = list(ex.map(lambda ip: read_paper(ip[0], ip[1], q_en), [(p["n"], p) for p in papers]))
    for p in papers:
        with open(os.path.join(outdir, f"{p['pmid'] or 'paper'}_notes.md"), "w", encoding="utf-8") as f:
            f.write(p["notes"])
    used = [p for p in papers if p.get("relevance", 1) > 0]
    log(f"relevant papers: {len(used)}/{len(papers)}")
    if not used:
        log("nothing relevant found; aborting")
        return

    log("synthesizing answer ...")
    body = synthesize(args.question, used)
    refs = "\n".join(ref_line(p) for p in used)
    n_full = sum(p["source"] != "abstract" for p in used)
    answer = (f"# Q: {args.question}\n\n{body}\n\n**参考文献 / References**（{n_full}/{len(used)} 篇读了全文）\n{refs}\n\n"
              f"*This is a literature summary for research/educational use, not medical advice.*\n")
    out = os.path.join(ROOT, "answers", f"{ts}.md")
    with open(out, "w", encoding="utf-8") as f:
        f.write(answer)
    print("\n" + "=" * 80 + "\n" + answer)
    log(f"saved: {out}\nfull texts + notes: {outdir}")


if __name__ == "__main__":
    main()
