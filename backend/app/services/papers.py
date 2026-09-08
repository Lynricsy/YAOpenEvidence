"""文献库文件的只读访问，以及入库任务的落盘 / 元数据准备。"""
from __future__ import annotations

import json
import os
import re

from fastapi import UploadFile
from picos_paths import LIB_DIR, PDF_DIR

from ..errors import ApiError
from ..schemas.literature import LiteratureRecord

KEY_RE = re.compile(r"^[A-Za-z0-9._-]{1,80}$")
PDF_MAGIC = b"%PDF-"
CHUNK = 1024 * 1024
# 入库元数据的固定键序，与 core/ingest.py 的 IngestSource.meta 契约一致
META_KEYS = ("pmid", "doi", "pmcid", "title", "year", "journal", "issn", "authors", "types", "quartile")


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


def ingest_pdf_path(job_id: str) -> str:
    """入库任务的 PDF 落盘位置；入库成功后文件保留，便于复查解析结果。"""
    return os.path.join(PDF_DIR, "ingest", f"{job_id}.pdf")


async def save_upload(file: UploadFile, dest: str, max_mb: int) -> None:
    """流式落盘并校验：非 PDF 直接 422，超限 413。任何失败都不留半个文件。"""
    limit = max_mb * 1024 * 1024
    os.makedirs(os.path.dirname(dest) or ".", exist_ok=True)
    written = 0
    try:
        with open(dest, "wb") as out:
            while chunk := await file.read(CHUNK):
                if written == 0 and not chunk.startswith(PDF_MAGIC):
                    raise ApiError(422, "validation_error", "文件不是 PDF")
                written += len(chunk)
                if written > limit:
                    raise ApiError(413, "payload_too_large", f"PDF 超过 {max_mb} MB")
                out.write(chunk)
        if written == 0:
            raise ApiError(422, "validation_error", "文件不是 PDF")
    except BaseException:
        try:
            os.remove(dest)
        except FileNotFoundError:
            pass
        raise


def meta_from_record(record: LiteratureRecord, doi: str = "") -> dict:
    """上游解析结果 -> 入库元数据（全部 str，与 library/meta.json 的形状一致）。"""
    return {
        "pmid": record.pmid or "",
        "doi": record.doi or doi,
        "pmcid": record.pmcid or "",
        "title": record.title,
        "year": record.year or "",
        "journal": record.journal or "",
        "issn": record.issn or "",
        "authors": ", ".join(record.authors),
        "types": list(record.types),
        "quartile": record.rank.quartile if record.rank else "",
    }


def merge_user_meta(resolved: dict | None, *, title: str, doi: str = "", journal: str = "",
                    year: str = "", authors: str = "") -> dict:
    """上游解析结果为底，用户填的字段只补空缺（上游权威，但不能因为解析失败就丢掉用户输入）。"""
    meta = dict(resolved) if resolved else {k: [] if k == "types" else "" for k in META_KEYS}
    for key, value in (("doi", doi), ("journal", journal), ("year", year), ("authors", authors)):
        if not meta.get(key) and value.strip():
            meta[key] = value.strip()
    if not meta.get("title"):
        meta["title"] = title.strip()
    return meta
