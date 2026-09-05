"""HTTP 媒体类型、跨域与探针契约。"""
from __future__ import annotations

from types import SimpleNamespace
from unittest.mock import AsyncMock

import pytest
from fastapi.testclient import TestClient

from app.config import settings
from app.deps import get_arq
from app.main import create_app
from app.routers import health
from app.schemas.common import Problem


@pytest.fixture
def http_client(monkeypatch, arq):
    monkeypatch.setattr(settings, "cors_origins", ["https://frontend.example"])
    app = create_app()
    app.state.auth_disabled = True
    app.dependency_overrides[get_arq] = lambda: arq
    # 不进入 lifespan，探针依赖全部由测试控制，不连接外部服务。
    client = TestClient(app)
    yield client
    client.close()


def test_cors_allows_sse_resume_and_exposes_location(http_client):
    origin = "https://frontend.example"
    preflight = http_client.options(
        "/v1/jobs/example/events",
        headers={
            "Origin": origin,
            "Access-Control-Request-Method": "GET",
            "Access-Control-Request-Headers": "authorization,last-event-id",
        },
    )
    assert preflight.status_code == 200
    assert preflight.headers["access-control-allow-origin"] == origin
    allowed = {h.strip().lower() for h in preflight.headers["access-control-allow-headers"].split(",")}
    assert {"authorization", "last-event-id"} <= allowed

    response = http_client.post("/v1/answers", json={"question": "Does treatment reduce mortality?"},
                                headers={"Origin": origin})
    assert response.status_code == 202
    assert response.headers["access-control-allow-origin"] == origin
    exposed = {h.strip().lower() for h in response.headers["access-control-expose-headers"].split(",")}
    assert "location" in exposed
    assert http_client.get(response.headers["location"]).status_code == 200


def test_openapi_problem_media_matches_validation_and_markdown_errors(http_client):
    schema = http_client.get("/v1/openapi.json").json()
    expected = {"application/problem+json": {"schema": {"$ref": "#/components/schemas/Problem"}}}
    for path in schema["paths"].values():
        for method, operation in path.items():
            if method not in {"get", "post", "put", "patch", "delete", "head", "options", "trace"}:
                continue
            assert operation["responses"]["default"]["content"] == expected
            assert operation["responses"]["422"]["content"] == expected
    assert "Problem" in schema["components"]["schemas"]
    assert "HTTPValidationError" not in schema["components"]["schemas"]

    invalid = http_client.get("/v1/papers", params={"limit": 0})
    assert invalid.status_code == 422
    assert invalid.headers["content-type"] == "application/problem+json"
    assert Problem.model_validate(invalid.json()).code == "validation_error"
    missing = http_client.get("/v1/papers/nonexistent-paper/fulltext")
    assert missing.status_code == 404
    assert missing.headers["content-type"] == "application/problem+json"
    assert Problem.model_validate(missing.json()).code == "not_found"


@pytest.mark.parametrize("failed", [None, "db", "redis", "llm", "kb", "ranks"])
def test_readiness_status_and_declared_shape(http_client, monkeypatch, failed):
    def check(name):
        def run():
            if failed == name:
                raise RuntimeError(f"{name} unavailable")
            return {"ok": True, "detail": "ok"}
        return run

    for name in ("db", "kb", "ranks"):
        monkeypatch.setattr(health, f"_check_{name}", check(name))
    monkeypatch.setattr(health, "_check_llm", AsyncMock(return_value={
        "ok": failed != "llm", "detail": "llm unavailable" if failed == "llm" else "ok",
    }))
    http_client.app.state.redis = SimpleNamespace(ping=AsyncMock(
        side_effect=RuntimeError("redis unavailable") if failed == "redis" else None,
    ))

    response = http_client.get("/v1/health/ready")
    assert response.status_code == (503 if failed in {"db", "redis"} else 200)
    assert response.headers["content-type"] == "application/json"
    body = response.json()
    assert body["status"] == ("degraded" if failed else "ok")
    assert set(body["checks"]) == {"db", "redis", "llm", "kb", "ranks"}
    for name, dependency in body["checks"].items():
        assert dependency["ok"] is (name != failed)
        assert isinstance(dependency["detail"], str)

    schema = http_client.get("/v1/openapi.json").json()
    responses = schema["paths"]["/v1/health/ready"]["get"]["responses"]
    assert responses["200"]["content"] == responses["503"]["content"]
    reference = responses[str(response.status_code)]["content"]["application/json"]["schema"]["$ref"]
    assert reference == "#/components/schemas/ReadinessResponse"
    assert set(schema["components"]["schemas"]["ReadinessResponse"]["required"]) == set(body)
    health.ReadinessResponse.model_validate(body)

    live = http_client.get("/v1/health")
    assert live.status_code == 200
    assert live.json()["status"] == "ok"
    assert live.json()["time"].endswith("Z")
    health.HealthResponse.model_validate(live.json())
