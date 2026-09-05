"""环境配置解码与迁移连接串的边界回归。"""
from __future__ import annotations

import argparse
import sqlite3

import pytest

from app.cli import cmd_migrate
from app.config import Settings, settings


@pytest.mark.parametrize("raw", [
    "http://localhost:3000, http://localhost:5173",
    '["http://localhost:3000", "http://localhost:5173"]',
])
def test_cors_environment_formats(monkeypatch, raw):
    monkeypatch.setenv("YAOE_CORS_ORIGINS", raw)
    configured = Settings(_env_file=None)
    assert configured.cors_origins == ["http://localhost:3000", "http://localhost:5173"]


def test_cors_dotenv_comma_separated(monkeypatch, tmp_path):
    monkeypatch.delenv("YAOE_CORS_ORIGINS", raising=False)
    dotenv = tmp_path / ".env"
    dotenv.write_text("YAOE_CORS_ORIGINS=http://localhost:3000,http://localhost:5173\n")
    configured = Settings(_env_file=dotenv)
    assert configured.cors_origins == ["http://localhost:3000", "http://localhost:5173"]


def test_migration_preserves_percent_database_url(monkeypatch, tmp_path):
    path = tmp_path / "db%25.sqlite3"
    monkeypatch.setattr(settings, "database_url", f"sqlite:///{path}")
    assert cmd_migrate(argparse.Namespace()) == 0
    assert path.is_file()
    with sqlite3.connect(path) as db:
        tables = {row[0] for row in db.execute("SELECT name FROM sqlite_master WHERE type = 'table'")}
        assert {"jobs", "answers", "alembic_version"} <= tables
        assert db.execute("SELECT version_num FROM alembic_version").fetchone() is not None
