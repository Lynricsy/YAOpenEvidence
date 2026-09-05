"""管理员账号管理；文献知识库仍共享，账号凭证不通过任何读取端点输出。"""
from __future__ import annotations

from fastapi import APIRouter, Depends, Query, Response
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from ..auth import Principal, require
from ..deps import get_db
from ..models import User
from ..schemas.common import Page
from ..schemas.users import CreateUserRequest, PasswordResetRequest, UserRead, UserUpdateRequest
from ..services import accounts

router = APIRouter(prefix="/users", tags=["users"])
_admin = require(admin=True)


@router.post("", status_code=201, response_model=UserRead, summary="创建账号",
             responses={201: {"headers": {"Location": {
                 "schema": {"type": "string"}, "description": "新建用户的资源地址",
             }}}})
def create_user(body: CreateUserRequest, response: Response,
                principal: Principal = Depends(_admin), db: Session = Depends(get_db)):
    user = accounts.create_user(db, username=body.username,
                                password=body.password.get_secret_value(), role=body.role)
    response.headers["Location"] = f"/v1/users/{user.id}"
    return user


@router.get("", response_model=Page[UserRead], summary="浏览账号")
def list_users(limit: int = Query(20, ge=1, le=100), offset: int = Query(0, ge=0),
               principal: Principal = Depends(_admin), db: Session = Depends(get_db)):
    total = db.scalar(select(func.count()).select_from(User)) or 0
    users = db.scalars(select(User).order_by(User.created_at, User.id).limit(limit).offset(offset)).all()
    return Page[UserRead](items=[UserRead.model_validate(user) for user in users],
                          total=total, limit=limit, offset=offset)


@router.get("/{user_id}", response_model=UserRead, summary="读取账号")
def get_user(user_id: str, principal: Principal = Depends(_admin), db: Session = Depends(get_db)):
    return accounts.get_user(db, user_id)


@router.patch("/{user_id}", response_model=UserRead, summary="启用或禁用账号")
def update_user(user_id: str, body: UserUpdateRequest,
                principal: Principal = Depends(_admin), db: Session = Depends(get_db)):
    return accounts.set_active(db, user_id=user_id, is_active=body.is_active, actor_id=principal.user_id)


@router.post("/{user_id}/password", status_code=204, summary="重置密码并注销全部会话")
def reset_password(user_id: str, body: PasswordResetRequest,
                   principal: Principal = Depends(_admin), db: Session = Depends(get_db)) -> None:
    accounts.reset_password(db, accounts.get_user(db, user_id), body.new_password.get_secret_value())
