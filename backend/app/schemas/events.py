"""SSE 游标、事件数据与 OpenAPI 扩展的共同定义。"""
from __future__ import annotations

from typing import Annotated, ClassVar, Literal

from pydantic import AfterValidator, BaseModel, ConfigDict, Field, RootModel
from pydantic.json_schema import JsonSchemaValue, models_json_schema

from .common import JobError

# agent 是 codex 引擎唯一的阶段：一轮对话内部没有可枚举的固定步骤
JobStage = Literal["queries", "search", "fulltext", "read", "kb", "synthesize", "reindex", "agent"]


def _stream_id(value: str) -> str:
    if any(int(part) > 2**64 - 1 for part in value.split("-")):
        raise ValueError("stream ID components must be unsigned 64-bit integers")
    return value


StreamId = Annotated[
    str,
    Field(pattern=r"^(0|[1-9][0-9]{0,19})-(0|[1-9][0-9]{0,19})$", max_length=41),
    AfterValidator(_stream_id),
]


class EventData(BaseModel):
    model_config: ClassVar[ConfigDict] = ConfigDict(extra="forbid")


class StageEventData(EventData):
    stage: JobStage
    status: Literal["started", "finished"]
    detail: dict[str, object] = Field(default_factory=dict)


class ProgressEventData(EventData):
    stage: Literal["fulltext", "read", "kb", "reindex"]
    current: int = Field(ge=0)
    total: int = Field(ge=0)
    pmid: str | None = None
    title: str | None = None


class LogEventData(EventData):
    level: Literal["info", "warning"]
    message: str


ToolCallStatus = Literal["started", "completed", "failed"]


class ToolCall(EventData):
    """agent 的一次工具调用；同一 `call_id` 先后发 started 与终态两条。

    既是 SSE `tool` 事件的数据，也是 `Answer.trace` 的元素——实时轨迹与落库轨迹
    必须是同一形状，客户端才能用同一套渲染。
    """

    call_id: str
    server: str
    tool: str
    status: ToolCallStatus
    args: dict[str, str | int | float | bool | None] = Field(default_factory=dict)
    duration_ms: int | None = None
    error: str | None = None


class AnswerSucceededData(EventData):
    answer_id: str


class ReindexSucceededData(EventData):
    items: int = Field(ge=0)
    papers: int = Field(ge=0)


class IngestSucceededData(EventData):
    key: str
    n_paragraphs: int = Field(ge=0)
    n_facts: int = Field(ge=0)
    items: int = Field(ge=0)


class SucceededEventData(RootModel[AnswerSucceededData | ReindexSucceededData | IngestSucceededData]):
    pass


class FailedEventData(JobError):
    model_config: ClassVar[ConfigDict] = ConfigDict(extra="forbid")


class CancelledEventData(EventData):
    pass


EVENT_MODELS: dict[str, type[BaseModel]] = {
    "stage": StageEventData,
    "progress": ProgressEventData,
    "log": LogEventData,
    "tool": ToolCall,
    "succeeded": SucceededEventData,
    "failed": FailedEventData,
    "cancelled": CancelledEventData,
}


def event_schemas() -> dict[str, JsonSchemaValue]:
    """为文本流的 x-sse-events 提供可复用的数据模型引用。"""
    _, schema = models_json_schema(
        [(model, "serialization") for model in EVENT_MODELS.values()],
        ref_template="#/components/schemas/{model}",
    )
    return schema["$defs"]
