"""用户体系迁移必须保留旧问答及任务关联，不猜测历史所有者。"""
from __future__ import annotations

import sqlite3

from alembic import command
from sqlalchemy import create_engine
from sqlalchemy.orm import Session

from app.cli import _alembic_config
from app.config import settings
from app.models import Answer, Job


def test_user_migration_preserves_legacy_answer_and_job(monkeypatch, tmp_path):
    path = tmp_path / "legacy.sqlite3"
    url = f"sqlite:///{path}"
    monkeypatch.setattr(settings, "database_url", url)
    cfg = _alembic_config()
    command.upgrade(cfg, "0001")
    with sqlite3.connect(path) as db:
        db.execute(
            "INSERT INTO jobs (id, kind, status, api_key_id, params, created_at) "
            "VALUES (?, ?, ?, ?, ?, ?)",
            ("old-job", "ask", "succeeded", "frontend-web", '{"answer_id":"old-answer"}',
             "2026-09-01 12:00:00"),
        )
        db.execute(
            "INSERT INTO answers (id, job_id, api_key_id, status, question, queries, options, "
            "papers, answer_md, citations, kb_hits, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
            ("old-answer", "old-job", "frontend-web", "ready", "旧问题", "[]", "{}", "[]",
             "# 保留的答案", "[]", "[]", "2026-09-01 12:00:00"),
        )
    command.upgrade(cfg, "head")
    engine = create_engine(url)
    try:
        with Session(engine) as db:
            answer = db.get(Answer, "old-answer")
            assert answer is not None
            job = db.get(Job, answer.job_id)
            assert job is not None
            assert answer.question == "旧问题"
            assert answer.answer_md == "# 保留的答案"
            assert answer.status == "ready"
            assert job.status == "succeeded"
            assert job.params == {"answer_id": answer.id}
            assert answer.user_id is None and job.user_id is None
        with sqlite3.connect(path) as db:
            assert db.execute("PRAGMA foreign_key_check").fetchall() == []
    finally:
        engine.dispose()
