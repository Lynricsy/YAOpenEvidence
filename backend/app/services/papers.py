"""文献库文件的只读访问。"""
from __future__ import annotations

import json
import os
import re

from picos_paths import LIB_DIR

from ..errors import ApiError

KEY_RE = re.compile(r"^[A-Za-z0-9._-]{1,80}$")


def _paper_dir(key: str) -> str:
    """先验证目录名，避免用户输入参与任意路径拼接。"""
    if not KEY_RE.fullmatch(key):
        raise ApiError(404, "not_found", f"paper '{key}' not found")
    return os.path.join(LIB_DIR, key)


def _read_json(path: str):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def list_papers(q: str = "", limit: int = 20, offset: int = 0) -> tuple[list[dict], int]:
    records: list[dict] = []
    if not os.path.isdir(LIB_DIR):
        return [], 0

    needle = q.casefold()
    with os.scandir(LIB_DIR) as entries:
        for entry in entries:
            if not entry.is_dir() or not KEY_RE.fullmatch(entry.name):
                continue
            meta_path = os.path.join(entry.path, "meta.json")
            if not os.path.isfile(meta_path):
                continue
            meta = _read_json(meta_path)
            meta["key"] = entry.name
            if needle and needle not in str(meta.get("title") or "").casefold() \
                    and needle not in str(meta.get("journal") or "").casefold():
                continue
            records.append(meta)

    # ISO-8601 时间按字符串排序即可；空值固定落在末尾。
    records.sort(key=lambda item: str(item.get("indexed_at") or ""), reverse=True)
    total = len(records)
    return records[offset:offset + limit], total


def get_meta(key: str) -> dict:
    paper_dir = _paper_dir(key)
    meta_path = os.path.join(paper_dir, "meta.json")
    if not os.path.isdir(paper_dir) or not os.path.isfile(meta_path):
        raise ApiError(404, "not_found", f"paper '{key}' not found")
    meta = _read_json(meta_path)
    meta["key"] = key
    return meta


def get_paragraphs(key: str) -> list[dict]:
    paper_dir = _paper_dir(key)
    path = os.path.join(paper_dir, "paragraphs.json")
    if not os.path.isdir(paper_dir) or not os.path.isfile(path):
        raise ApiError(404, "not_found", f"paragraphs for paper '{key}' not found")
    return _read_json(path)


def get_facts(key: str) -> list[dict]:
    paper_dir = _paper_dir(key)
    if not os.path.isdir(paper_dir):
        raise ApiError(404, "not_found", f"paper '{key}' not found")
    path = os.path.join(paper_dir, "facts.json")
    return _read_json(path) if os.path.isfile(path) else []


def get_paragraph(key: str, pid: int) -> dict:
    for paragraph in get_paragraphs(key):
        if paragraph.get("id") == pid:
            return paragraph
    raise ApiError(404, "not_found", f"paragraph {pid} for paper '{key}' not found")


def fulltext_path(key: str) -> str:
    paper_dir = _paper_dir(key)
    path = os.path.join(paper_dir, "fulltext.md")
    if not os.path.isdir(paper_dir) or not os.path.isfile(path):
        raise ApiError(404, "not_found", f"full text for paper '{key}' not found")
    return path
