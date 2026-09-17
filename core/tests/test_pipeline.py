"""run_ask 流水线的契约：事件流、引用定位、落盘产物、失败与取消。

上游检索与 LLM 都换成确定性替身，但引文核实（verify_citations）用的是
真实段落文本，所以 `[n¶pid]` 里的 pid 是真算出来的，不是桩里写死的。
"""
from __future__ import annotations

import json
from pathlib import Path

import httpx
import pytest

import ask
import knowledge_store as ks
from tests.fake_llm import fake_llm

FIX = Path(__file__).parent / "fixtures" / "paper_39133485"


def _meta() -> dict:
    return json.loads((FIX / "meta.json").read_text(encoding="utf-8"))


def _paras() -> list[dict]:
    return json.loads((FIX / "paragraphs.json").read_text(encoding="utf-8"))


def _candidate() -> dict:
    m = _meta()
    return {"pmid": m["pmid"], "pmcid": m["pmcid"], "doi": m["doi"], "title": m["title"], "year": m["year"],
            "journal": m["journal"], "issn": m["issn"], "authors": m["authors"], "cited": 0,
            "types": [], "abstract": "", "rank": None, "quartile": "", "zone": 0}


@pytest.fixture
def pipeline(monkeypatch, tmp_path):
    """把流水线的外部依赖换成替身，输出目录隔到 tmp_path。"""
    answers = tmp_path / "answers"
    answers.mkdir()
    monkeypatch.setattr(ask, "ANSWERS_DIR", str(answers))
    monkeypatch.setattr(ask, "llm", lambda system, user, **kw: fake_llm(system, user))

    class IsolatedStore(ks.KnowledgeStore):
        def __init__(self):
            super().__init__(kb_dir=str(tmp_path / "kb"))

    monkeypatch.setattr(ks, "KnowledgeStore", IsolatedStore)
    monkeypatch.setattr(ks, "KB_DIR", str(tmp_path / "kb"))
    monkeypatch.setattr(ks, "LIB_DIR", str(tmp_path / "library"))

    def _search_all(queries, n_papers, flt, *, emit=ask.print_emit):
        flt.candidates = flt.kept = 1
        return [_candidate()]

    def _fetch(p, outdir, max_chars, *, emit=ask.print_emit):
        paras = _paras()
        p["paras"], p["source"] = paras, "pmc"
        p["text"] = ks.numbered_text(paras)[:max_chars]
        p["md_file"] = f"{p['pmid']}.md"
        p["fulltext_md"] = ks.anchored_markdown(paras)
        Path(outdir, p["md_file"]).write_text(p["fulltext_md"], encoding="utf-8")
        Path(outdir, f"{p['pmid']}_paragraphs.json").write_text(
            json.dumps(paras, ensure_ascii=False), encoding="utf-8")
        return p

    monkeypatch.setattr(ask, "search_all", _search_all)
    monkeypatch.setattr(ask, "fetch_fulltext", _fetch)
    return answers


def test_run_ask_produces_located_citations_and_files(pipeline):
    events: list[dict] = []
    res = ask.run_ask(ask.AskOptions(question="替西帕肽相比 GLP-1 RA 有什么获益？", papers=1, use_kb=False,
                                     use_paywall=False, workers=1),
                      run_id="testrun", emit=events.append)

    # 正文用裸标记，链接只出现在渲染稿里：前端自己决定跳转目标
    assert "[1¶2]" in res.body_md
    assert "](" not in res.body_md
    assert "[1¶2](testrun_papers/39133485.md#p2)" in res.answer_md

    assert res.used_n == [1]
    assert res.n_fulltext == 1
    assert res.citations[0]["n"] == 1
    assert res.citations[0]["pid"] == 2
    assert res.citations[0]["from_marker"] is True
    assert res.citations[0]["quotes"], "被引段落应带上核实过的引文"
    assert res.citations[0]["text"].startswith("In this cohort study")

    assert Path(pipeline, "testrun.md").exists()
    papers_dir = Path(pipeline, "testrun_papers")
    assert json.loads(Path(papers_dir, "39133485_paragraphs.json").read_text(encoding="utf-8"))
    assert Path(papers_dir, "39133485_notes.md").exists()
    cites = json.loads(Path(papers_dir, "39133485_citations.json").read_text(encoding="utf-8"))
    assert any(c["verified"] and c["pid"] == 2 for c in cites)

    stages = [(e["stage"], e["status"]) for e in events if e["type"] == "stage"]
    assert ("queries", "started") in stages and ("synthesize", "finished") in stages
    search_done = next(e for e in events if e["type"] == "stage" and e["stage"] == "search" and e["status"] == "finished")
    assert len(search_done["detail"]["papers"]) == 1
    assert search_done["detail"]["papers"][0]["pmid"] == "39133485"
    read_done = next(e for e in events if e["type"] == "stage" and e["stage"] == "read" and e["status"] == "finished")
    assert read_done["detail"] == {"relevant": 1, "total": 1}
    assert {"type": "progress", "stage": "read", "current": 1, "total": 1,
            "pmid": "39133485", "title": _meta()["title"]} in events


def test_run_ask_cancels_before_writing_answer(pipeline):
    with pytest.raises(ask.PipelineCancelled):
        ask.run_ask(ask.AskOptions(question="任意问题", papers=1, use_kb=False, use_paywall=False, workers=1),
                    run_id="cancelled", emit=lambda e: None, should_cancel=lambda: True)
    assert not Path(pipeline, "cancelled.md").exists()


def test_run_ask_without_candidates_raises_no_papers(pipeline, monkeypatch):
    monkeypatch.setattr(ask, "search_all", lambda queries, n, flt, *, emit=ask.print_emit: [])
    with pytest.raises(ask.NoPapers) as e:
        ask.run_ask(ask.AskOptions(question="任意问题", papers=1, use_kb=False, use_paywall=False),
                    run_id="empty", emit=lambda ev: None)
    assert e.value.code == "no_papers"
    assert not Path(pipeline, "empty.md").exists()


def test_llm_unavailable_raises_instead_of_empty_string(monkeypatch):
    """LLM 三次重试全失败必须抛错，而不是返回空串让空答案一路落盘。"""
    monkeypatch.setattr(ask, "LLM_BASE", "http://127.0.0.1:1/v1")   # 拒连端口
    monkeypatch.setattr(ask.time, "sleep", lambda *_: None)
    warnings: list[dict] = []
    with pytest.raises(ask.LLMUnavailable):
        ask.llm("sys", "user", emit=warnings.append)
    metrics = [json.loads(e["message"].removeprefix("llm_metrics "))
               for e in warnings if e["message"].startswith("llm_metrics ")]
    assert [m["attempt"] for m in metrics] == [1, 2, 3]
    assert all(not m["success"] and m["elapsed_s"] >= 0 for m in metrics)
    assert len({m["request_id"] for m in metrics}) == 3


@pytest.mark.parametrize(("content", "reason", "message"), [
    (None, "length", "truncated"),
    ("尚未写完的证据", "length", "truncated"),
    ("   ", "stop", "empty"),
    ("<think>仅有推理，没有正文</think>", "stop", "empty"),
])
def test_llm_rejects_incomplete_answers(monkeypatch, content, reason, message):
    """HTTP 200 不等于答案完成；推理耗尽预算和空正文都不能作为成功结果返回。"""
    response = httpx.Response(200, request=httpx.Request("POST", "http://llm/chat/completions"),
                              json={"choices": [{"finish_reason": reason,
                                                 "message": {"content": content}}]})
    monkeypatch.setattr(ask.httpx, "post", lambda *a, **kw: response)
    monkeypatch.setattr(ask.time, "sleep", lambda *_: None)
    with pytest.raises(ask.LLMUnavailable, match=message):
        ask.llm("system", "question", think=True)


@pytest.mark.parametrize(("notes", "expected"), [
    # 提示词要求逐字照抄 `### Relevance (0-3)`，分值写在下一行：曾把范围下限 0 当分值，整轮问答被判无相关文献
    ("### Relevance (0-3)\n2 — directly addresses the question.\n### P — Patient\nAdults.", 2),
    ("### Relevance (0-3)\n**0** — reports neither drug separately.", 0),
    ("### Relevance (2)\n### P — Patient\nAdults.", 2),          # 分值写在标题行内
    ("Relevance 0", 0),                                          # READ_SYS 末句要求的裸写法：不相关就此收尾
    ("Relevance 0\n", 0),
    ("### Relevance 0-3\n1", 1),                                 # 标题里的范围不带括号时也不能当分值
    ("### Relevance (0-3)\nScore not stated.", 1),               # 解析不出时保守纳入
])
def test_parse_relevance_reads_the_score_not_the_range(notes, expected):
    assert ask.parse_relevance(notes) == expected


def test_papers_without_text_are_not_treated_as_relevant():
    p = ask.read_paper(1, {"pmid": "1", "text": ""}, "question")
    assert p["relevance"] == 0


def test_deferred_snapshot_recovers_after_index_failure(pipeline, monkeypatch, tmp_path):
    original_extract = ks.extract_facts
    monkeypatch.setattr(ks, "extract_facts", lambda *a, **kw: pytest.fail("foreground extracted facts"))
    res = ask.run_ask(ask.AskOptions(question="benefit", workers=1, use_paywall=False),
                      run_id="deferred", defer_kb=True, emit=lambda e: None)
    assert "[1¶2]" in res.body_md
    assert not (tmp_path / "kb").exists()
    snapshot = ask.save_kb_snapshot(res)
    before = Path(res.out_path).read_bytes()
    # 输入已独立落盘，恢复不再依赖调用方保留的内存对象。
    res.papers.clear()
    monkeypatch.setattr(ks, "extract_facts", original_extract)
    real_add = ks.KnowledgeStore.add_paper
    monkeypatch.setattr(ks.KnowledgeStore, "add_paper",
                        lambda *a, **kw: (_ for _ in ()).throw(OSError("interrupted index")))
    with pytest.raises(OSError, match="interrupted index"):
        ask.index_kb_snapshot(snapshot, position=0, emit=lambda e: None)
    monkeypatch.setattr(ks.KnowledgeStore, "add_paper", real_add)
    monkeypatch.setattr(ks, "extract_facts", lambda *a, **kw: pytest.fail("recovery re-extracted facts"))
    first = ask.index_kb_snapshot(snapshot, position=0, emit=lambda e: None)
    replay = ask.index_kb_snapshot(snapshot, position=0, emit=lambda e: None)
    assert first == replay
    assert (first["paper_count"], first["next_position"]) == (1, 1)
    store = ks.KnowledgeStore()
    assert store.stats()["items"] == first["items"]
    assert store.stats()["papers"] == 1
    assert any(h["kind"] == "fact" for h in store.search("tirzepatide", top_k=100))
    assert Path(res.out_path).read_bytes() == before


def test_snapshot_rejects_partial_checkpoint_and_obeys_cancel(pipeline, monkeypatch, tmp_path):
    res = ask.run_ask(ask.AskOptions(question="benefit", workers=1, use_paywall=False),
                      run_id="partial", defer_kb=True, emit=lambda e: None)
    snapshot = ask.save_kb_snapshot(res)
    checkpoint = Path(res.papers_dir, "kb-facts-1.json")
    checkpoint.write_text('{"version": 1, "facts": [', encoding="utf-8")
    with pytest.raises(ask.PipelineCancelled):
        ask.index_kb_snapshot(snapshot, position=0, should_cancel=lambda: True, emit=lambda e: None)
    assert not (tmp_path / "kb").exists()
    result = ask.index_kb_snapshot(snapshot, position=0, emit=lambda e: None)
    assert result["items"] > len(_paras())
    assert json.loads(checkpoint.read_text(encoding="utf-8"))["facts"]


def test_nothing_relevant_skips_expensive_kb(pipeline, monkeypatch):
    def read_irrelevant(i, p, question_en, **kwargs):
        p.update(notes="Relevance 0", relevance=0, cites=[])
        return p

    monkeypatch.setattr(ask, "read_paper", read_irrelevant)
    monkeypatch.setattr(ks, "extract_facts", lambda *a, **kw: pytest.fail("irrelevant facts extraction"))
    with pytest.raises(ask.NothingRelevant):
        ask.run_ask(ask.AskOptions(question="irrelevant", workers=1, use_paywall=False),
                    run_id="irrelevant", emit=lambda e: None)


def test_llm_metrics_preserve_usage_without_content_or_secrets(monkeypatch):
    events = []
    response = httpx.Response(200, request=httpx.Request("POST", "http://llm/chat/completions"),
                             json={"id": "provider-id", "model": "served-model",
                                   "choices": [{"finish_reason": "stop", "message": {"content": "private answer"}}],
                                   "usage": {"prompt_tokens": 12, "completion_tokens": 7,
                                             "completion_tokens_details": {"reasoning_tokens": 3},
                                             "prompt_tokens_details": {"cached_tokens": 4}}})
    monkeypatch.setattr(ask.httpx, "post", lambda *a, **kw: response)
    monkeypatch.setattr(ask, "LLM_KEY", "secret-key")
    assert ask.llm("private system", "private question", operation="read", emit=events.append) == "private answer"
    logged = json.dumps(events)
    assert "private" not in logged and "secret-key" not in logged
    metrics = json.loads(events[0]["message"].removeprefix("llm_metrics "))
    assert metrics["success"] and metrics["operation"] == "read"
    assert metrics["response_id"] == "provider-id"
    assert (metrics["prompt_tokens"], metrics["completion_tokens"], metrics["reasoning_tokens"],
            metrics["cached_tokens"]) == (12, 7, 3, 4)


def test_snapshot_processes_all_papers_one_at_a_time_including_empty(pipeline, monkeypatch, tmp_path):
    res = ask.run_ask(ask.AskOptions(question="benefit", workers=1, use_paywall=False),
                      run_id="batch", defer_kb=True, emit=lambda e: None)
    # 无相关性/无段落的候选也必须保留在完整快照中，但不能启动模型抽取。
    res.papers.append({**res.papers[0], "n": 2, "pmid": "empty", "paras": [], "fulltext_md": ""})
    snapshot = ask.save_kb_snapshot(res)
    first = ask.index_kb_snapshot(snapshot, position=0, emit=lambda e: None)
    assert (first["paper_count"], first["next_position"]) == (2, 1)
    monkeypatch.setattr(ks, "extract_facts", lambda *a, **kw: pytest.fail("empty paragraphs extracted"))
    assert ask.index_kb_snapshot(snapshot, position=1, emit=lambda e: None) == {
        "paper_count": 2, "next_position": 2, "items": 0}
    assert ks.KnowledgeStore().stats()["items"] == first["items"]


def test_default_pipeline_still_indexes_synchronously(pipeline, monkeypatch, tmp_path):
    res = ask.run_ask(ask.AskOptions(question="benefit", workers=1, use_paywall=False),
                      run_id="sync", emit=lambda e: None)
    assert any(h["kind"] == "fact" for h in ks.KnowledgeStore().search("tirzepatide", top_k=100))
    assert json.loads(Path(res.papers_dir, "39133485_facts.json").read_text(encoding="utf-8")) == res.papers[0]["facts"]


def test_deferred_kb_hits_only_include_history(pipeline, monkeypatch, tmp_path):
    store = ks.KnowledgeStore()
    for pmid in ("history", "39133485"):
        store.add_paper({"pmid": pmid, "title": "tirzepatide"}, [],
                        [{"fact": "tirzepatide clinical benefit", "verified": False}])
    monkeypatch.setattr(ks, "extract_facts", lambda *a, **kw: pytest.fail("history lookup extracted facts"))
    res = ask.run_ask(ask.AskOptions(question="tirzepatide benefit", workers=1,
                                    use_paywall=False, kb_hits=10),
                      run_id="history", defer_kb=True, emit=lambda e: None)
    assert {hit["pmid"] for hit in res.kb_hits} == {"history"}
    assert "PMID:history" in res.answer_md
    assert "[1¶2]" in res.body_md
