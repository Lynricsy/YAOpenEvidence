"""分区表的加载契约：SCImago 列格式、stats 概况、以及换表后的自动热重载。

热重载是关键行为：api 与 worker 是长驻进程，主人换表/新表落盘后不应重启即可生效。
"""
from __future__ import annotations

import os

import pytest

import journal_rank as jr

HEADER = "Title;Issn;SJR;SJR Best Quartile;H index;Categories\n"


def _write(path, quartile: str) -> None:
    path.write_text(f"{HEADER}Lancet;01406736;10,5;{quartile};700;Medicine\n", encoding="utf-8")


@pytest.fixture
def ranks(monkeypatch, tmp_path):
    """把表目录隔到 tmp_path，并清掉进程级缓存（模块全局在测试间会串味）。"""
    monkeypatch.setattr(jr, "DATA_DIR", str(tmp_path))
    monkeypatch.setattr(jr, "_SIG", None)
    monkeypatch.setattr(jr, "_TABLES", [])
    monkeypatch.setattr(jr, "_BY_ISSN", {})
    monkeypatch.setattr(jr, "_BY_TITLE", {})
    return tmp_path


def test_scimago_table_is_queryable_by_issn_and_title(ranks):
    _write(ranks / "scimagojr_2024.csv", "Q1")
    assert jr.load(force=True) == ["scimagojr_2024.csv (1 journals)"]
    assert jr.lookup(title="Lancet")["quartile"] == "Q1"
    assert jr.lookup(issn="0140-6736")["zone"] == 1
    assert jr.lookup(title="No Such Journal") is None


def test_stats_reports_year_and_index_size(ranks):
    _write(ranks / "scimagojr_2024.csv", "Q1")
    s = jr.stats()
    assert s["tables"] == [{"file": "scimagojr_2024.csv", "year": 2024, "journals": 1, "source": "scimago"}]
    assert (s["issns"], s["titles"]) == (1, 1)
    assert s["loaded_at"] > 0


def test_rewritten_table_reloads_without_force(ranks):
    path = ranks / "scimagojr_2024.csv"
    _write(path, "Q1")
    assert jr.lookup(title="Lancet")["quartile"] == "Q1"

    _write(path, "Q2")
    st = os.stat(path)
    os.utime(path, ns=(st.st_atime_ns, st.st_mtime_ns + 2_000_000_000))  # 保证 mtime 一定变化

    assert jr.lookup(title="Lancet")["quartile"] == "Q2"


def test_new_table_is_picked_up_and_empty_dir_yields_no_tables(ranks):
    assert jr.load() == []
    assert jr.stats()["issns"] == 0

    _write(ranks / "scimagojr_2024.csv", "Q3")
    assert [t["file"] for t in jr.stats()["tables"]] == ["scimagojr_2024.csv"]
    assert jr.lookup(title="Lancet")["quartile"] == "Q3"
