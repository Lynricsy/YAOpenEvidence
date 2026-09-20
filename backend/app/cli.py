"""`picoseek` 命令行：运行服务、迁移、离线账号管理与 OpenAPI 导出。

重依赖（uvicorn、alembic）都在子命令内部导入，避免 `picoseek --help` 也要付
导入成本。alembic 的路径按本文件定位，因此在任意 cwd 下都能跑。
"""
from __future__ import annotations

import argparse
import getpass
import json
import sys
from pathlib import Path

BACKEND_DIR = Path(__file__).resolve().parent.parent


def _alembic_config():
    from alembic.config import Config

    cfg = Config(str(BACKEND_DIR / "alembic.ini"))
    cfg.set_main_option("script_location", str(BACKEND_DIR / "alembic"))
    return cfg


def cmd_serve(args: argparse.Namespace) -> int:
    import uvicorn

    from .config import settings

    uvicorn.run("app.main:create_app", factory=True, host=args.host or settings.host,
                port=args.port or settings.port, reload=args.reload)
    return 0


def cmd_worker(_args: argparse.Namespace) -> int:
    from .worker import run

    run()
    return 0


def cmd_migrate(_args: argparse.Namespace) -> int:
    from alembic import command

    from .config import settings

    command.upgrade(_alembic_config(), "head")
    print(f"migrated: {settings.database_url}")
    return 0


def cmd_import_answers(_args: argparse.Namespace) -> int:
    from .db import SessionLocal
    from .services.answers import import_legacy_answers

    with SessionLocal() as db:
        n = import_legacy_answers(db)
    print(f"imported {n} legacy answer(s)")
    return 0


def _read_password(args: argparse.Namespace) -> str:
    if args.password_stdin:
        value = sys.stdin.readline(131).rstrip("\r\n")
        if not value:
            raise ValueError("标准输入未提供密码")
        return value
    value = getpass.getpass("密码（6-128 字符）: ")
    if value != getpass.getpass("再次输入密码: "):
        raise ValueError("两次输入的密码不一致")
    return value


def cmd_account(args: argparse.Namespace) -> int:
    from pydantic import ValidationError
    from sqlalchemy import select

    from .db import SessionLocal
    from .errors import ApiError
    from .models import User
    from .services.accounts import create_user, reset_password

    try:
        password = _read_password(args)
        with SessionLocal() as db:
            if args.cmd == "create-admin":
                user = create_user(db, username=args.username, password=password, role="admin")
                print(f"created admin: {user.username} ({user.id})")
            else:
                user = db.scalar(select(User).where(User.username == args.username.lower()))
                if user is None:
                    raise ApiError(404, "not_found", "用户不存在")
                reset_password(db, user, password)
                print(f"password reset: {user.username}; all sessions revoked")
        return 0
    except ValidationError as exc:
        print("; ".join(e["msg"] for e in exc.errors(include_input=False)), file=sys.stderr)
    except ApiError as exc:
        print(exc.detail, file=sys.stderr)
    except (ValueError, EOFError) as exc:
        print(str(exc) or "缺少密码输入", file=sys.stderr)
    return 1


def cmd_export_openapi(args: argparse.Namespace) -> int:
    from .main import create_app

    spec = create_app().openapi()
    out = Path(args.path)
    out.write_text(json.dumps(spec, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"wrote {out} ({len(spec.get('paths', {}))} paths)")
    return 0


def build_parser() -> argparse.ArgumentParser:
    ap = argparse.ArgumentParser(prog="picoseek", description="PicoSeek backend")
    sub = ap.add_subparsers(dest="cmd", required=True)

    s = sub.add_parser("serve", help="run the HTTP API")
    s.add_argument("--host", default="")
    s.add_argument("--port", type=int, default=0)
    s.add_argument("--reload", action="store_true")
    s.set_defaults(fn=cmd_serve)

    w = sub.add_parser("worker", help="run the arq task worker")
    w.set_defaults(fn=cmd_worker)

    m = sub.add_parser("migrate", help="alembic upgrade head")
    m.set_defaults(fn=cmd_migrate)

    i = sub.add_parser("import-answers", help="index existing answers/<ts>.md files into the DB")
    i.set_defaults(fn=cmd_import_answers)

    for command, help_text in (
        ("create-admin", "create an administrator account"),
        ("reset-password", "reset a user password and revoke all sessions"),
    ):
        account = sub.add_parser(command, help=help_text)
        account.add_argument("username")
        account.add_argument("--password-stdin", action="store_true",
                             help="read password from stdin instead of an interactive prompt")
        account.set_defaults(fn=cmd_account)

    e = sub.add_parser("export-openapi", help="dump the OpenAPI document")
    e.add_argument("path", nargs="?", default=str(BACKEND_DIR / "openapi.json"))
    e.set_defaults(fn=cmd_export_openapi)

    return ap


def main() -> None:
    args = build_parser().parse_args()
    raise SystemExit(args.fn(args))


if __name__ == "__main__":
    main()
