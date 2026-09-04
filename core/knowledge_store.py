#!/usr/bin/env python
"""Paragraph splitting, atomic-knowledge extraction and a persistent local vector store.

Layout (all under the project root):
  library/<pmid>/fulltext.md       full text with paragraph anchors  (<a id="p12"></a> ¶12 ...)
  library/<pmid>/paragraphs.json   [{id, sec, page, text}]
  library/<pmid>/facts.json        atomic knowledge units [{fact, pid, quote, kind, ...}]
  library/<pmid>/meta.json         bibliographic record (title, journal, year, quartile, source ...)
  kb/meta.jsonl                    one line per indexed item (fact or paragraph) with paper metadata
  kb/vectors.npy                   float32 matrix aligned with meta.jsonl
  kb/info.json                     {"embedder": ..., "dim": ...}

Embedding backend: sentence-transformers model at $EMBED_MODEL (default models/BAAI/bge-m3) on the
freest GPU; if the model or library is missing, falls back to a hashed bag-of-words vector (works
offline, weaker recall) — the backend name is stored so mixed indexes are detected.

CLI:
    python knowledge_store.py search "SGLT2 HFpEF hospitalization" [--top 8] [--kind fact|paragraph]
    python knowledge_store.py stats
    python knowledge_store.py reindex        # rebuild kb/ from library/ (e.g. after changing the embedder)
"""
from __future__ import annotations

import argparse
import difflib
import hashlib
import json
import math
import os
import re
import sys
from typing import Callable, Optional

import numpy as np

from picos_paths import KB_DIR, LIB_DIR, MODELS_DIR

EMBED_MODEL = os.environ.get("EMBED_MODEL") or os.path.join(MODELS_DIR, "BAAI", "bge-m3")
HASH_DIM = 4096


def log(msg: str) -> None:
    print(msg, file=sys.stderr, flush=True)


# ====================================================================== paragraphs
def _split_long(text: str, limit: int = 1200) -> list[str]:
    """Split a long paragraph on sentence boundaries into chunks <= ~limit chars."""
    if len(text) <= limit:
        return [text]
    sents = re.split(r"(?<=[.!?。！？])\s+", text)
    out, cur = [], ""
    for s in sents:
        if cur and len(cur) + len(s) > limit:
            out.append(cur.strip()); cur = s
        else:
            cur = (cur + " " + s) if cur else s
    if cur.strip():
        out.append(cur.strip())
    return out


def paragraphs_from_sections(secs: list[tuple[str, list[str]]]) -> list[dict]:
    """secs: [(section title, [paragraph, ...])] -> numbered paragraph records."""
    out = []
    for sec, paras in secs:
        for para in paras:
            para = " ".join(para.split())
            if len(para) < 20:
                continue
            for chunk in _split_long(para):
                out.append({"id": len(out) + 1, "sec": sec, "page": None, "text": chunk})
    return out


def paragraphs_from_pdf_text(text: str) -> list[dict]:
    """Text produced by _pdf_text ('--- page N ---' markers). Paragraph = blank-line block or ~1000-char chunk."""
    out = []
    for m in re.finditer(r"--- page (\d+) ---\n(.*?)(?=\n--- page \d+ ---|\Z)", text, re.S):
        page, body = int(m.group(1)), m.group(2)
        blocks = [b for b in re.split(r"\n\s*\n", body) if b.strip()]
        if len(blocks) <= 1:  # pypdf often yields no blank lines: re-flow and chunk by sentences
            flat = " ".join(body.split())
            blocks = _split_long(flat, 1000)
        for b in blocks:
            b = " ".join(b.split())
            if len(b) < 40:
                continue
            for chunk in _split_long(b):
                out.append({"id": len(out) + 1, "sec": f"p.{page}", "page": page, "text": chunk})
    if not out and text.strip():
        for chunk in _split_long(" ".join(text.split()), 1000):
            out.append({"id": len(out) + 1, "sec": "Body", "page": None, "text": chunk})
    return out


def paragraphs_from_abstract(abstract: str) -> list[dict]:
    out = []
    parts = [p for p in re.split(r"\n+", abstract or "") if p.strip()] or ([abstract] if abstract else [])
    for p in parts:
        m = re.match(r"^([A-Z][A-Z /&-]{2,40}):\s*(.*)$", p.strip(), re.S)
        sec, body = (m.group(1).title(), m.group(2)) if m else ("Abstract", p)
        for chunk in _split_long(" ".join(body.split())):
            out.append({"id": len(out) + 1, "sec": f"Abstract/{sec}" if sec != "Abstract" else "Abstract",
                        "page": None, "text": chunk})
    return out


def numbered_text(paras: list[dict]) -> str:
    """Model-facing rendering: section headers + [¶n] prefixes."""
    lines, cur = [], None
    for p in paras:
        if p["sec"] != cur:
            cur = p["sec"]
            lines.append(f"\n## {cur}")
        lines.append(f"[¶{p['id']}] {p['text']}")
    return "\n".join(lines).strip()


def anchored_markdown(paras: list[dict]) -> str:
    """Human-facing rendering with HTML anchors so answers can deep-link to a paragraph (file.md#p12)."""
    lines, cur = [], None
    for p in paras:
        if p["sec"] != cur:
            cur = p["sec"]
            lines.append(f"\n## {cur}\n")
        lines.append(f'<a id="p{p["id"]}"></a>**¶{p["id"]}** {p["text"]}\n')
    return "\n".join(lines).strip()


def loc_label(p: dict) -> str:
    return f"¶{p['id']} · {p['sec']}" if p.get("sec") else f"¶{p['id']}"


# ====================================================================== quote verification
def _norm(s: str) -> str:
    s = s.lower().replace("·", ".").replace("–", "-").replace("−", "-")
    s = re.sub(r"[ -​  ]", " ", s)
    return re.sub(r"[^a-z0-9%.<>=+-]+", " ", s).strip()


def quote_in(quote: str, text: str) -> float:
    """Similarity score 0..1 of `quote` against the best matching window of `text`."""
    q, t = _norm(quote), _norm(text)
    if not q or not t:
        return 0.0
    if q in t:
        return 1.0
    # sliding window of the quote's length over the paragraph
    w = max(len(q), 20)
    best, step = 0.0, max(1, w // 4)
    for i in range(0, max(1, len(t) - w + 1), step):
        r = difflib.SequenceMatcher(None, q, t[i:i + w + 20]).ratio()
        if r > best:
            best = r
            if best > 0.95:
                break
    return best


def locate_quote(quote: str, paras: list[dict], hint_id: Optional[int] = None, threshold: float = 0.72) -> tuple[Optional[dict], float]:
    """Find the paragraph that contains `quote`. Checks `hint_id` first, then all paragraphs."""
    by_id = {p["id"]: p for p in paras}
    if hint_id in by_id:
        s = quote_in(quote, by_id[hint_id]["text"])
        if s >= threshold:
            return by_id[hint_id], s
    best, best_s = None, 0.0
    for p in paras:
        s = quote_in(quote, p["text"])
        if s > best_s:
            best, best_s = p, s
            if s == 1.0:
                break
    return (best, best_s) if best_s >= threshold else (None, best_s)


CITE_RE = re.compile(r"[¶§]\s*(\d{1,4})\s*[:：]?\s*[\"“„]([^\"”]{8,400})[\"”]")


def verify_citations(notes: str, paras: list[dict]) -> list[dict]:
    """Parse (¶12: "quoted words") markers in model notes and verify each quote against the paragraphs.
    Returns [{pid, quote, score, verified, sec, page, claimed_pid}]."""
    out, seen = [], set()
    headings = [(m.start(), m.group(1).strip()) for m in re.finditer(r"^#{1,6}\s*(.+)$", notes, re.M)]
    for m in CITE_RE.finditer(notes):
        claimed, quote = int(m.group(1)), m.group(2).strip()
        key = (claimed, quote[:60])
        if key in seen:
            continue
        seen.add(key)
        heading = next((h for pos, h in reversed(headings) if pos < m.start()), "")
        p, score = locate_quote(quote, paras, hint_id=claimed)
        out.append({"claimed_pid": claimed, "pid": p["id"] if p else None, "sec": p["sec"] if p else None,
                    "page": p.get("page") if p else None, "quote": quote, "score": round(score, 2),
                    "verified": p is not None, "note_section": heading,
                    "key_finding": "key finding" in heading.lower()})
    return out


# ====================================================================== atomic facts
FACTS_SYS = """You are building a medical knowledge base. From the numbered paragraphs of ONE paper, extract ATOMIC
knowledge units: each unit is ONE self-contained factual statement that is true according to this paper, understandable
without the rest of the paper (name the population, intervention, comparator, outcome and numbers inside the sentence).
Return ONLY a JSON array, 5-20 items (most important first), each:
{"fact": "<one English sentence with exact numbers>", "fact_zh": "<中文翻译>", "kind": "finding|method|population|definition|safety|limitation|background",
 "pid": <paragraph number the fact comes from>, "quote": "<8-25 verbatim words copied from that paragraph>"}
Rules: never invent numbers; every fact must have a real pid and a verbatim quote; skip references/funding boilerplate."""


def extract_facts(paras: list[dict], llm: Callable[[str, str, int], str], question: str = "", max_chars: int = 24000) -> list[dict]:
    """Ask the model for atomic facts; verify each quote; return the verified list (unverified are flagged)."""
    text = numbered_text(paras)
    if len(text) > max_chars:
        text = text[:max_chars] + "\n[... truncated ...]"
    user = (f"(context question, optional: {question})\n\n" if question else "") + text
    raw = llm(FACTS_SYS, user, 3200)
    start = raw.find("[")
    if start < 0:
        return []
    blob = raw[start:]
    end = blob.rfind("]")
    try:
        items = json.loads(blob[:end + 1] if end > 0 else blob)
    except json.JSONDecodeError:
        # tolerate trailing commas / truncated output (max_tokens hit): keep the complete objects only
        objs = re.findall(r"\{[^{}]*\}", blob, re.S)
        items = []
        for o in objs:
            try:
                items.append(json.loads(o))
            except json.JSONDecodeError:
                continue
    out = []
    for it in items:
        if not isinstance(it, dict) or not it.get("fact"):
            continue
        try:
            pid = int(it.get("pid") or 0)
        except (TypeError, ValueError):
            pid = 0
        quote = str(it.get("quote") or "")
        p, score = locate_quote(quote, paras, hint_id=pid) if quote else (None, 0.0)
        if p is None and pid:  # quote not found: fall back to matching the fact text itself
            p, score = locate_quote(it["fact"], paras, hint_id=pid, threshold=0.5)
        out.append({"fact": str(it["fact"]).strip(), "fact_zh": str(it.get("fact_zh") or "").strip(),
                    "kind": str(it.get("kind") or "finding"), "pid": p["id"] if p else pid or None,
                    "sec": p["sec"] if p else None, "page": p.get("page") if p else None,
                    "quote": quote, "score": round(score, 2), "verified": p is not None})
    return out


# ====================================================================== embeddings
class Embedder:
    def __init__(self, model_path: str = EMBED_MODEL, device: str = ""):
        self.name = "hash-bow-v1"
        self.model = None
        self.dim = HASH_DIM
        if os.path.isdir(model_path):
            try:
                import torch
                from sentence_transformers import SentenceTransformer
                if not device:
                    device = "cpu"
                    if torch.cuda.is_available():
                        free = [(torch.cuda.mem_get_info(i)[0], i) for i in range(torch.cuda.device_count())]
                        best_free, best_i = max(free)
                        if best_free > 4 * 1024 ** 3:
                            device = f"cuda:{best_i}"
                self.model = SentenceTransformer(model_path, device=device)
                self.dim = (self.model.get_embedding_dimension() if hasattr(self.model, "get_embedding_dimension") else self.model.get_sentence_embedding_dimension())
                self.name = os.path.basename(model_path.rstrip("/"))
                log(f"[kb] embedder {self.name} on {device}")
            except Exception as e:  # noqa: BLE001
                log(f"[kb] embedding model unavailable ({e}); using hashed bag-of-words")
        else:
            log(f"[kb] no embedding model at {model_path}; using hashed bag-of-words (set EMBED_MODEL)")

    def encode(self, texts: list[str]) -> np.ndarray:
        if not texts:
            return np.zeros((0, self.dim), dtype=np.float32)
        if self.model is not None:
            v = self.model.encode(texts, batch_size=16, normalize_embeddings=True, show_progress_bar=False)
            return np.asarray(v, dtype=np.float32)
        return np.stack([self._hash(t) for t in texts]).astype(np.float32)

    @staticmethod
    def _hash(text: str) -> np.ndarray:
        v = np.zeros(HASH_DIM, dtype=np.float32)
        toks = re.findall(r"[a-z0-9]+|[一-鿿]", text.lower())
        grams = toks + [a + "_" + b for a, b in zip(toks, toks[1:])]
        for g in grams:
            h = int(hashlib.md5(g.encode()).hexdigest()[:8], 16)
            v[h % HASH_DIM] += 1.0
        v = np.log1p(v)
        n = np.linalg.norm(v)
        return v / n if n else v


# ====================================================================== store
class KnowledgeStore:
    def __init__(self, kb_dir: str = KB_DIR, embedder: Optional[Embedder] = None):
        self.dir = kb_dir
        os.makedirs(kb_dir, exist_ok=True)
        self.meta_path = os.path.join(kb_dir, "meta.jsonl")
        self.vec_path = os.path.join(kb_dir, "vectors.npy")
        self.info_path = os.path.join(kb_dir, "info.json")
        self._embedder = embedder
        self.meta: list[dict] = []
        self.vecs: Optional[np.ndarray] = None
        self.info = {"embedder": None, "dim": None}
        self._load()

    @property
    def embedder(self) -> Embedder:
        if self._embedder is None:
            self._embedder = Embedder()
        return self._embedder

    def _load(self) -> None:
        if os.path.exists(self.meta_path):
            with open(self.meta_path, encoding="utf-8") as f:
                self.meta = [json.loads(l) for l in f if l.strip()]
        if os.path.exists(self.vec_path):
            self.vecs = np.load(self.vec_path)
        if os.path.exists(self.info_path):
            with open(self.info_path, encoding="utf-8") as f:
                self.info = json.load(f)
        if self.vecs is not None and len(self.meta) != len(self.vecs):
            log(f"[kb] WARNING meta/vector length mismatch ({len(self.meta)} vs {len(self.vecs)}); run `reindex`")
            n = min(len(self.meta), len(self.vecs))
            self.meta, self.vecs = self.meta[:n], self.vecs[:n]

    def indexed_pmids(self) -> set[str]:
        return {m["pmid"] for m in self.meta if m.get("pmid")}

    def add_paper(self, meta: dict, paras: list[dict], facts: list[dict], replace: bool = True) -> int:
        """Index one paper's facts and paragraphs. Returns number of items added."""
        pmid = str(meta.get("pmid") or meta.get("doi") or meta.get("title"))
        if self.info.get("embedder") and self.info["embedder"] != self.embedder.name:
            log(f"[kb] WARNING index built with {self.info['embedder']} but current embedder is {self.embedder.name}; run `reindex`")
        if replace and pmid in self.indexed_pmids():
            keep = [i for i, m in enumerate(self.meta) if m.get("pmid") != pmid]
            self.meta = [self.meta[i] for i in keep]
            self.vecs = self.vecs[keep] if self.vecs is not None and len(keep) else None
        base = {k: meta.get(k) for k in ("pmid", "doi", "pmcid", "title", "year", "journal", "quartile", "source", "authors")}
        items, texts = [], []
        for fct in facts:
            items.append({**base, "kind": "fact", "pid": fct.get("pid"), "sec": fct.get("sec"), "page": fct.get("page"),
                          "text": fct["fact"], "text_zh": fct.get("fact_zh", ""), "fact_kind": fct.get("kind"),
                          "quote": fct.get("quote"), "verified": fct.get("verified")})
            texts.append(fct["fact"] + ((" " + fct["fact_zh"]) if fct.get("fact_zh") else ""))
        for p in paras:
            items.append({**base, "kind": "paragraph", "pid": p["id"], "sec": p["sec"], "page": p.get("page"),
                          "text": p["text"]})
            texts.append(f"{meta.get('title', '')}. {p['sec']}: {p['text']}")
        if not items:
            return 0
        v = self.embedder.encode(texts)
        self.vecs = v if self.vecs is None or len(self.vecs) == 0 else np.vstack([self.vecs, v])
        self.meta.extend(items)
        self.info = {"embedder": self.embedder.name, "dim": int(v.shape[1])}
        self._save()
        return len(items)

    def _save(self) -> None:
        """原子写：先写 .tmp 再 os.replace。

        顺序是 vectors → meta → info：worker 落库时 API 进程可能同时在读，
        任何时刻读到的三个文件都必须是自洽的一代快照。
        """
        if self.vecs is not None:
            tmp = self.vec_path + ".tmp"          # np.save 会补 .npy 后缀，故显式指定文件名
            with open(tmp, "wb") as f:
                np.save(f, self.vecs)
            os.replace(tmp, self.vec_path)
        tmp = self.meta_path + ".tmp"
        with open(tmp, "w", encoding="utf-8") as f:
            for m in self.meta:
                f.write(json.dumps(m, ensure_ascii=False) + "\n")
        os.replace(tmp, self.meta_path)
        tmp = self.info_path + ".tmp"
        with open(tmp, "w", encoding="utf-8") as f:
            json.dump(self.info, f)
        os.replace(tmp, self.info_path)

    def search(self, query: str, top_k: int = 8, kind: str = "", pmids: Optional[set[str]] = None) -> list[dict]:
        if self.vecs is None or not len(self.meta):
            return []
        q = self.embedder.encode([query])[0]
        scores = self.vecs @ q
        order = np.argsort(-scores)
        out = []
        for i in order:
            m = self.meta[int(i)]
            if kind and m["kind"] != kind:
                continue
            if pmids and m.get("pmid") not in pmids:
                continue
            out.append({**m, "score": float(scores[int(i)])})
            if len(out) >= top_k:
                break
        return out

    def stats(self) -> dict:
        kinds: dict[str, int] = {}
        for m in self.meta:
            kinds[m["kind"]] = kinds.get(m["kind"], 0) + 1
        return {"items": len(self.meta), "papers": len(self.indexed_pmids()), "by_kind": kinds, **self.info}


# ====================================================================== library (persistent per-paper files)
def save_to_library(meta: dict, paras: list[dict], facts: list[dict], fulltext_md: str) -> str:
    key = re.sub(r"[^A-Za-z0-9._-]+", "_", str(meta.get("pmid") or meta.get("doi") or meta.get("title"))[:80])
    d = os.path.join(LIB_DIR, key)
    os.makedirs(d, exist_ok=True)
    with open(os.path.join(d, "fulltext.md"), "w", encoding="utf-8") as f:
        f.write(fulltext_md)
    with open(os.path.join(d, "paragraphs.json"), "w", encoding="utf-8") as f:
        json.dump(paras, f, ensure_ascii=False, indent=1)
    with open(os.path.join(d, "facts.json"), "w", encoding="utf-8") as f:
        json.dump(facts, f, ensure_ascii=False, indent=1)
    with open(os.path.join(d, "meta.json"), "w", encoding="utf-8") as f:
        json.dump(meta, f, ensure_ascii=False, indent=1)
    return d


def format_hits(hits: list[dict]) -> str:
    lines = []
    for i, h in enumerate(hits, 1):
        loc = f"¶{h.get('pid')}" + (f" {h.get('sec')}" if h.get("sec") else "")
        lines.append(f"[{i}] ({h['score']:.3f}) [{h['kind']}] {h['text'][:400]}"
                     + (f"\n    中文: {h['text_zh']}" if h.get("text_zh") else "")
                     + f"\n    ← {h.get('title')} ({h.get('year')}) {h.get('journal')} PMID:{h.get('pmid')} {h.get('quartile') or ''} @ {loc}")
    return "\n".join(lines) if lines else "(knowledge base is empty)"


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd")
    s = sub.add_parser("search"); s.add_argument("query"); s.add_argument("--top", type=int, default=8); s.add_argument("--kind", default="")
    sub.add_parser("stats")
    sub.add_parser("reindex")
    a = ap.parse_args()
    if a.cmd == "search":
        print(format_hits(KnowledgeStore().search(a.query, a.top, a.kind)))
    elif a.cmd == "stats":
        print(json.dumps(KnowledgeStore().stats(), ensure_ascii=False, indent=1))
    elif a.cmd == "reindex":
        for fn in ("meta.jsonl", "vectors.npy", "info.json"):
            p = os.path.join(KB_DIR, fn)
            if os.path.exists(p):
                os.remove(p)
        ks = KnowledgeStore()
        n = 0
        for d in sorted(glob_dirs()):
            try:
                with open(os.path.join(d, "meta.json"), encoding="utf-8") as f: meta = json.load(f)
                with open(os.path.join(d, "paragraphs.json"), encoding="utf-8") as f: paras = json.load(f)
                with open(os.path.join(d, "facts.json"), encoding="utf-8") as f: facts = json.load(f)
            except FileNotFoundError:
                continue
            n += ks.add_paper(meta, paras, facts, replace=False)
        print(f"reindexed {n} items from {len(glob_dirs())} papers")
    else:
        ap.print_help()


def glob_dirs() -> list[str]:
    return [os.path.join(LIB_DIR, x) for x in os.listdir(LIB_DIR)] if os.path.isdir(LIB_DIR) else []


if __name__ == "__main__":
    main()
