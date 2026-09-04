"""两棵测试树（core/tests、backend/tests）共用的测试环境。

环境变量必须在 **模块导入期** 设好：pytest 收集阶段就会 import picos_paths /
journal_rank / app.config，这些模块在导入时就把路径固化成模块级常量，
放进 fixture 里改已经太晚了。
"""
from __future__ import annotations

import json
import os
import shutil
import tempfile
from pathlib import Path
from urllib.parse import urlparse

import pytest

REPO = Path(__file__).resolve().parent
CORE = REPO / "core"
FIXTURES = CORE / "tests" / "fixtures"

_TMP = tempfile.mkdtemp(prefix="yaoe-test-")

os.environ["PICOSGPT_DATA"] = _TMP
os.environ["EMBED_MODEL"] = "/nonexistent"          # 强制 Embedder 退化为 hash-bow（无需 2G 权重）
os.environ.setdefault("YAOE_REDIS_URL", "redis://127.0.0.1:6379/15")


def assert_test_redis(url: str) -> str:
    """测试会 FLUSHDB，所以只允许打本机的高位 db。

    `YAOE_REDIS_URL` 是从环境继承的：如果开发机上它指着真实实例（几乎总是
    db 0），无条件 flush 就把别人的数据清了。宁可让测试启动失败。
    """
    parsed = urlparse(url)
    host = (parsed.hostname or "").lower()
    try:
        db = int((parsed.path or "/0").lstrip("/") or 0)
    except ValueError:
        db = 0
    if host not in ("127.0.0.1", "localhost", "::1", "redis") or db < 10:
        raise RuntimeError(
            f"refusing to run tests against {url!r}: 测试会 FLUSHDB，"
            "请把 YAOE_REDIS_URL 指向本机的 db>=10（例如 redis://127.0.0.1:6379/15）")
    return url


os.environ["YAOE_REDIS_URL"] = assert_test_redis(os.environ["YAOE_REDIS_URL"])
os.environ["YAOE_DATABASE_URL"] = f"sqlite:///{_TMP}/var/test.sqlite3"
os.environ["YAOE_API_KEYS_FILE"] = f"{_TMP}/api_keys.toml"
os.environ.setdefault("LLM_BASE", "http://127.0.0.1:4999/v1")   # 不存在的端口：测试不该真调 LLM

API_KEYS_TOML = """\
[[keys]]
id = "reader"
key = "test_read_key"
scopes = ["read"]

[[keys]]
id = "writer"
key = "test_write_key"
scopes = ["read", "write"]

[[keys]]
id = "admin"
key = "test_admin_key"
scopes = ["read", "write", "admin"]
"""


@pytest.fixture(scope="session")
def data_root() -> Path:
    return Path(_TMP)


@pytest.fixture(scope="session", autouse=True)
def _prepare_data_root() -> Path:
    """在临时 PICOSGPT_DATA 下搭一份最小但真实的数据：1 篇文献 + 分区表 + 可搜的 kb。"""
    root = Path(_TMP)
    for sub in ("answers", "library", "kb", "var", "pdfs", "data/journal_ranks"):
        (root / sub).mkdir(parents=True, exist_ok=True)
    (root / "api_keys.toml").write_text(API_KEYS_TOML, encoding="utf-8")

    paper = root / "library" / "39133485"
    paper.mkdir(exist_ok=True)
    for name in ("meta.json", "paragraphs.json", "facts.json"):
        shutil.copyfile(FIXTURES / "paper_39133485" / name, paper / name)
    meta = json.loads((paper / "meta.json").read_text(encoding="utf-8"))
    paras = json.loads((paper / "paragraphs.json").read_text(encoding="utf-8"))
    facts = json.loads((paper / "facts.json").read_text(encoding="utf-8"))

    import knowledge_store as ks

    (paper / "fulltext.md").write_text(ks.anchored_markdown(paras), encoding="utf-8")

    # 分区表 11MB，硬链接省时省盘；跨设备时退回复制
    src = CORE / "data" / "journal_ranks" / "scimagojr_2024.csv"
    dst = root / "data" / "journal_ranks" / "scimagojr_2024.csv"
    if src.exists() and not dst.exists():
        try:
            os.link(src, dst)
        except OSError:
            shutil.copyfile(src, dst)

    ks.KnowledgeStore(kb_dir=str(root / "kb")).add_paper(meta, paras, facts)

    # backend 需要建好表、清空 Redis 测试库（默认 db 15）
    from alembic import command
    from alembic.config import Config

    cfg = Config(str(REPO / "backend" / "alembic.ini"))
    cfg.set_main_option("script_location", str(REPO / "backend" / "alembic"))
    command.upgrade(cfg, "head")

    import redis

    client = redis.Redis.from_url(os.environ["YAOE_REDIS_URL"])
    client.flushdb()
    client.close()
    return root
