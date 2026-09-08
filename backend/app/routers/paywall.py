"""机构订阅登录态：任何登录用户可观测，只有管理员能替换或清除。

不提供「下载登录态」端点：cookie 快照等同凭据，出去了就收不回来。
"""
from __future__ import annotations

from fastapi import APIRouter, Depends, File, Response, UploadFile

from ..auth import Principal, require
from ..errors import ApiError
from ..schemas.paywall import PaywallStatus
from ..services import paywall as service

router = APIRouter(prefix="/paywall", tags=["paywall"])
_read = require()
_admin = require(admin=True)


async def _read_file(file: UploadFile, field: str) -> bytes:
    """先看 Content-Length（multipart 里通常有），避免把超大文件整个读进内存。"""
    if file.size is not None and file.size > service.MAX_STATE_BYTES:
        raise ApiError(413, "payload_too_large",
                       f"{field} 超过 {service.MAX_STATE_BYTES // (1024 * 1024)} MB")
    return await file.read()


async def _optional(file: UploadFile | None, field: str) -> bytes | None:
    return None if file is None else await _read_file(file, field)


@router.get("/status", response_model=PaywallStatus, summary="机构访问状态")
def get_status(_principal: Principal = Depends(_read)) -> PaywallStatus:
    return PaywallStatus(**service.status())


@router.put("/state", response_model=PaywallStatus, summary="上传机构登录态（管理员）")
async def put_state(storage_state: UploadFile = File(...),
                    session_storage: UploadFile | None = File(None),
                    context_meta: UploadFile | None = File(None),
                    _principal: Principal = Depends(_admin)) -> PaywallStatus:
    service.save_state(
        await _read_file(storage_state, "storage_state"),
        await _optional(session_storage, "session_storage"),
        await _optional(context_meta, "context_meta"),
    )
    return PaywallStatus(**service.status())


@router.delete("/state", status_code=204, summary="清除机构登录态（管理员）")
def delete_state(_principal: Principal = Depends(_admin)) -> Response:
    service.clear_state()
    return Response(status_code=204)
