"""静态 API Key 鉴权 + scope。

key 放在 TOML 文件里（不入库），启动时一次读入内存。scope 只有三档：
read（所有 GET）/ write（建任务、删自己的东西）/ admin（reindex、删任意任务）。
SSE 端点额外接受 `?access_token=`，因为浏览器 EventSource 不能设 header
（RFC 6750 §2.3）。
"""
from __future__ import annotations

import hmac
import tomllib
from collections.abc import Callable
from dataclasses import dataclass
from pathlib import Path

from fastapi import Depends, Request
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from .errors import ApiError

SCOPES = ("read", "write", "admin")
_bearer = HTTPBearer(auto_error=False, description="静态 API Key（Authorization: Bearer <api_key>）")


@dataclass(frozen=True)
class Principal:
    key_id: str
    scopes: frozenset[str]

    @property
    def is_admin(self) -> bool:
        return "admin" in self.scopes


ANONYMOUS = Principal("anonymous", frozenset(SCOPES))


def load_api_keys(path: Path, *, auth_disabled: bool = False) -> dict[str, Principal]:
    """读 [[keys]] 表 -> {key: Principal}。鉴权开启时缺文件直接启动失败，避免裸奔。"""
    if not path.exists():
        if auth_disabled:
            return {}
        raise RuntimeError(
            f"api keys file not found: {path} — 复制 api_keys.example.toml 或设 YAOE_AUTH_DISABLED=1")
    data = tomllib.loads(path.read_text(encoding="utf-8"))
    out: dict[str, Principal] = {}
    for i, item in enumerate(data.get("keys") or []):
        key = str(item.get("key") or "").strip()
        key_id = str(item.get("id") or f"key{i}").strip()
        scopes = {str(s) for s in (item.get("scopes") or [])}
        if not key:
            raise RuntimeError(f"api key #{i} ({key_id}) has no 'key'")
        unknown = scopes - set(SCOPES)
        if unknown:
            raise RuntimeError(f"api key {key_id} has unknown scopes: {sorted(unknown)}")
        out[key] = Principal(key_id, frozenset(scopes))
    if not out and not auth_disabled:
        raise RuntimeError(f"no api keys defined in {path}")
    return out


def _token(request: Request, creds: HTTPAuthorizationCredentials | None, allow_query: bool) -> str:
    if creds is not None and creds.scheme.lower() == "bearer":
        return creds.credentials.strip()
    if allow_query:
        return (request.query_params.get("access_token") or "").strip()
    return ""


def _match(principals: dict[str, Principal], token: str) -> Principal | None:
    # 逐 key 常数时间比较：key 数量是个位数，遍历成本可忽略
    candidate = token.encode("utf-8")
    for known, principal in principals.items():
        if hmac.compare_digest(known.encode("utf-8"), candidate):
            return principal
    return None


def require(*scopes: str, allow_query: bool = False) -> Callable[..., Principal]:
    """依赖工厂：校验 Bearer key 并要求持有全部 `scopes`。"""
    needed = frozenset(scopes)
    unknown = needed - set(SCOPES)
    if unknown:
        raise ValueError(f"unknown scopes: {sorted(unknown)}")

    def dependency(request: Request,
                   creds: HTTPAuthorizationCredentials | None = Depends(_bearer)) -> Principal:
        if getattr(request.app.state, "auth_disabled", False):
            return ANONYMOUS
        token = _token(request, creds, allow_query)
        if not token:
            raise ApiError(401, "unauthenticated", "missing API key",
                           headers={"WWW-Authenticate": "Bearer"})
        principal = _match(request.app.state.principals, token)
        if principal is None:
            raise ApiError(401, "unauthenticated", "invalid API key",
                           headers={"WWW-Authenticate": "Bearer"})
        if not needed <= principal.scopes:
            raise ApiError(403, "forbidden", f"requires scope(s): {', '.join(sorted(needed))}")
        return principal

    return dependency
