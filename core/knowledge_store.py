#!/usr/bin/env python
"""Paragraph splitting, atomic-knowledge extraction and a persistent local vector store.

Layout (all under the project root):
  library/<pmid>/fulltext.md       full text with paragraph anchors  (<a id="p12"></a> ¶12 ...)
  library/<pmid>/paragraphs.json   [{id, sec, page, text}]
  library/<pmid>/facts.json        atomic knowledge units [{fact, pid, quote, kind, ...}]
  library/<pmid>/meta.json         bibliographic record (title, journal, year, quartile, source ...)
  kb/index.npz                     整份向量索引（向量矩阵 + 每条元数据 + embedder 信息）
                                   一个文件、一次 rename 换代；旧的三文件布局
                                   （meta.jsonl / vectors.npy / info.json）仍可读，保存时自动迁移

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
import fcntl
import hashlib
import json
import math
import os
import re
import shutil
import sys
import tempfile
import time
from contextlib import contextmanager, nullcontext
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
    """Text produced by literature.pdf_text ('--- page N ---' markers). Paragraph = blank-line block or ~1000-char chunk."""
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


# ====================================================================== index container
INDEX_FILE = "index.npz"
LEGACY_FILES = ("meta.jsonl", "vectors.npy", "info.json")


def _blob(obj: object) -> np.ndarray:
    """把 JSON 塞进 npz：存成 uint8 数组，读写都不碰 pickle。"""
    return np.frombuffer(json.dumps(obj, ensure_ascii=False).encode("utf-8"), dtype=np.uint8)


def _unblob(arr: np.ndarray) -> object:
    return json.loads(bytes(arr).decode("utf-8"))


def write_index(path: str, meta: list[dict], vecs: Optional[np.ndarray], info: dict) -> None:
    """原子写整代索引：写 `<path>.tmp`，fsync，再一次 os.replace 换上去。

    失败时清掉半成品 tmp——它不会被任何读者看到（读者只认 `path`），但留着
    会让人误以为索引坏了。
    """
    dim = int(info.get("dim") or 0) or (int(vecs.shape[1]) if vecs is not None and len(vecs) else 0)
    payload = vecs if vecs is not None else np.zeros((0, dim), dtype=np.float32)
    stamped = {**info, "items": len(meta)}
    tmp = path + ".tmp"
    try:
        with open(tmp, "wb") as f:
            np.savez(f, vectors=payload, meta=_blob(meta), info=_blob(stamped))
            f.flush()
            os.fsync(f.fileno())           # rename 是原子的，但内容得先真的落盘
        os.replace(tmp, path)
    except BaseException:
        try:
            os.remove(tmp)
        except FileNotFoundError:
            pass
        raise


def read_index(path: str) -> tuple[list[dict], Optional[np.ndarray], dict]:
    with np.load(path) as z:
        meta = _unblob(z["meta"])
        info = _unblob(z["info"])
        vecs = z["vectors"]
    return meta, (vecs if len(vecs) else None), info


def index_info(kb_dir: str = KB_DIR) -> Optional[dict]:
    """只读索引头（embedder / dim / items），不加载向量矩阵——给健康检查用。"""
    path = os.path.join(kb_dir, INDEX_FILE)
    if os.path.exists(path):
        with np.load(path) as z:
            return _unblob(z["info"])
    meta_path, _, info_path = (os.path.join(kb_dir, n) for n in LEGACY_FILES)
    if not os.path.exists(info_path):
        return None
    with open(info_path, encoding="utf-8") as f:
        info = json.load(f)
    items = 0
    if os.path.exists(meta_path):
        with open(meta_path, encoding="utf-8") as f:
            items = sum(1 for line in f if line.strip())
    return {**info, "items": items}



@contextmanager
def _writer_lock(kb_dir: str, should_cancel: Callable[[], bool] = lambda: False):
    """同一路径的线程、进程共用锁；锁文件不能随索引换代或清理而删除。"""
    path = os.path.realpath(kb_dir) + ".lock"
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "a+b") as lock:
        while True:
            if should_cancel():
                raise ReindexCancelled("cancelled while waiting for knowledge store")
            try:
                fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
                break
            except BlockingIOError:
                time.sleep(0.05)
        try:
            if should_cancel():
                raise ReindexCancelled("cancelled before rebuilding")
            yield
        finally:
            fcntl.flock(lock, fcntl.LOCK_UN)

# ====================================================================== store
class KnowledgeStore:
    """向量库。整份索引是**一个文件**（`kb/index.npz`）。

    早先的三文件布局（meta.jsonl / vectors.npy / info.json）无法原子更新：
    逐个 os.replace，中途崩溃就会留下「新向量 + 旧元数据」，两者长度往往仍然
    相等（重建只是改变了条目顺序），于是 row i 的向量配到别人的论文上——
    静默错配，比缺索引危险得多。一个文件 + 一次 rename 让「换代」要么全成、
    要么全不成。
    """

    def __init__(self, kb_dir: str = KB_DIR, embedder: Optional[Embedder] = None):
        self.dir = kb_dir
        os.makedirs(kb_dir, exist_ok=True)
        self.index_path = os.path.join(kb_dir, INDEX_FILE)
        self._legacy = tuple(os.path.join(kb_dir, n) for n in LEGACY_FILES)
        self._embedder = embedder
        self._snapshot: tuple[list[dict], Optional[np.ndarray], dict] = (
            [], None, {"embedder": None, "dim": None})
        self._staging = False
        self._load()

    @property
    def meta(self) -> list[dict]:
        return self._snapshot[0]

    @property
    def vecs(self) -> Optional[np.ndarray]:
        return self._snapshot[1]

    @property
    def info(self) -> dict:
        return self._snapshot[2]

    @property
    def embedder(self) -> Embedder:
        if self._embedder is None:
            self._embedder = Embedder()
        return self._embedder

    def _load(self) -> None:
        if os.path.exists(self.index_path):
            self._snapshot = read_index(self.index_path)
            return
        self._load_legacy()

    def _load_legacy(self) -> None:
        """读旧的三文件布局，让已有 kb/ 无需先重建也能用；下一次保存即完成迁移。"""
        meta_path, vec_path, info_path = self._legacy
        meta, vecs = [], None
        info = {"embedder": None, "dim": None}
        if os.path.exists(meta_path):
            with open(meta_path, encoding="utf-8") as f:
                meta = [json.loads(l) for l in f if l.strip()]
        if os.path.exists(vec_path):
            vecs = np.load(vec_path)
        if os.path.exists(info_path):
            with open(info_path, encoding="utf-8") as f:
                info = json.load(f)
        if vecs is not None and len(meta) != len(vecs):
            log(f"[kb] WARNING meta/vector length mismatch ({len(meta)} vs {len(vecs)}); run `reindex`")
            n = min(len(meta), len(vecs))
            meta, vecs = meta[:n], vecs[:n]
        self._snapshot = meta, vecs, info

    def indexed_pmids(self) -> set[str]:
        return {m["pmid"] for m in self.meta if m.get("pmid")}

    def add_paper(self, meta: dict, paras: list[dict], facts: list[dict], replace: bool = True) -> int:
        """Index one paper's facts and paragraphs. Returns number of items added."""
        with nullcontext() if self._staging else _writer_lock(self.dir):
            if not self._staging:
                self._load()
            return self._add_paper(meta, paras, facts, replace)

    def _add_paper(self, meta: dict, paras: list[dict], facts: list[dict], replace: bool) -> int:
        pmid = str(meta.get("pmid") or meta.get("doi") or meta.get("title"))
        old_meta, old_vecs, info = self._snapshot
        if info.get("embedder") and info["embedder"] != self.embedder.name:
            log(f"[kb] WARNING index built with {info['embedder']} but current embedder is {self.embedder.name}; run `reindex`")
        if replace and pmid in self.indexed_pmids():
            keep = [i for i, m in enumerate(old_meta) if m.get("pmid") != pmid]
            old_meta = [old_meta[i] for i in keep]
            old_vecs = old_vecs[keep] if old_vecs is not None and len(keep) else None
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
        vecs = v if old_vecs is None or len(old_vecs) == 0 else np.vstack([old_vecs, v])
        snapshot = (old_meta + items, vecs, {"embedder": self.embedder.name, "dim": int(v.shape[1])})
        if not self._staging:
            self._persist(snapshot)
        self._snapshot = snapshot
        return len(items)

    def _persist(self, snapshot: tuple[list[dict], Optional[np.ndarray], dict]) -> None:
        write_index(self.index_path, *snapshot)
        for path in self._legacy:          # 迁移完成：旧布局留着只会误导读者
            try:
                os.remove(path)
            except FileNotFoundError:
                pass

    def search(self, query: str, top_k: int = 8, kind: str = "", pmids: Optional[set[str]] = None) -> list[dict]:
        meta, vecs, _ = self._snapshot
        if vecs is None or not len(meta):
            return []
        q = self.embedder.encode([query])[0]
        scores = vecs @ q
        order = np.argsort(-scores)
        out = []
        for i in order:
            m = meta[int(i)]
            if kind and m["kind"] != kind:
                continue
            if pmids and m.get("pmid") not in pmids:
                continue
            out.append({**m, "score": float(scores[int(i)])})
            if len(out) >= top_k:
                break
        return out

    def stats(self) -> dict:
        meta, _, info = self._snapshot
        kinds: dict[str, int] = {}
        for m in meta:
            kinds[m["kind"]] = kinds.get(m["kind"], 0) + 1
        # 计算值优先于快照里记的 items：后者只是给健康检查省一次全量加载
        return {**info, "items": len(meta), "papers": len({m["pmid"] for m in meta if m.get("pmid")}), "by_kind": kinds}


# ====================================================================== library (persistent per-paper files)
def save_to_library(meta: dict, paras: list[dict], facts: list[dict], fulltext_md: str) -> str:
    # 保存四份文献文件时阻止重建读取未完成的文献。
    with _writer_lock(KB_DIR):
        return _save_to_library(meta, paras, facts, fulltext_md)


def _save_to_library(meta: dict, paras: list[dict], facts: list[dict], fulltext_md: str) -> str:
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


class ReindexCancelled(Exception):
    """重建被协作式取消（在逐篇边界抛出）。线上索引不受影响。"""


def reindex(emit: Callable[[dict], None] = lambda e: None,
            should_cancel: Callable[[], bool] = lambda: False) -> tuple[int, int]:
    """从 library/ 重建 kb/（换 embedder 后必须做）。返回 (入库条目数, 论文数)。

    先在同一文件系统上的临时目录里**完整**构建，成功后把整代索引一次
    os.replace 换上去。原来的做法是先删线上索引再逐篇写，一旦崩溃、超时或
    被取消，留下的就是空的或半成品索引，而 API 正在读同一份 kb/。

    `emit` 收结构化进度事件（供 HTTP worker 推给 SSE），`should_cancel` 在
    逐篇边界轮询。
    """
    # 锁覆盖目录视图、编码、暂存和发布；新增写者等待后必须重新加载基线。
    with _writer_lock(KB_DIR, should_cancel):
        return _reindex_locked(emit, should_cancel)


def _reindex_locked(emit: Callable[[dict], None], should_cancel: Callable[[], bool]) -> tuple[int, int]:
    os.makedirs(KB_DIR, exist_ok=True)
    staging = tempfile.mkdtemp(prefix=".kb-reindex-", dir=os.path.dirname(os.path.abspath(KB_DIR)))
    try:
        store = KnowledgeStore(kb_dir=staging)
        store._staging = True
        dirs = sorted(glob_dirs())
        emit({"type": "stage", "stage": "reindex", "status": "started", "detail": {"papers": len(dirs)}})
        n, done = 0, 0
        for i, d in enumerate(dirs, 1):
            if should_cancel():
                raise ReindexCancelled(f"cancelled after {done}/{len(dirs)} papers")
            try:
                with open(os.path.join(d, "meta.json"), encoding="utf-8") as f: meta = json.load(f)
                with open(os.path.join(d, "paragraphs.json"), encoding="utf-8") as f: paras = json.load(f)
                with open(os.path.join(d, "facts.json"), encoding="utf-8") as f: facts = json.load(f)
            except FileNotFoundError:
                continue
            n += store.add_paper(meta, paras, facts, replace=False)
            done += 1
            emit({"type": "progress", "stage": "reindex", "current": i, "total": len(dirs),
                  "pmid": str(meta.get("pmid") or ""), "title": str(meta.get("title") or "")})
        if should_cancel():
            raise ReindexCancelled(f"cancelled after {done}/{len(dirs)} papers")
        store._persist(store._snapshot)
        if should_cancel():
            raise ReindexCancelled("cancelled before publishing")
        _promote_index(staging)
        emit({"type": "stage", "stage": "reindex", "status": "finished",
              "detail": {"items": n, "papers": done}})
        return n, done
    finally:
        shutil.rmtree(staging, ignore_errors=True)


def _promote_index(staging: str) -> None:
    """换代：空库也发布完整快照，避免删除文件与活动加载之间的竞态。"""
    live = os.path.join(KB_DIR, INDEX_FILE)
    os.replace(os.path.join(staging, INDEX_FILE), live)
    for name in LEGACY_FILES:              # 迁移完成，旧布局不再是事实来源
        try:
            os.remove(os.path.join(KB_DIR, name))
        except FileNotFoundError:
            pass


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
        n, papers = reindex()
        print(f"reindexed {n} items from {papers} papers")
    else:
        ap.print_help()


def glob_dirs() -> list[str]:
    return [os.path.join(LIB_DIR, x) for x in os.listdir(LIB_DIR)] if os.path.isdir(LIB_DIR) else []


if __name__ == "__main__":
    main()
