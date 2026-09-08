FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim AS base
ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy UV_PROJECT_ENVIRONMENT=/app/.venv PYTHONUNBUFFERED=1
WORKDIR /app
COPY pyproject.toml uv.lock ./
COPY core/pyproject.toml core/
COPY backend/pyproject.toml backend/
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --all-packages --no-dev --no-install-workspace
COPY core/ core/
COPY backend/ backend/
# 两棵测试树共用的根 conftest：test 阶段必须有它才能建表并搭好数据根
COPY conftest.py ./

FROM base AS runtime
RUN --mount=type=cache,target=/root/.cache/uv uv sync --frozen --all-packages --no-dev
# CODEX_HOME 落在挂载卷里：codex 会话与登录态要跨容器重启存活（provider/MCP 走内联配置，不读 config.toml）
ENV PATH=/app/.venv/bin:$PATH PICOSGPT_DATA=/data PLAYWRIGHT_BROWSERS_PATH=/ms-playwright \
    CODEX_HOME=/data/var/codex
# 机构订阅取全文与 SCImago 分区表下载都要真浏览器；缺它这两条路径只能报 fulltext_unavailable
RUN playwright install --with-deps chromium
WORKDIR /app/backend
CMD ["yaoe", "serve", "--host", "0.0.0.0", "--port", "8765"]

FROM base AS test
RUN --mount=type=cache,target=/root/.cache/uv uv sync --frozen --all-packages
ENV PATH=/app/.venv/bin:$PATH PICOSGPT_DATA=/data
WORKDIR /app
CMD ["pytest", "-q"]
