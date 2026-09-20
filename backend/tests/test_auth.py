"""Bearer 会话鉴权、统一错误响应和不接受 URL 令牌的边界。"""
from __future__ import annotations

from .conftest import USER_TOKEN, auth, make_job


def test_missing_token_returns_problem_json_with_challenge(client):
    r = client.get("/v1/answers")
    assert r.status_code == 401
    assert r.headers["content-type"].startswith("application/problem+json")
    assert r.headers["www-authenticate"] == "Bearer"
    body = r.json()
    assert body["code"] == "unauthenticated"
    assert body["type"] == "urn:picoseek:error:unauthenticated"
    assert body["instance"] == "/v1/answers"


def test_invalid_token_is_unauthenticated(client):
    r = client.get("/v1/answers", headers=auth("nope"))
    assert r.status_code == 401
    assert r.json()["code"] == "unauthenticated"


def test_unicode_query_token_is_unauthenticated(client):
    r = client.get("/v1/jobs/nonexistent/events", params={"access_token": "\u00e9"})
    assert r.status_code == 401
    assert r.json()["code"] == "unauthenticated"
    assert r.headers["www-authenticate"] == "Bearer"


def test_regular_user_can_create_and_read_own_answer(client):
    response = client.post("/v1/answers", json={"question": "问题"}, headers=auth(USER_TOKEN))
    assert response.status_code == 202
    assert client.get(response.headers["location"], headers=auth(USER_TOKEN)).status_code == 200


def test_health_endpoints_need_no_session(client):
    assert client.get("/v1/health").status_code == 200
    assert client.get("/v1/health/ready").status_code in (200, 503)


def test_sse_rejects_access_token_query_param(client, sync_redis):
    job_id, _ = make_job(user_id="reader", status="succeeded")

    r = client.get(f"/v1/jobs/{job_id}/events", params={"access_token": USER_TOKEN})
    assert r.status_code == 401

    assert client.get(f"/v1/jobs/{job_id}/events").status_code == 401
    # 普通端点不认 query token
    assert client.get(f"/v1/jobs/{job_id}", params={"access_token": USER_TOKEN}).status_code == 401


def test_sse_uses_only_bearer_even_when_query_token_is_present(client):
    job_id, _ = make_job(user_id="reader", status="cancelled")
    url = f"/v1/jobs/{job_id}/events"
    assert client.get(url, headers=auth(USER_TOKEN),
                      params={"access_token": "invalid"}).status_code == 200
    assert client.get(url, headers=auth("invalid"),
                      params={"access_token": USER_TOKEN}).status_code == 401
