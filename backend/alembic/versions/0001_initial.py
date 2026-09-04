"""initial schema: jobs + answers

Revision ID: 0001
Revises:
Create Date: 2026-09-04
"""
from __future__ import annotations

import sqlalchemy as sa
from alembic import op

revision = "0001"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "jobs",
        sa.Column("id", sa.String(64), primary_key=True),
        sa.Column("kind", sa.String(32), nullable=False),
        sa.Column("status", sa.String(16), nullable=False),
        sa.Column("api_key_id", sa.String(64), nullable=True),
        sa.Column("params", sa.JSON(), nullable=False),
        sa.Column("progress", sa.JSON(), nullable=True),
        sa.Column("error", sa.JSON(), nullable=True),
        sa.Column("result", sa.JSON(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("started_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("finished_at", sa.DateTime(timezone=True), nullable=True),
    )
    op.create_index("ix_jobs_status", "jobs", ["status"])
    op.create_index("ix_jobs_key_status", "jobs", ["api_key_id", "status"])

    op.create_table(
        "answers",
        sa.Column("id", sa.String(64), primary_key=True),
        sa.Column("job_id", sa.String(64), sa.ForeignKey("jobs.id"), nullable=True),
        sa.Column("api_key_id", sa.String(64), nullable=True),
        sa.Column("status", sa.String(16), nullable=False),
        sa.Column("question", sa.Text(), nullable=False),
        sa.Column("question_en", sa.Text(), nullable=True),
        sa.Column("queries", sa.JSON(), nullable=False),
        sa.Column("options", sa.JSON(), nullable=False),
        sa.Column("filters_label", sa.String(255), nullable=True),
        sa.Column("n_papers", sa.Integer(), nullable=True),
        sa.Column("n_fulltext", sa.Integer(), nullable=True),
        sa.Column("papers", sa.JSON(), nullable=False),
        sa.Column("body_md", sa.Text(), nullable=True),
        sa.Column("answer_md", sa.Text(), nullable=True),
        sa.Column("citations", sa.JSON(), nullable=False),
        sa.Column("kb_hits", sa.JSON(), nullable=False),
        sa.Column("error", sa.JSON(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("started_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("finished_at", sa.DateTime(timezone=True), nullable=True),
    )
    op.create_index("ix_answers_status", "answers", ["status"])
    op.create_index("ix_answers_created", "answers", ["created_at"])


def downgrade() -> None:
    op.drop_index("ix_answers_created", table_name="answers")
    op.drop_index("ix_answers_status", table_name="answers")
    op.drop_table("answers")
    op.drop_index("ix_jobs_key_status", table_name="jobs")
    op.drop_index("ix_jobs_status", table_name="jobs")
    op.drop_table("jobs")
