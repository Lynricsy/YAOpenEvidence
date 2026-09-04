"""answers 端点契约：入参校验、202 语义、并发上限、未就绪、删除/取消、legacy 导入。"""
from __future__ import annotations

import datetime as dt
import json
from pathlib import Path

import pytest

from app.db import SessionLocal
from app.models import Answer, Job
from app.services import events
from app.services.answers import import_legacy_answers

from .conftest import ADMIN_KEY, READ_KEY, WRITE_KEY, auth

VALID = {"question": "SGLT2 抑制剂对 HFpEF 有什么获益？", "papers": 2, "years": 3, "use_kb": False}


def _create(client, **overrides):
    return client.post("/v1/answers", json={**VALID, **overrides}, headers=auth(WRITE_KEY))


def test_create_returns_202_with_location_and_enqueues(client, arq):
    r = _create(client)
    assert r.status_code == 202
    body = r.json()
    assert body["status"] == "queued"
    assert body["question"] == VALID["question"]
    assert body["job_id"]
    assert r.headers["location"] == f"/v1/answers/{body['id']}"
    assert body["created_at"].endswith("Z")

    assert arq.calls == [("run_ask_job", (body["job_id"],), {"_job_id": body["job_id"]})]
    with SessionLocal() as db:
        job = db.get(Job, body["job_id"])
        answer = db.get(Answer, body["id"])
        assert job.status == "queued" and job.kind == "ask"
        assert job.params["answer_id"] == body["id"]
        assert answer.status == "queued" and answer.api_key_id == "writer"


@pytest.mark.parametrize("payload, field", [
    ({"years": 3, "year_from": 2020}, "years"),
    ({"year_to": 2024}, "year_to"),
    ({"year_from": 2024, "year_to": 2020}, "year_to"),
    ({"quartiles": [5]}, "quartiles"),
    ({"question": "   "}, "question"),
    ({"papers": 99}, "papers"),
])
def test_invalid_options_are_rejected(client, payload, field):
    r = _create(client, **payload)
    assert r.status_code == 422
    body = r.json()
    assert body["code"] == "validation_error"
    assert r.headers["content-type"].startswith("application/problem+json")
    assert body["errors"], "422 必须带上逐字段的 errors"


def test_active_job_limit_per_key(client):
    assert _create(client).status_code == 202
    assert _create(client).status_code == 202
    r = _create(client)
    assert r.status_code == 429
    assert r.json()["code"] == "too_many_jobs"


def test_markdown_of_unfinished_answer_is_conflict(client):
    answer_id = _create(client).json()["id"]
    r = client.get(f"/v1/answers/{answer_id}/markdown", headers=auth(READ_KEY))
    assert r.status_code == 409
    assert r.json()["code"] == "not_ready"


def test_paper_detail_of_answer_without_papers_is_404(client):
    answer_id = _create(client).json()["id"]
    r = client.get(f"/v1/answers/{answer_id}/papers/1", headers=auth(READ_KEY))
    assert r.status_code == 404
    assert r.json()["code"] == "not_found"


def test_unknown_answer_is_404(client):
    r = client.get("/v1/answers/nope", headers=auth(READ_KEY))
    assert r.status_code == 404
    assert r.json()["detail"].startswith("answer 'nope'")


def test_delete_active_answer_requests_cancel(client, sync_redis):
    body = _create(client).json()
    r = client.delete(f"/v1/answers/{body['id']}", headers=auth(WRITE_KEY))
    assert r.status_code == 204
    assert sync_redis.exists(events.cancel_key(body["job_id"]))
    # 还在跑的任务不删行，等 worker 收尾
    assert client.get(f"/v1/answers/{body['id']}", headers=auth(READ_KEY)).status_code == 200


def test_delete_terminal_answer_removes_row_and_files(client, data_root: Path):
    body = _create(client).json()
    answer_id = body["id"]
    md = data_root / "answers" / f"{answer_id}.md"
    papers_dir = data_root / "answers" / f"{answer_id}_papers"
    md.write_text("# Q: x", encoding="utf-8")
    papers_dir.mkdir(parents=True, exist_ok=True)
    (papers_dir / "1_notes.md").write_text("notes", encoding="utf-8")
    with SessionLocal() as db:
        row = db.get(Answer, answer_id)
        row.status = "ready"
        job = db.get(Job, row.job_id)
        job.status = "succeeded"
        db.commit()

    assert client.delete(f"/v1/answers/{answer_id}", headers=auth(WRITE_KEY)).status_code == 204
    assert client.get(f"/v1/answers/{answer_id}", headers=auth(READ_KEY)).status_code == 404
    assert not md.exists()
    assert not papers_dir.exists()


def test_delete_other_keys_answer_is_forbidden_but_admin_may(client):
    answer_id = _create(client).json()["id"]
    with SessionLocal() as db:
        row = db.get(Answer, answer_id)
        row.api_key_id = "someone-else"
        row.status = "ready"
        db.commit()
    assert client.delete(f"/v1/answers/{answer_id}", headers=auth(WRITE_KEY)).status_code == 403
    assert client.delete(f"/v1/answers/{answer_id}", headers=auth(ADMIN_KEY)).status_code == 204


def test_list_filters_by_status_and_question(client):
    first = _create(client, question="替西帕肽与死亡率").json()["id"]
    _create(client, question="SGLT2 与心衰住院")

    r = client.get("/v1/answers", params={"q": "替西帕肽"}, headers=auth(READ_KEY))
    assert r.status_code == 200
    page = r.json()
    assert page["total"] == 1
    assert page["items"][0]["id"] == first
    assert "body_md" not in page["items"][0], "列表用 summary，不带正文"

    assert client.get("/v1/answers", params={"status": "ready"},
                      headers=auth(READ_KEY)).json()["total"] == 0


def test_import_legacy_answers_is_idempotent(client, data_root: Path):
    (data_root / "answers" / "20260101_000000.md").write_text("# Q: 测试\n\n正文", encoding="utf-8")
    with SessionLocal() as db:
        assert import_legacy_answers(db) >= 1
        assert import_legacy_answers(db) == 0

    r = client.get("/v1/answers/20260101_000000", headers=auth(READ_KEY))
    assert r.status_code == 200
    body = r.json()
    assert body["question"] == "测试"
    assert body["status"] == "ready"
    assert body["created_at"] == "2026-01-01T00:00:00Z"

    md = client.get("/v1/answers/20260101_000000/markdown", headers=auth(READ_KEY))
    assert md.status_code == 200
    assert md.headers["content-type"].startswith("text/markdown")
    assert "正文" in md.text


def test_answer_paper_detail_reads_run_artifacts(client, data_root: Path):
    """/papers/{n} 要能从 answers/<id>_papers/ 自包含地拼出详情。"""
    answer_id = "run-with-files"
    papers_dir = data_root / "answers" / f"{answer_id}_papers"
    papers_dir.mkdir(parents=True, exist_ok=True)
    (papers_dir / "39133485_notes.md").write_text("### Relevance\n2", encoding="utf-8")
    (papers_dir / "39133485.md").write_text('<a id="p1"></a>**¶1** text', encoding="utf-8")
    (papers_dir / "39133485_paragraphs.json").write_text(
        json.dumps([{"id": 1, "sec": "Abstract", "page": None, "text": "text"}]), encoding="utf-8")
    (papers_dir / "39133485_citations.json").write_text(
        json.dumps([{"claimed_pid": 1, "pid": 1, "quote": "text", "score": 1.0, "verified": True}]),
        encoding="utf-8")
    with SessionLocal() as db:
        db.add(Answer(id=answer_id, job_id=None, api_key_id="writer", status="ready",
                      question="q", queries=[], options={}, papers=[{"n": 1, "pmid": "39133485",
                                                                     "title": "T", "source": "pmc"}],
                      citations=[], kb_hits=[], answer_md="# Q: q",
                      created_at=dt.datetime.now(dt.timezone.utc)))
        db.commit()

    r = client.get(f"/v1/answers/{answer_id}/papers/1", headers=auth(READ_KEY))
    assert r.status_code == 200
    body = r.json()
    assert body["n"] == 1 and body["pmid"] == "39133485"
    assert body["notes_md"].startswith("### Relevance")
    assert body["paragraphs"][0]["text"] == "text"
    assert body["citations"][0]["verified"] is True
    assert body["facts"] == []
    assert '<a id="p1">' in body["fulltext_md"]

    assert client.get(f"/v1/answers/{answer_id}/papers/2",
                      headers=auth(READ_KEY)).status_code == 404
