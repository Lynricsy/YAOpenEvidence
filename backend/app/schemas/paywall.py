"""机构订阅登录态的只读观测模型。

登录态本身是浏览器 cookie/storage 快照，永不外泄；这里只回报「有没有、什么时候存的、
指向哪个站点」，够前端判断付费全文能不能取到即可。
"""
from __future__ import annotations

from pydantic import BaseModel

from .common import UtcDateTime


class PaywallStatus(BaseModel):
    configured: bool                        # storage_state 文件存在
    saved_at: UtcDateTime | None = None     # storage_state 文件 mtime（UTC）
    final_url: str | None = None            # 上次登录成功后落在的站点
    has_session_storage: bool = False
    has_context_meta: bool = False
    playwright_available: bool = False      # 服务端装了 playwright 才可能下载
