"""机构订阅登录态的观测与替换。

产品定位是「只读观测 + 管理员上传 state 文件」：应用内不做中继登录（那需要有桌面的
浏览器与人工过 SSO），主人在本地跑 `paywall_fetch login` 生成三份文件后上传到这里。

三份文件名由 core 的 `spider_auth.state_paths` 派生，必须与 `paywall_fetch` 读取时一致，
所以路径统一走 `picos_paths.PAYWALL_STATE`，不在这里另算。
"""
from __future__ import annotations

import datetime as dt
import json
import os

import ask
import spider_auth
from picos_paths import PAYWALL_STATE
from spider_auth import _json_dump_atomic

from ..errors import ApiError

MAX_STATE_BYTES = 5 * 1024 * 1024


def _paths():
    return spider_auth.state_paths(PAYWALL_STATE)


def status() -> dict:
    paths = _paths()
    configured = os.path.isfile(paths.storage_state)
    saved_at = None
    if configured:
        # 不读 context_meta.saved_at：登录脚本与手工上传两种写入者的格式并不一致
        saved_at = dt.datetime.fromtimestamp(os.path.getmtime(paths.storage_state), tz=dt.timezone.utc)
    meta = spider_auth.load_context_meta(PAYWALL_STATE)
    return {
        "configured": configured,
        "saved_at": saved_at,
        "final_url": meta.get("final_url") or meta.get("authorized_url") or None,
        "has_session_storage": os.path.isfile(paths.session_storage),
        "has_context_meta": os.path.isfile(paths.context_meta),
        "playwright_available": ask.paywall_fetch is not None,
    }


def _parse(raw: bytes, field: str, *, require_cookies: bool = False) -> dict:
    if len(raw) > MAX_STATE_BYTES:
        raise ApiError(413, "payload_too_large", f"{field} 超过 {MAX_STATE_BYTES // (1024 * 1024)} MB")
    try:
        obj = json.loads(raw)
    except (ValueError, UnicodeDecodeError) as exc:
        raise ApiError(422, "validation_error", f"{field} 不是合法 JSON") from exc
    if not isinstance(obj, dict):
        raise ApiError(422, "validation_error", f"{field} 必须是 JSON 对象")
    if require_cookies and not isinstance(obj.get("cookies"), list):
        raise ApiError(422, "validation_error", f"{field} 不是 Playwright storage_state JSON（缺 cookies 列表）")
    return obj


def save_state(storage_state: bytes, session_storage: bytes | None = None,
               context_meta: bytes | None = None) -> None:
    """整体替换登录态。未提供的可选文件保持原样（旧的 session_storage 仍然有效）。"""
    parsed = [(_paths().storage_state, _parse(storage_state, "storage_state", require_cookies=True))]
    if session_storage is not None:
        parsed.append((_paths().session_storage, _parse(session_storage, "session_storage")))
    if context_meta is not None:
        parsed.append((_paths().context_meta, _parse(context_meta, "context_meta")))
    os.makedirs(os.path.dirname(PAYWALL_STATE) or ".", exist_ok=True)
    for path, obj in parsed:      # 先全部校验通过再落盘，避免只写进去一半
        _json_dump_atomic(path, obj)


def clear_state() -> None:
    paths = _paths()
    for path in (paths.storage_state, paths.session_storage, paths.context_meta):
        try:
            os.remove(path)
        except FileNotFoundError:
            pass
