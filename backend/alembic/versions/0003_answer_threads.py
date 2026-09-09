"""答案支持多轮会话与结构化工具轨迹。

Revision ID: 0003
Revises: 0002
"""
from __future__ import annotations

import sqlalchemy as sa
from alembic import op

revision = "0003"
down_revision = "0002"
branch_labels = None
depends_on = None


def upgrade() -> None:
    # trace 不能允许 NULL：老行读出来要能直接过 `list[ToolCall]` 校验。
    with op.batch_alter_table("answers") as batch:
        batch.add_column(sa.Column("parent_id", sa.String(64), nullable=True))
        batch.create_foreign_key("fk_answers_parent", "answers", ["parent_id"], ["id"],
                                 ondelete="SET NULL")
        batch.add_column(sa.Column("thread_id", sa.String(64), nullable=True))
        batch.add_column(sa.Column("trace", sa.JSON(), nullable=False, server_default="[]"))
        batch.create_index("ix_answers_thread", ["thread_id"])


def downgrade() -> None:
    with op.batch_alter_table("answers") as batch:
        batch.drop_index("ix_answers_thread")
        batch.drop_column("trace")
        batch.drop_column("thread_id")
        batch.drop_constraint("fk_answers_parent", type_="foreignkey")
        batch.drop_column("parent_id")
