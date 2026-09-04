"""鉴权与 scope：错误体形状、scope 不足、SSE 的 query token 例外。"""
from __future__ import annotations

from .conftest import READ_KEY, WRITE_KEY, auth, make_job


def test_missing_key_returns_problem_json_with_challenge(client):
    r = client.get("/v1/answers")
    assert r.status_code == 401
    assert r.headers["content-type"].startswith("application/problem+json")
    assert r.headers["www-authenticate"] == "Bearer"
    body = r.json()
    assert body["code"] == "unauthenticated"
    assert body["type"] == "urn:yaoe:error:unauthenticated"
    assert body["instance"] == "/v1/answers"


def test_invalid_key_is_unauthenticated(client):
    r = client.get("/v1/answers", headers=auth("nope"))
    assert r.status_code == 401
    assert r.json()["code"] == "unauthenticated"


def test_read_scope_cannot_create_answers(client):
    r = client.post("/v1/answers", json={"question": "问题"}, headers=auth(READ_KEY))
    assert r.status_code == 403
    assert r.json()["code"] == "forbidden"


def test_write_scope_can_read_and_write(client):
    assert client.get("/v1/answers", headers=auth(WRITE_KEY)).status_code == 200


def test_health_endpoints_need_no_key(client):
    assert client.get("/v1/health").status_code == 200
    assert client.get("/v1/health/ready").status_code in (200, 503)


def test_sse_accepts_access_token_query_param(client, sync_redis):
    """浏览器 EventSource 不能设 header，所以只有 SSE 端点接受 ?access_token=。"""
    job_id, _ = make_job(api_key_id="reader", status="succeeded")

    r = client.get(f"/v1/jobs/{job_id}/events", params={"access_token": READ_KEY})
    assert r.status_code == 200

    assert client.get(f"/v1/jobs/{job_id}/events").status_code == 401
    # 普通端点不认 query token
    assert client.get(f"/v1/jobs/{job_id}", params={"access_token": READ_KEY}).status_code == 401
