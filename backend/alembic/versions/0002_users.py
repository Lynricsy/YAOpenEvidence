"""新增用户与会话，并将业务归属切换到用户。

Revision ID: 0002
Revises: 0001
"""
from __future__ import annotations

import sqlalchemy as sa
from alembic import op

revision = "0002"
down_revision = "0001"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "users",
        sa.Column("id", sa.String(64), primary_key=True),
        sa.Column("username", sa.String(64), nullable=False),
        sa.Column("password_hash", sa.Text(), nullable=False),
        sa.Column("role", sa.String(16), nullable=False),
        sa.Column("is_active", sa.Boolean(), nullable=False),
        sa.Column("auth_version", sa.Integer(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.UniqueConstraint("username", name="uq_users_username"),
        sa.CheckConstraint("role IN ('user', 'admin')", name="ck_users_role"),
    )
    op.create_table(
        "user_sessions",
        sa.Column("token_hash", sa.String(64), primary_key=True),
        sa.Column("user_id", sa.String(64), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("auth_version", sa.Integer(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index("ix_user_sessions_user", "user_sessions", ["user_id"])
    op.create_index("ix_user_sessions_expires", "user_sessions", ["expires_at"])

    # 旧 Key 不是用户，不能按同名猜测归属；保留历史业务行，NULL 仅管理员可见。
    with op.batch_alter_table("jobs") as batch:
        batch.drop_index("ix_jobs_key_status")
        batch.add_column(sa.Column("user_id", sa.String(64), nullable=True))
        batch.create_foreign_key("fk_jobs_user", "users", ["user_id"], ["id"])
        batch.drop_column("api_key_id")
        batch.create_index("ix_jobs_user_status", ["user_id", "status"])
    with op.batch_alter_table("answers") as batch:
        batch.add_column(sa.Column("user_id", sa.String(64), nullable=True))
        batch.create_foreign_key("fk_answers_user", "users", ["user_id"], ["id"])
        batch.drop_column("api_key_id")
        batch.create_index("ix_answers_user_created", ["user_id", "created_at"])


def downgrade() -> None:
    with op.batch_alter_table("answers") as batch:
        batch.drop_index("ix_answers_user_created")
        batch.drop_constraint("fk_answers_user", type_="foreignkey")
        batch.add_column(sa.Column("api_key_id", sa.String(64), nullable=True))
        batch.drop_column("user_id")
    with op.batch_alter_table("jobs") as batch:
        batch.drop_index("ix_jobs_user_status")
        batch.drop_constraint("fk_jobs_user", type_="foreignkey")
        batch.add_column(sa.Column("api_key_id", sa.String(64), nullable=True))
        batch.drop_column("user_id")
        batch.create_index("ix_jobs_key_status", ["api_key_id", "status"])
    op.drop_table("user_sessions")
    op.drop_table("users")
