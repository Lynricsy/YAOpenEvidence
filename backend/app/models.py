"""ORM 模型：jobs（执行）与 answers（结果）。

两张表分开是因为生命周期不同：job 是一次执行（可重试、可取消、7 天后事件流
过期），answer 是长期可浏览的结果。worker 在同一个事务里同时更新两者，状态映射
queued→queued / running→running / succeeded→ready / failed→failed / cancelled→cancelled。
"""
from __future__ import annotations

import datetime as dt

from sqlalchemy import JSON, DateTime, ForeignKey, Index, Integer, String, Text
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column


def utcnow() -> dt.datetime:
    return dt.datetime.now(dt.timezone.utc)


class Base(DeclarativeBase):
    pass


class Job(Base):
    __tablename__ = "jobs"

    id: Mapped[str] = mapped_column(String(64), primary_key=True)
    kind: Mapped[str] = mapped_column(String(32))
    status: Mapped[str] = mapped_column(String(16))
    api_key_id: Mapped[str | None] = mapped_column(String(64), nullable=True)
    params: Mapped[dict] = mapped_column(JSON, default=dict)
    progress: Mapped[dict | None] = mapped_column(JSON, nullable=True)
    error: Mapped[dict | None] = mapped_column(JSON, nullable=True)
    result: Mapped[dict | None] = mapped_column(JSON, nullable=True)
    created_at: Mapped[dt.datetime] = mapped_column(DateTime(timezone=True), default=utcnow)
    started_at: Mapped[dt.datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    finished_at: Mapped[dt.datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)

    __table_args__ = (
        Index("ix_jobs_status", "status"),
        Index("ix_jobs_key_status", "api_key_id", "status"),
    )


class Answer(Base):
    __tablename__ = "answers"

    id: Mapped[str] = mapped_column(String(64), primary_key=True)
    job_id: Mapped[str | None] = mapped_column(String(64), ForeignKey("jobs.id"), nullable=True)
    api_key_id: Mapped[str | None] = mapped_column(String(64), nullable=True)
    status: Mapped[str] = mapped_column(String(16))
    question: Mapped[str] = mapped_column(Text)
    question_en: Mapped[str | None] = mapped_column(Text, nullable=True)
    queries: Mapped[list] = mapped_column(JSON, default=list)
    options: Mapped[dict] = mapped_column(JSON, default=dict)
    filters_label: Mapped[str | None] = mapped_column(String(255), nullable=True)
    n_papers: Mapped[int | None] = mapped_column(Integer, nullable=True)
    n_fulltext: Mapped[int | None] = mapped_column(Integer, nullable=True)
    papers: Mapped[list] = mapped_column(JSON, default=list)
    body_md: Mapped[str | None] = mapped_column(Text, nullable=True)
    answer_md: Mapped[str | None] = mapped_column(Text, nullable=True)
    citations: Mapped[list] = mapped_column(JSON, default=list)
    kb_hits: Mapped[list] = mapped_column(JSON, default=list)
    error: Mapped[dict | None] = mapped_column(JSON, nullable=True)
    created_at: Mapped[dt.datetime] = mapped_column(DateTime(timezone=True), default=utcnow)
    started_at: Mapped[dt.datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    finished_at: Mapped[dt.datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)

    __table_args__ = (
        Index("ix_answers_status", "status"),
        Index("ix_answers_created", "created_at"),
    )


# job.status -> answer.status
JOB_TO_ANSWER_STATUS = {
    "queued": "queued",
    "running": "running",
    "succeeded": "ready",
    "failed": "failed",
    "cancelled": "cancelled",
}
