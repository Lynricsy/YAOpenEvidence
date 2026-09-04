"""`yaoe` 命令行：serve / migrate / export-openapi。

重依赖（uvicorn、alembic）都在子命令内部导入，避免 `yaoe --help` 也要付
导入成本。alembic 的路径按本文件定位，因此在任意 cwd 下都能跑。
"""
from __future__ import annotations

import argparse
import json
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


def cmd_export_openapi(args: argparse.Namespace) -> int:
    from .main import create_app

    spec = create_app().openapi()
    out = Path(args.path)
    out.write_text(json.dumps(spec, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"wrote {out} ({len(spec.get('paths', {}))} paths)")
    return 0


def build_parser() -> argparse.ArgumentParser:
    ap = argparse.ArgumentParser(prog="yaoe", description="YAOpenEvidence backend")
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

    e = sub.add_parser("export-openapi", help="dump the OpenAPI document")
    e.add_argument("path", nargs="?", default=str(BACKEND_DIR / "openapi.json"))
    e.set_defaults(fn=cmd_export_openapi)

    return ap


def main() -> None:
    args = build_parser().parse_args()
    raise SystemExit(args.fn(args))


if __name__ == "__main__":
    main()
