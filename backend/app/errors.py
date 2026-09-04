"""统一错误响应：RFC 9457 Problem Details（application/problem+json）。

对外只暴露稳定的 `code` 枚举，前端据此分支；`detail` 是给人看的，随时可能改。
内部异常一律收敛成 500 internal_error，绝不把堆栈或 SQL 泄给调用方。
"""
from __future__ import annotations

import http
import logging

from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException as StarletteHTTPException

logger = logging.getLogger("yaoe.errors")

PROBLEM_MEDIA_TYPE = "application/problem+json"

# HTTP 状态码 -> 默认 code（StarletteHTTPException 走这条路，例如路由未命中）
STATUS_CODES = {
    401: "unauthenticated",
    403: "forbidden",
    404: "not_found",
    405: "not_found",
    409: "conflict",
    422: "validation_error",
    429: "too_many_jobs",
    502: "upstream_unavailable",
    503: "unavailable",
}


class ApiError(Exception):
    """业务层抛的错误：状态码 + 稳定 code + 人类可读 detail。"""

    def __init__(self, status: int, code: str, detail: str, extra: dict | None = None,
                 headers: dict[str, str] | None = None):
        super().__init__(f"{status} {code}: {detail}")
        self.status = status
        self.code = code
        self.detail = detail
        self.extra = extra or {}
        self.headers = headers or {}


def problem(request: Request, status: int, code: str, detail: str,
            extra: dict | None = None, headers: dict[str, str] | None = None) -> JSONResponse:
    body = {
        "type": f"urn:yaoe:error:{code}",
        "title": http.HTTPStatus(status).phrase,
        "status": status,
        "detail": detail,
        "instance": request.url.path,
        "code": code,
        **(extra or {}),
    }
    return JSONResponse(body, status_code=status, media_type=PROBLEM_MEDIA_TYPE, headers=headers)


def register_handlers(app: FastAPI) -> None:
    @app.exception_handler(ApiError)
    async def _api_error(request: Request, exc: ApiError) -> JSONResponse:
        return problem(request, exc.status, exc.code, exc.detail, exc.extra, exc.headers)

    @app.exception_handler(RequestValidationError)
    async def _validation(request: Request, exc: RequestValidationError) -> JSONResponse:
        errors = [{"loc": [str(x) for x in e.get("loc", [])], "msg": e.get("msg", ""), "type": e.get("type", "")}
                  for e in exc.errors()]
        detail = errors[0]["msg"] if errors else "request validation failed"
        return problem(request, 422, "validation_error", detail, {"errors": errors})

    @app.exception_handler(StarletteHTTPException)
    async def _http(request: Request, exc: StarletteHTTPException) -> JSONResponse:
        code = STATUS_CODES.get(exc.status_code, "internal_error" if exc.status_code >= 500 else "conflict")
        detail = exc.detail if isinstance(exc.detail, str) else http.HTTPStatus(exc.status_code).phrase
        return problem(request, exc.status_code, code, detail, headers=dict(exc.headers or {}))

    @app.exception_handler(Exception)
    async def _unhandled(request: Request, exc: Exception) -> JSONResponse:
        logger.exception("unhandled error on %s %s", request.method, request.url.path)
        return problem(request, 500, "internal_error", "internal server error")
