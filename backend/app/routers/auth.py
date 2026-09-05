"""登录、注销与当前账号操作。限流异步访问Redis，数据库与Argon2在线程池执行。"""
from __future__ import annotations

import hashlib

from fastapi import APIRouter, Depends, Response
from redis.asyncio import Redis
from redis.exceptions import RedisError
from sqlalchemy.orm import Session
from starlette.concurrency import run_in_threadpool

from ..auth import Principal, require
from ..config import settings
from ..deps import get_db, get_redis
from ..errors import ApiError
from ..schemas.users import LoginRequest, LoginResponse, PasswordChangeRequest, UserRead
from ..services import accounts

router = APIRouter(prefix="/auth", tags=["auth"])
_authenticated = require()
_LOGIN_LIMIT = """
local count = redis.call('INCR', KEYS[1])
if count == 1 then redis.call('EXPIRE', KEYS[1], ARGV[1]) end
return {count, redis.call('TTL', KEYS[1])}
"""


@router.post("/login", response_model=LoginResponse, summary="使用账号密码登录")
async def login(body: LoginRequest, response: Response, db: Session = Depends(get_db),
                redis: Redis = Depends(get_redis)) -> LoginResponse:
    response.headers["Cache-Control"] = "no-store"
    key = "auth:login:" + hashlib.sha256(body.username.encode("ascii")).hexdigest()
    try:
        count, ttl = await redis.eval(_LOGIN_LIMIT, 1, key, settings.login_window_s)
    except RedisError:
        raise ApiError(503, "unavailable", "登录限流服务暂不可用",
                       headers={"Cache-Control": "no-store"}) from None
    if count > settings.login_max_attempts:
        raise ApiError(429, "login_rate_limited", "登录请求过于频繁",
                       headers={"Retry-After": str(max(1, ttl)), "Cache-Control": "no-store"})
    return await run_in_threadpool(accounts.login, db, username=body.username,
                                   password=body.password.get_secret_value())


@router.post("/logout", status_code=204, summary="注销本次会话")
def logout(response: Response, principal: Principal = Depends(_authenticated),
           db: Session = Depends(get_db)) -> None:
    accounts.logout(db, principal.session_hash)
    response.headers["Cache-Control"] = "no-store"


@router.get("/me", response_model=UserRead, summary="读取当前账号")
def me(principal: Principal = Depends(_authenticated), db: Session = Depends(get_db)):
    return accounts.get_user(db, principal.user_id)


@router.post("/password", status_code=204, summary="修改密码并注销全部会话")
def change_password(body: PasswordChangeRequest, principal: Principal = Depends(_authenticated),
                    db: Session = Depends(get_db)) -> None:
    accounts.change_password(db, principal.user_id, body.current_password.get_secret_value(),
                             body.new_password.get_secret_value())
