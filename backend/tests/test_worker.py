"""worker 状态机：成功 / 业务失败 / 排队期间被取消，以及事件流的终态。"""
from __future__ import annotations

import json

import pytest

import ask
from app.db import SessionLocal
from app.models import Answer, Job
from app.services import events
from app.worker import run_ask_job

from .conftest import make_job


def _result(answer_id: str) -> ask.AskResult:
    paper = {"n": 1, "pmid": "39133485", "doi": "10.1/x", "pmcid": "PMC1", "title": "T", "year": "2024",
             "journal": "JAMA Netw Open", "issn": "2574-3805", "authors": "Chuang MH", "quartile": "Q1",
             "rank": None, "source": "pmc", "relevance": 2,
             "paras": [{"id": 1, "sec": "Abstract", "page": None, "text": "x"}],
             "cites": [{"pid": 1, "verified": True}, {"pid": 2, "verified": False}]}
    return ask.AskResult(run_id=answer_id, question="测试问题", question_en="test question",
                         queries=["q1"], filters_label="无", papers=[paper], used_n=[1],
                         body_md="结论 [1¶1]", answer_md="# Q\n\n结论 [1¶1](x.md#p1)",
                         citations=[{"n": 1, "pmid": "39133485", "pid": 1, "sec": "Abstract", "page": None,
                                     "text": "x", "quotes": ["x"], "from_marker": True}],
                         kb_hits=[], out_path="/tmp/x.md", papers_dir="/tmp/x_papers", n_fulltext=1)


def _stream(sync_redis, job_id: str) -> list[tuple[str, dict]]:
    entries = sync_redis.xrange(events.stream_key(job_id))
    out = []
    for _id, fields in entries:
        kind = fields[b"type"].decode()
        out.append((kind, json.loads(fields[b"data"].decode())))
    return out


async def test_successful_job_persists_answer_and_emits_succeeded(worker_ctx, sync_redis, monkeypatch):
    job_id, answer_id = make_job()
    monkeypatch.setattr(ask, "run_ask", lambda opts, **kw: _result(answer_id))

    await run_ask_job(worker_ctx, job_id)

    with SessionLocal() as db:
        job, answer = db.get(Job, job_id), db.get(Answer, answer_id)
        assert job.status == "succeeded"
        assert job.result == {"answer_id": answer_id}
        assert job.finished_at is not None
        assert answer.status == "ready"
        assert answer.n_papers == 1 and answer.n_fulltext == 1
        assert answer.papers[0]["n"] == 1
        assert answer.papers[0]["rank_label"] == "分区未知"
        assert answer.papers[0]["n_citations"] == 2
        assert answer.papers[0]["n_citations_verified"] == 1
        assert answer.citations[0]["pid"] == 1
        assert answer.body_md == "结论 [1¶1]"

    kind, data = _stream(sync_redis, job_id)[-1]
    assert kind == "succeeded"
    assert data == {"answer_id": answer_id}


async def test_pipeline_error_marks_job_failed_with_code(worker_ctx, sync_redis, monkeypatch):
    job_id, answer_id = make_job()

    def boom(opts, **kw):
        raise ask.NoPapers("no papers pass the filters")

    monkeypatch.setattr(ask, "run_ask", boom)
    await run_ask_job(worker_ctx, job_id)

    with SessionLocal() as db:
        job, answer = db.get(Job, job_id), db.get(Answer, answer_id)
        assert job.status == "failed"
        assert job.error["code"] == "no_papers"
        assert answer.status == "failed"
        assert answer.error["code"] == "no_papers"

    kind, data = _stream(sync_redis, job_id)[-1]
    assert kind == "failed"
    assert data["code"] == "no_papers"


async def test_cancel_requested_before_start_skips_pipeline(worker_ctx, sync_redis, monkeypatch):
    job_id, answer_id = make_job()
    sync_redis.set(events.cancel_key(job_id), "1")
    called = False

    def never(opts, **kw):
        nonlocal called
        called = True
        raise AssertionError("pipeline must not start for a cancelled job")

    monkeypatch.setattr(ask, "run_ask", never)
    await run_ask_job(worker_ctx, job_id)

    assert called is False
    with SessionLocal() as db:
        assert db.get(Job, job_id).status == "cancelled"
        assert db.get(Answer, answer_id).status == "cancelled"
    assert _stream(sync_redis, job_id)[-1][0] == "cancelled"


async def test_progress_events_land_in_job_row(worker_ctx, sync_redis, monkeypatch):
    job_id, answer_id = make_job()

    def with_progress(opts, *, run_id, emit, should_cancel):
        emit({"type": "progress", "stage": "read", "current": 2, "total": 3, "pmid": "1", "title": "t"})
        return _result(run_id)

    monkeypatch.setattr(ask, "run_ask", with_progress)
    await run_ask_job(worker_ctx, job_id)

    kinds = [k for k, _ in _stream(sync_redis, job_id)]
    assert kinds == ["progress", "succeeded"]


@pytest.mark.parametrize("options, expected", [
    ({"question": "q", "year_from": 2020, "year_to": 2024}, "2020-2024"),
    ({"question": "q", "year_from": 2021}, "2021-2021"),
    ({"question": "q", "years": 3}, ""),
])
def test_year_options_map_to_cli_range(options, expected):
    from app.services.answers import to_ask_options

    assert to_ask_options(options).year == expected


def test_quartiles_and_journals_map_to_cli_strings():
    from app.services.answers import to_ask_options

    opts = to_ask_options({"question": "q", "quartiles": [2, 1, 1], "journals": ["Lancet", "JAMA"]})
    assert opts.quartile == "Q1,Q2"
    assert opts.journal == "Lancet,JAMA"
