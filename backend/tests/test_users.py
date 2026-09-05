"""真实账号/会话生命周期与管理员边界回归。"""
from __future__ import annotations

import datetime as dt
import hashlib

import pytest
from redis.exceptions import ConnectionError as RedisConnectionError
from sqlalchemy import select

from app.config import settings
from app.db import SessionLocal
from app.deps import get_redis
from app.errors import ApiError
from app.models import User, UserSession, utcnow
from app.services import accounts
from .conftest import ADMIN_TOKEN, PASSWORD, USER_TOKEN, auth

NEW_PASSWORD = "New-testing-password!2"


def login(client, username="reader", password=PASSWORD):
    return client.post("/v1/auth/login", json={"username": username, "password": password})


def test_bad_credentials_and_validation_do_not_leak_secrets(client):
    wrong = "Incorrect-password!1"
    existing = login(client, password=wrong)
    unknown = login(client, username="nobody", password=wrong)
    assert existing.status_code == unknown.status_code == 401
    assert existing.json() == unknown.json()
    assert wrong not in existing.text
    invalid = login(client, password="private")
    assert invalid.status_code == 422
    assert "private" not in invalid.text
    assert client.get("/v1/auth/me", params={"access_token": USER_TOKEN}).status_code == 401


def test_login_logout_only_revokes_one_session(client):
    result = login(client)
    assert result.status_code == 200
    token = result.json()["access_token"]
    assert result.headers["cache-control"] == "no-store"
    assert set(result.json()["user"]) == {"id", "username", "role", "is_active", "created_at"}
    with SessionLocal() as db:
        session = db.get(UserSession, hashlib.sha256(token.encode()).hexdigest())
        assert session is not None
        assert db.get(UserSession, token) is None
    assert client.get("/v1/auth/me", headers=auth(token)).json()["id"] == "reader"
    assert client.post("/v1/auth/logout", headers=auth(token)).status_code == 204
    assert client.get("/v1/auth/me", headers=auth(token)).status_code == 401
    assert client.get("/v1/auth/me", headers=auth(USER_TOKEN)).status_code == 200


def test_expired_session_is_rejected_and_collected_on_login(client):
    digest = hashlib.sha256(USER_TOKEN.encode()).hexdigest()
    with SessionLocal() as db:
        db.get(UserSession, digest).expires_at = utcnow() - dt.timedelta(seconds=1)
        db.commit()
    assert client.get("/v1/auth/me", headers=auth(USER_TOKEN)).status_code == 401
    assert login(client).status_code == 200
    with SessionLocal() as db:
        assert db.get(UserSession, digest) is None


def test_password_change_revokes_all_sessions_and_checks_current_password(client):
    token = login(client).json()["access_token"]
    denied = client.post("/v1/auth/password", headers=auth(USER_TOKEN), json={
        "current_password": NEW_PASSWORD, "new_password": NEW_PASSWORD})
    assert denied.status_code == 401
    assert client.get("/v1/auth/me", headers=auth(token)).status_code == 200
    changed = client.post("/v1/auth/password", headers=auth(USER_TOKEN), json={
        "current_password": PASSWORD, "new_password": NEW_PASSWORD})
    assert changed.status_code == 204
    for old in (USER_TOKEN, token):
        assert client.get("/v1/auth/me", headers=auth(old)).status_code == 401
    assert login(client).status_code == 401
    assert login(client, password=NEW_PASSWORD).status_code == 200


def test_disable_reenable_and_admin_reset_never_restore_old_sessions(client):
    token = login(client).json()["access_token"]
    disabled = client.patch("/v1/users/reader", headers=auth(ADMIN_TOKEN), json={"is_active": False})
    assert disabled.status_code == 200
    assert login(client).status_code == 401
    assert client.get("/v1/auth/me", headers=auth(token)).status_code == 401
    assert client.patch("/v1/users/reader", headers=auth(ADMIN_TOKEN),
                        json={"is_active": True}).status_code == 200
    assert client.get("/v1/auth/me", headers=auth(token)).status_code == 401
    fresh = login(client).json()["access_token"]
    assert client.post("/v1/users/reader/password", headers=auth(ADMIN_TOKEN),
                       json={"new_password": NEW_PASSWORD}).status_code == 204
    assert client.get("/v1/auth/me", headers=auth(fresh)).status_code == 401
    assert login(client).status_code == 401
    assert login(client, password=NEW_PASSWORD).status_code == 200


def test_regular_user_cannot_manage_accounts(client):
    requests = [
        ("GET", "/v1/users", None),
        ("POST", "/v1/users", {"username": "newadmin", "password": PASSWORD, "role": "admin"}),
        ("GET", "/v1/users/admin", None),
        ("PATCH", "/v1/users/admin", {"is_active": False}),
        ("POST", "/v1/users/admin/password", {"new_password": NEW_PASSWORD}),
    ]
    for method, path, body in requests:
        assert client.request(method, path, headers=auth(USER_TOKEN), json=body).status_code == 403


def test_create_case_insensitive_duplicate_and_admin_guards(client):
    created = client.post("/v1/users", headers=auth(ADMIN_TOKEN), json={
        "username": "SecondAdmin", "password": PASSWORD, "role": "admin"})
    assert created.status_code == 201
    assert created.json()["username"] == "secondadmin"
    assert client.get(created.headers["location"], headers=auth(ADMIN_TOKEN)).json() == created.json()
    duplicate = client.post("/v1/users", headers=auth(ADMIN_TOKEN), json={
        "username": "SECONDADMIN", "password": PASSWORD})
    assert duplicate.status_code == 409
    page = client.get("/v1/users", headers=auth(ADMIN_TOKEN), params={"limit": 2, "offset": 1}).json()
    assert page["total"] == 4
    assert len(page["items"]) == 2
    assert client.patch("/v1/users/admin", headers=auth(ADMIN_TOKEN),
                        json={"is_active": False}).status_code == 409
    second_id = created.json()["id"]
    second_token = login(client, username="SECONDADMIN").json()["access_token"]
    assert client.patch(f"/v1/users/{second_id}", headers=auth(ADMIN_TOKEN),
                        json={"is_active": False}).status_code == 200
    assert client.patch("/v1/users/admin", headers=auth(second_token),
                        json={"is_active": False}).status_code == 401
    # 服务边界也必须拒绝最后一个管理员，不能依赖HTTP自禁用检查作为唯一保护。
    with SessionLocal() as db:
        with pytest.raises(ApiError) as exc:
            accounts.set_active(db, user_id="admin", is_active=False, actor_id="reader")
        assert exc.value.code == "last_admin"


def test_login_rate_limit_counts_success_and_normalizes_username(client, monkeypatch):
    monkeypatch.setattr(settings, "login_max_attempts", 2)
    assert login(client).status_code == 200
    assert login(client, username="READER").status_code == 200
    blocked = login(client)
    assert blocked.status_code == 429
    assert blocked.json()["code"] == "login_rate_limited"
    assert 1 <= int(blocked.headers["retry-after"]) <= settings.login_window_s
    assert login(client, username="writer").status_code == 200


def test_login_fails_closed_without_redis(client):
    class UnavailableRedis:
        async def eval(self, *args):
            raise RedisConnectionError("unavailable")

    client.app.dependency_overrides[get_redis] = lambda: UnavailableRedis()
    try:
        assert login(client).status_code == 503
    finally:
        client.app.dependency_overrides.pop(get_redis)


def test_reset_during_password_verification_cannot_issue_old_credential_session(client, monkeypatch):
    verify = accounts._verify

    def reset_while_verifying(password_hash, password):
        valid = verify(password_hash, password)
        with SessionLocal() as db:
            accounts.reset_password(db, db.get(User, "reader"), NEW_PASSWORD)
        return valid

    monkeypatch.setattr(accounts, "_verify", reset_while_verifying)
    assert login(client).status_code == 401
    assert client.get("/v1/auth/me", headers=auth(USER_TOKEN)).status_code == 401
    with SessionLocal() as db:
        assert db.scalar(select(UserSession).where(UserSession.user_id == "reader")) is None
    monkeypatch.setattr(accounts, "_verify", verify)
    assert login(client, password=NEW_PASSWORD).status_code == 200


def test_current_role_and_auth_version_are_checked_on_each_request(client):
    with SessionLocal() as db:
        user = db.get(User, "reader")
        user.role = "admin"
        db.commit()
    assert client.get("/v1/users", headers=auth(USER_TOKEN)).status_code == 200
    with SessionLocal() as db:
        user = db.get(User, "reader")
        user.role = "user"
        db.commit()
    assert client.get("/v1/users", headers=auth(USER_TOKEN)).status_code == 403
    with SessionLocal() as db:
        user = db.get(User, "reader")
        user.auth_version += 1
        db.commit()
    assert client.get("/v1/auth/me", headers=auth(USER_TOKEN)).status_code == 401
