"""机构访问登录态端点：观测对所有登录用户开放，替换/清除只给管理员。

登录态是进程外的三个文件，用 autouse fixture 前后清干净，避免与其他测试文件的
执行顺序耦合。
"""
from __future__ import annotations

import json
import os

import pytest
import spider_auth
from picos_paths import PAYWALL_STATE

from app.services import paywall as service

from .conftest import ADMIN_TOKEN, USER_TOKEN, auth

MINIMAL_STATE = json.dumps({"cookies": [], "origins": []}).encode()


@pytest.fixture(autouse=True)
def clean_state():
    service.clear_state()
    yield
    service.clear_state()


def _upload(client, token, **files):
    return client.put("/v1/paywall/state", files=files, headers=auth(token))


def test_status_reports_unconfigured(client):
    body = client.get("/v1/paywall/status", headers=auth(USER_TOKEN)).json()
    assert body["configured"] is False
    assert body["saved_at"] is None
    assert body["has_session_storage"] is False
    assert body["playwright_available"] is True


def test_upload_requires_admin(client):
    response = _upload(client, USER_TOKEN, storage_state=("sd.json", MINIMAL_STATE, "application/json"))
    assert response.status_code == 403
    assert client.get("/v1/paywall/status", headers=auth(USER_TOKEN)).json()["configured"] is False


def test_admin_upload_then_clear(client):
    response = _upload(client, ADMIN_TOKEN, storage_state=("sd.json", MINIMAL_STATE, "application/json"))
    assert response.status_code == 200
    body = response.json()
    assert body["configured"] is True
    assert body["saved_at"].endswith("Z")
    assert body["has_context_meta"] is False
    assert os.path.isfile(PAYWALL_STATE)

    assert client.delete("/v1/paywall/state", headers=auth(ADMIN_TOKEN)).status_code == 204
    assert client.get("/v1/paywall/status", headers=auth(USER_TOKEN)).json()["configured"] is False
    assert not os.path.exists(PAYWALL_STATE)


def test_upload_exposes_final_url_from_context_meta(client):
    meta = json.dumps({"final_url": "https://www.sciencedirect.com/"}).encode()
    response = _upload(client, ADMIN_TOKEN,
                       storage_state=("sd.json", MINIMAL_STATE, "application/json"),
                       context_meta=("ctx.json", meta, "application/json"))
    body = response.json()
    assert body["final_url"] == "https://www.sciencedirect.com/"
    assert body["has_context_meta"] is True


def test_optional_files_are_kept_when_not_resupplied(client):
    session = json.dumps({"https://x": {"k": "v"}}).encode()
    _upload(client, ADMIN_TOKEN,
            storage_state=("sd.json", MINIMAL_STATE, "application/json"),
            session_storage=("ss.json", session, "application/json"))
    body = _upload(client, ADMIN_TOKEN,
                   storage_state=("sd.json", MINIMAL_STATE, "application/json")).json()
    assert body["has_session_storage"] is True
    paths = spider_auth.state_paths(PAYWALL_STATE)
    assert json.loads(open(paths.session_storage, encoding="utf-8").read()) == {"https://x": {"k": "v"}}


def test_non_json_state_is_rejected_and_nothing_is_written(client):
    response = _upload(client, ADMIN_TOKEN, storage_state=("sd.json", b"not json", "application/json"))
    assert response.status_code == 422
    assert response.json()["code"] == "validation_error"
    assert not os.path.exists(PAYWALL_STATE)


def test_json_without_cookies_is_rejected(client):
    response = _upload(client, ADMIN_TOKEN,
                       storage_state=("sd.json", json.dumps({"origins": []}).encode(), "application/json"))
    assert response.status_code == 422
    assert not os.path.exists(PAYWALL_STATE)


def test_bad_optional_file_does_not_replace_storage_state(client):
    _upload(client, ADMIN_TOKEN, storage_state=("sd.json", MINIMAL_STATE, "application/json"))
    before = os.path.getmtime(PAYWALL_STATE)
    response = _upload(client, ADMIN_TOKEN,
                       storage_state=("sd.json", MINIMAL_STATE, "application/json"),
                       context_meta=("ctx.json", b"[]", "application/json"))
    assert response.status_code == 422
    assert os.path.getmtime(PAYWALL_STATE) == before


def test_delete_requires_admin(client):
    _upload(client, ADMIN_TOKEN, storage_state=("sd.json", MINIMAL_STATE, "application/json"))
    assert client.delete("/v1/paywall/state", headers=auth(USER_TOKEN)).status_code == 403
    assert os.path.isfile(PAYWALL_STATE)
