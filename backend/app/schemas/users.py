"""请求中的账号资料；密码只以 SecretStr 进入业务层。"""
from __future__ import annotations

import re
from typing import Annotated, Literal

from pydantic import BaseModel, ConfigDict, Field, SecretStr, field_validator

from .common import UtcDateTime

Password = Annotated[SecretStr, Field(min_length=6, max_length=128)]
USERNAME_PATTERN = r"[A-Za-z0-9][A-Za-z0-9_.-]{2,63}"


def normalize_username(value: str) -> str:
    if not re.fullmatch(USERNAME_PATTERN, value):
        raise ValueError("用户名须为3-64位ASCII字母数字、下划线、横线或点，并以字母数字开头")
    return value.lower()


class LoginRequest(BaseModel):
    username: str = Field(min_length=3, max_length=64, pattern=f"^{USERNAME_PATTERN}$")
    password: Password

    _username = field_validator("username")(normalize_username)


class CreateUserRequest(LoginRequest):
    role: Literal["user", "admin"] = "user"


class PasswordChangeRequest(BaseModel):
    current_password: Password
    new_password: Password


class PasswordResetRequest(BaseModel):
    new_password: Password


class UserUpdateRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    is_active: bool


class UserRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    username: str
    role: Literal["user", "admin"]
    is_active: bool
    created_at: UtcDateTime


class LoginResponse(BaseModel):
    access_token: str
    token_type: Literal["bearer"] = "bearer"
    expires_at: UtcDateTime
    user: UserRead
