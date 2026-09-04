"""SSE 进度流：回放、Last-Event-ID 续传、流过期后的合成终态。"""
from __future__ import annotations

import json

from app.config import settings
from app.db import SessionLocal
from app.models import Job
from app.services import events

from .conftest import READ_KEY, WRITE_KEY, auth, make_job

PUB = {"maxlen": settings.events_maxlen, "ttl_s": settings.events_ttl_s}


def parse_sse(text: str) -> list[dict]:
    """把原始 SSE 文本拆成 [{id, event, data}]，忽略心跳注释行。"""
    out, cur = [], {}
    for line in text.splitlines():
        if not line.strip():
            if cur:
                out.append(cur)
                cur = {}
            continue
        if line.startswith(":"):
            continue
        field, _, value = line.partition(":")
        value = value.lstrip()
        if field == "data":
            cur["data"] = json.loads(value)
        elif field in ("id", "event"):
            cur[field] = value
    if cur:
        out.append(cur)
    return out


def test_stream_replays_from_beginning_and_stops_at_terminal(client, sync_redis):
    job_id, answer_id = make_job(api_key_id="reader")
    events.publish(sync_redis, job_id, {"type": "stage", "stage": "search", "status": "started"}, **PUB)
    events.publish(sync_redis, job_id,
                   {"type": "progress", "stage": "read", "current": 1, "total": 2}, **PUB)
    events.publish(sync_redis, job_id, {"type": "succeeded", "answer_id": answer_id}, **PUB)

    r = client.get(f"/v1/jobs/{job_id}/events", headers=auth(READ_KEY))
    assert r.status_code == 200
    assert r.headers["content-type"].startswith("text/event-stream")
    got = parse_sse(r.text)
    assert [e["event"] for e in got] == ["stage", "progress", "succeeded"]
    assert got[1]["data"] == {"stage": "read", "current": 1, "total": 2}
    assert got[2]["data"] == {"answer_id": answer_id}
    assert all(e["id"] for e in got), "每条事件都要带 id，否则无法续传"


def test_last_event_id_resumes_after_that_entry(client, sync_redis):
    job_id, answer_id = make_job(api_key_id="reader")
    first = events.publish(sync_redis, job_id,
                           {"type": "progress", "stage": "read", "current": 1, "total": 2}, **PUB)
    events.publish(sync_redis, job_id,
                   {"type": "progress", "stage": "read", "current": 2, "total": 2}, **PUB)
    events.publish(sync_redis, job_id, {"type": "succeeded", "answer_id": answer_id}, **PUB)

    r = client.get(f"/v1/jobs/{job_id}/events",
                   headers={**auth(READ_KEY), "Last-Event-ID": first})
    got = parse_sse(r.text)
    assert [e["event"] for e in got] == ["progress", "succeeded"]
    assert got[0]["data"]["current"] == 2


def test_expired_stream_synthesises_terminal_event(client, sync_redis):
    job_id, answer_id = make_job(api_key_id="reader", status="succeeded")
    with SessionLocal() as db:
        job = db.get(Job, job_id)
        job.result = {"answer_id": answer_id}
        db.commit()
    assert not sync_redis.exists(events.stream_key(job_id))

    got = parse_sse(client.get(f"/v1/jobs/{job_id}/events", headers=auth(READ_KEY)).text)
    assert len(got) == 1
    assert got[0]["event"] == "succeeded"
    assert got[0]["id"] == "0-0"
    assert got[0]["data"] == {"answer_id": answer_id}


def test_expired_stream_of_failed_job_reports_error_code(client, sync_redis):
    job_id, _ = make_job(api_key_id="reader", status="failed")
    with SessionLocal() as db:
        db.get(Job, job_id).error = {"code": "no_papers", "message": "nothing found"}
        db.commit()

    got = parse_sse(client.get(f"/v1/jobs/{job_id}/events", headers=auth(READ_KEY)).text)
    assert got[0]["event"] == "failed"
    assert got[0]["data"]["code"] == "no_papers"


def test_other_keys_job_is_invisible(client, sync_redis):
    job_id, _ = make_job(api_key_id="somebody-else")
    assert client.get(f"/v1/jobs/{job_id}", headers=auth(READ_KEY)).status_code == 404
    assert client.get(f"/v1/jobs/{job_id}/events", headers=auth(READ_KEY)).status_code == 404


def test_cancel_sets_flag_and_terminal_job_conflicts(client, sync_redis):
    job_id, _ = make_job(api_key_id="writer")
    assert client.delete(f"/v1/jobs/{job_id}", headers=auth(WRITE_KEY)).status_code == 204
    assert sync_redis.exists(events.cancel_key(job_id))

    done_id, _ = make_job(api_key_id="writer", status="succeeded")
    r = client.delete(f"/v1/jobs/{done_id}", headers=auth(WRITE_KEY))
    assert r.status_code == 409
    assert r.json()["code"] == "conflict"


def test_job_list_scopes_to_own_key_unless_admin(client, sync_redis):
    make_job(api_key_id="writer")
    make_job(api_key_id="reader")

    mine = client.get("/v1/jobs", headers=auth(READ_KEY)).json()
    assert mine["total"] == 1
    assert mine["items"][0]["api_key_id"] == "reader"

    from .conftest import ADMIN_KEY

    assert client.get("/v1/jobs", headers=auth(ADMIN_KEY)).json()["total"] == 2
    assert client.get("/v1/jobs", params={"kind": "kb_reindex"},
                      headers=auth(ADMIN_KEY)).json()["total"] == 0
