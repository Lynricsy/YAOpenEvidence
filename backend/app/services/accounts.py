"""账号与会话操作。写操作成功即提交，失败回滚；调用者不应混入未提交业务写入。"""
from __future__ import annotations

import datetime as dt
import hashlib
import secrets
import uuid

from argon2 import PasswordHasher, Type
from argon2.exceptions import InvalidHashError, VerificationError
from sqlalchemy import delete, func, select, update
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from ..auth import unauthenticated
from ..config import settings
from ..errors import ApiError
from ..models import User, UserSession, utcnow
from ..schemas.users import LoginResponse, UserRead, normalize_username

_hasher = PasswordHasher(type=Type.ID)
# 不存在的账号也执行相同 Argon2 校验，避免快速失败暴露账号是否存在。
_dummy_hash = _hasher.hash(secrets.token_urlsafe(32))


def _hash_password(password: str) -> str:
    if not 6 <= len(password) <= 128:
        raise ValueError("密码长度须为6-128字符")
    return _hasher.hash(password)


def _verify(password_hash: str, password: str) -> bool:
    try:
        return _hasher.verify(password_hash, password)
    except (VerificationError, InvalidHashError):
        return False


def create_user(db: Session, *, username: str, password: str, role: str = "user") -> User:
    """创建账号并提交；用户名冲突回滚并返回409。供管理员API与CLI共用。"""
    username = normalize_username(username)
    if role not in {"user", "admin"}:
        raise ValueError("角色须为user或admin")
    user = User(id=uuid.uuid4().hex, username=username, password_hash=_hash_password(password),
                role=role, is_active=True, auth_version=0)
    try:
        db.add(user)
        db.commit()
    except IntegrityError:
        db.rollback()
        if db.scalar(select(User.id).where(User.username == username)) is not None:
            db.rollback()
            raise ApiError(409, "username_exists", "用户名已存在") from None
        db.rollback()
        raise
    return user


def get_user(db: Session, user_id: str) -> User:
    user = db.get(User, user_id)
    if user is None:
        raise ApiError(404, "not_found", "账号不存在")
    return user


def login(db: Session, *, username: str, password: str) -> LoginResponse:
    user = db.scalar(select(User).where(User.username == username))
    user_id = user.id if user is not None else None
    password_hash = user.password_hash if user is not None else _dummy_hash
    version = user.auth_version if user is not None else None
    active = user is not None and user.is_active
    db.rollback()
    valid = _verify(password_hash, password)
    if not valid or not active:
        raise unauthenticated()
    try:
        # 条件写入同时锁住用户行；重置先提交则拒绝，登录先提交则令牌会被重置撤销。
        result = db.execute(update(User).where(
            User.id == user_id, User.auth_version == version,
            User.password_hash == password_hash, User.is_active.is_(True),
        ).values(auth_version=User.auth_version))
        if result.rowcount != 1:
            raise unauthenticated()
        now = utcnow()
        db.execute(delete(UserSession).where(UserSession.expires_at <= now))
        token = secrets.token_urlsafe(32)
        expires_at = now + dt.timedelta(seconds=settings.session_ttl_s)
        db.add(UserSession(token_hash=hashlib.sha256(token.encode()).hexdigest(),
                           user_id=user_id, auth_version=version,
                           created_at=now, expires_at=expires_at))
        current = db.scalar(select(User).where(User.id == user_id).execution_options(populate_existing=True))
        public_user = UserRead.model_validate(current)
        db.commit()
        return LoginResponse(access_token=token, expires_at=expires_at, user=public_user)
    except Exception:
        db.rollback()
        raise


def logout(db: Session, session_hash: str) -> None:
    db.execute(delete(UserSession).where(UserSession.token_hash == session_hash))
    db.commit()


def reset_password(db: Session, user: User, new_password: str) -> None:
    """替换密码、提升凭证版本并删除全部会话，在同一个事务中提交。"""
    password_hash = _hash_password(new_password)
    try:
        db.execute(update(User).where(User.id == user.id).values(
            password_hash=password_hash, auth_version=User.auth_version + 1))
        db.execute(delete(UserSession).where(UserSession.user_id == user.id))
        db.commit()
    except Exception:
        db.rollback()
        raise


def change_password(db: Session, user_id: str, current_password: str, new_password: str) -> None:
    user = get_user(db, user_id)
    old_hash, version = user.password_hash, user.auth_version
    db.rollback()
    if not _verify(old_hash, current_password):
        raise unauthenticated()
    password_hash = _hash_password(new_password)
    try:
        result = db.execute(update(User).where(
            User.id == user_id, User.auth_version == version,
            User.password_hash == old_hash, User.is_active.is_(True),
        ).values(password_hash=password_hash, auth_version=User.auth_version + 1))
        if result.rowcount != 1:
            raise unauthenticated()
        db.execute(delete(UserSession).where(UserSession.user_id == user_id))
        db.commit()
    except Exception:
        db.rollback()
        raise


def set_active(db: Session, *, user_id: str, is_active: bool, actor_id: str) -> User:
    if not is_active and user_id == actor_id:
        raise ApiError(409, "cannot_disable_self", "不能禁用自己的账号")
    try:
        # 先锁定全部管理员行，使并发禁用操作不能各自认为另一个管理员仍然活跃。
        admin_ids = db.scalars(select(User.id).where(User.role == "admin").order_by(User.id)).all()
        for admin_id in admin_ids:
            db.execute(update(User).where(User.id == admin_id).values(auth_version=User.auth_version))
        user = db.scalar(select(User).where(User.id == user_id).execution_options(populate_existing=True))
        if user is None:
            raise ApiError(404, "not_found", "账号不存在")
        if not is_active and user.is_active and user.role == "admin":
            count = db.scalar(select(func.count()).select_from(User).where(
                User.role == "admin", User.is_active.is_(True)))
            if count <= 1:
                raise ApiError(409, "last_admin", "不能禁用最后一个活跃管理员")
        values = {"is_active": is_active}
        if not is_active:
            values["auth_version"] = User.auth_version + 1
        db.execute(update(User).where(User.id == user_id).values(**values))
        if not is_active:
            db.execute(delete(UserSession).where(UserSession.user_id == user_id))
        db.commit()
        db.refresh(user)
        return user
    except Exception:
        db.rollback()
        raise
