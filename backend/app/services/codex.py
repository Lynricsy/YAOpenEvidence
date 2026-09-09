"""codex 引擎：在容器内跑 Codex agent，工具面与 CLI 时代同一套 MCP。

与 ask 流水线的分工：ask 每一步都由我们控制（检索 → 全文 → 逐篇读 → 综合），结果可复现；
codex 让模型自己决定调哪些工具，适合非标准问法与追问。两者共用 answers 资源与任务模型。

运行期形态：`openai-codex` SDK 会拉起随 wheel 附带的 codex 二进制（`openai-codex-cli-bin`），
以 `codex app-server` 的 JSON-RPC 方式通信，所以镜像里既不需要 node，也不需要 `~/.codex/config.toml`
——provider 与 MCP 全部走每次会话的内联配置，和 ask 共用 LLM_BASE / LLM_MODEL / LOCAL_QWEN_KEY。

服务端安全边界（重要，别误读）：
- `sandbox=read-only` + `approval_mode=deny_all`：模型写不了文件，也拿不到升权批准；
- `cwd` 指向 CODEX_HOME/work 这个空目录而不是代码树，只是把「默认浏览范围」挪开，
  **read-only 并不限制读取范围**，`cwd` 也只是工作目录；真正的租户隔离靠容器与运行用户，
  不靠这两个参数。多租户对外开放时，隔离必须在容器/进程层面做。
"""
from __future__ import annotations

import os
import sys
from collections.abc import Callable, Iterator
from dataclasses import dataclass, field
from typing import Any

import ask
from picos_paths import CORE_DIR, VAR_DIR

PROVIDER = "local-qwen"
CODEX_HOME = os.environ.get("CODEX_HOME") or os.path.join(VAR_DIR, "codex")
WORK_DIR = os.path.join(CODEX_HOME, "work")
AGENTS_MD = os.path.join(CORE_DIR, "AGENTS.md")
MCP_SCRIPT = os.path.join(CORE_DIR, "semantic_scholar_mcp.py")
MCP_STARTUP_TIMEOUT_S = int(os.environ.get("CODEX_MCP_STARTUP_TIMEOUT_S", "60"))
MCP_TOOL_TIMEOUT_S = int(os.environ.get("CODEX_MCP_TOOL_TIMEOUT_S", "180"))
# MCP 子进程只继承这些变量：codex 不会把 worker 的整个环境透传给工具服务
MCP_ENV_PASSTHROUGH = ("S2_API_KEY", "NCBI_API_KEY", "UNPAYWALL_EMAIL", "PICOSGPT_DATA",
                       "SD_STATE_PATH", "HOME", "PATH")


class CodexCancelled(RuntimeError):
    """协作式取消：worker 在事件边界看到取消标记后中断本轮。"""


class CodexFailed(RuntimeError):
    """一轮对话以失败告终（模型不可达、工具超时、被审批策略拒绝等）。

    与 ask.PipelineError 同一套约定：调用方据 `.code` 决定对外错误码。
    """

    code = "codex_failed"


@dataclass
class CodexResult:
    thread_id: str
    answer_md: str
    trace: list[dict[str, Any]] = field(default_factory=list)


def _mcp_env() -> dict[str, str]:
    env = {k: os.environ[k] for k in MCP_ENV_PASSTHROUGH if os.environ.get(k)}
    # 直接 `python semantic_scholar_mcp.py` 时脚本目录才是导入根；显式给出，别依赖 cwd
    env["PYTHONPATH"] = CORE_DIR
    return env


def engine_config() -> dict[str, Any]:
    """一次会话的内联配置：provider + MCP 工具 + 关掉用不上的内置工具。"""
    return {
        "model_providers": {
            PROVIDER: {
                "name": PROVIDER,
                "base_url": ask.LLM_BASE,
                "env_key": "LOCAL_QWEN_KEY",
                # codex 0.147 起只支持 responses 线协议；LiteLLM 代理提供 /v1/responses
                "wire_api": "responses",
            },
        },
        "mcp_servers": {
            "semantic_scholar": {
                "command": sys.executable,
                "args": [MCP_SCRIPT],
                "env": _mcp_env(),
                "startup_timeout_sec": MCP_STARTUP_TIMEOUT_S,
                "tool_timeout_sec": MCP_TOOL_TIMEOUT_S,
            },
        },
        # 内置联网检索由模型服务端实现，本地 provider 没有；证据必须来自 MCP 工具。
        # 开关是顶层 `web_search`：`tools.web_search` 的布尔值会被反序列化后丢弃，
        # strict-config 也不会报错，工具照样下发。
        "web_search": "disabled",
    }


def instructions() -> str:
    """CLI 时代的 AGENTS.md 就是这套检索工作流与回答格式，容器里同样只有这一份。"""
    with open(AGENTS_MD, encoding="utf-8") as f:
        return f.read()


def preflight() -> None:
    """启动前把「跑不起来」和「跑出错」分开：缺二进制/缺工具脚本要能一眼看出。"""
    try:
        from codex_cli_bin import bundled_codex_path
    except ImportError as exc:  # pragma: no cover - 依赖缺失时才会走到
        raise CodexFailed("codex runtime missing: install openai-codex-cli-bin") from exc
    binary = str(bundled_codex_path())
    if not (os.path.isfile(binary) and os.access(binary, os.X_OK)):
        raise CodexFailed(f"codex binary not executable: {binary}")
    for path in (AGENTS_MD, MCP_SCRIPT):
        if not os.path.isfile(path):
            raise CodexFailed(f"codex engine asset missing: {path}")


# SDK 的三态（外加 commandExecution 独有的 declined）压成对外契约的三态
_STATUS = {"inProgress": "started", "completed": "completed", "failed": "failed",
           "declined": "failed"}


def _args_summary(value: Any) -> dict[str, Any]:
    """工具入参只保留标量：轨迹是给人看的一行摘要，嵌套结构进不了 SSE 契约。"""
    if not isinstance(value, dict):
        return {}
    out: dict[str, Any] = {}
    for k, v in value.items():
        if isinstance(v, str):
            out[str(k)] = v[:200]
        elif isinstance(v, (int, float, bool)) or v is None:
            out[str(k)] = v
    return out


def _tool_call(item: dict[str, Any]) -> dict[str, Any] | None:
    """把一条 thread item 压成 ToolCall dict；不关心的类型返回 None。"""
    kind = item.get("type")
    if kind == "mcpToolCall":
        error = item.get("error") or {}
        return {
            "call_id": item.get("id") or "",
            "server": item.get("server") or "mcp",
            "tool": item.get("tool") or "?",
            "status": _STATUS.get(item.get("status") or "", "failed"),
            "args": _args_summary(item.get("arguments")),
            "duration_ms": item.get("duration_ms"),
            "error": error.get("message"),
        }
    if kind == "commandExecution":
        status = _STATUS.get(item.get("status") or "", "failed")
        return {
            "call_id": item.get("id") or "",
            "server": "shell",
            "tool": "exec",
            "status": status,
            "args": {"command": (item.get("command") or "")[:200]},
            "duration_ms": item.get("duration_ms"),
            "error": f"exit {item.get('exit_code')}" if status == "failed" else None,
        }
    return None


def _drain(stream: Iterator[Any], *, emit: Callable[[dict], None],
           should_cancel: Callable[[], bool],
           interrupt: Callable[[], None]) -> tuple[str, list[dict[str, Any]]]:
    text = ""
    trace: list[dict[str, Any]] = []
    cancelled = False
    for event in stream:
        if not cancelled and should_cancel():
            cancelled = True
            interrupt()          # 让 codex 自己收尾，别硬杀进程：会话文件要留完整
        payload = event.payload
        if event.method in ("item/started", "item/completed"):
            item = payload.item.model_dump(mode="json")   # 枚举转成字符串，契约里才是 completed
            if item.get("type") == "agentMessage" and event.method == "item/completed":
                text = item.get("text") or text
            call = _tool_call(item)
            if call is not None:
                emit({"type": "tool", **call})
                if call["status"] != "started":
                    trace.append(call)
        elif event.method == "turn/completed":
            turn = payload.turn
            status = getattr(turn.status, "value", turn.status)
            if cancelled:
                raise CodexCancelled("cancelled by request")
            if status != "completed":
                detail = getattr(turn.error, "message", None) or status
                raise CodexFailed(f"codex turn {status}: {detail}")
    return text, trace


def run_codex(prompt: str, *, thread_id: str | None = None,
              emit: Callable[[dict], None] = lambda _e: None,
              should_cancel: Callable[[], bool] = lambda: False) -> CodexResult:
    """跑一轮 codex 对话；`thread_id` 非空则在原会话上追问。

    同步阻塞（SDK 是同步的），worker 里用 `asyncio.to_thread` 调。
    """
    preflight()
    os.makedirs(WORK_DIR, exist_ok=True)
    os.environ.setdefault("CODEX_HOME", CODEX_HOME)

    from openai_codex import ApprovalMode, Codex, CodexError, Sandbox

    common = {
        "model": ask.LLM_MODEL,
        "model_provider": PROVIDER,
        "sandbox": Sandbox.read_only,
        "approval_mode": ApprovalMode.deny_all,
        "cwd": WORK_DIR,
        "developer_instructions": instructions(),
        "config": engine_config(),
    }
    emit({"type": "stage", "stage": "agent", "status": "started", "detail": {"resumed": bool(thread_id)}})
    try:
        with Codex() as codex:
            thread = (codex.thread_resume(thread_id, **common) if thread_id
                      else codex.thread_start(**common))
            turn = thread.turn(prompt)
            text, trace = _drain(turn.stream(), emit=emit, should_cancel=should_cancel,
                                 interrupt=turn.interrupt)
            resolved = thread.id or thread_id or ""
    except CodexError as exc:
        raise CodexFailed(str(exc)) from exc
    if not text.strip():
        raise CodexFailed("codex returned an empty answer")
    emit({"type": "stage", "stage": "agent", "status": "finished",
          "detail": {"tool_calls": len(trace), "chars": len(text)}})
    return CodexResult(thread_id=resolved, answer_md=text, trace=trace)
