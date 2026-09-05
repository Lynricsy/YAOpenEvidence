"""可撤销 Bearer 会话鉴权；每次从数据库读取当前用户状态与角色。"""
from __future__ import annotations

import hashlib
from collections.abc import Callable
from dataclasses import dataclass

from fastapi import Depends, Response
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy import select
from sqlalchemy.orm import Session

from .db import get_db
from .errors import ApiError
from .models import User, UserSession, utcnow

_bearer = HTTPBearer(auto_error=False, description="登录返回的可撤销会话令牌")


@dataclass(frozen=True)
class Principal:
    user_id: str
    role: str
    session_hash: str

    @property
    def is_admin(self) -> bool:
        return self.role == "admin"


def unauthenticated() -> ApiError:
    return ApiError(401, "unauthenticated", "凭证无效或已失效",
                    headers={"WWW-Authenticate": "Bearer", "Cache-Control": "no-store"})


def session_principal(db: Session, session_hash: str) -> Principal:
    row = db.execute(
        select(User.id, User.role)
        .join(UserSession, UserSession.user_id == User.id)
        .where(UserSession.token_hash == session_hash,
               UserSession.expires_at > utcnow(), User.is_active.is_(True),
               UserSession.auth_version == User.auth_version)
    ).one_or_none()
    if row is None:
        raise unauthenticated()
    return Principal(user_id=row.id, role=row.role, session_hash=session_hash)


def require(*, admin: bool = False) -> Callable[..., Principal]:
    def dependency(response: Response, db: Session = Depends(get_db),
                   creds: HTTPAuthorizationCredentials | None = Depends(_bearer)) -> Principal:
        response.headers["Cache-Control"] = "no-store"
        if creds is None:
            raise unauthenticated()
        digest = hashlib.sha256(creds.credentials.encode("utf-8")).hexdigest()
        principal = session_principal(db, digest)
        if admin and not principal.is_admin:
            raise ApiError(403, "forbidden", "仅管理员可执行此操作",
                           headers={"Cache-Control": "no-store"})
        return principal

    return dependency
