"""文献适配层的故障语义与流水线降级回归。"""
from __future__ import annotations

import httpx
import pytest

import ask
import literature as lit


@pytest.fixture
def upstream_http(monkeypatch):
    clients = []

    def install(handler):
        upstream = httpx.Client(transport=httpx.MockTransport(handler))
        clients.append(upstream)
        monkeypatch.setattr(lit.httpx, "get", upstream.get)
        monkeypatch.setattr(lit.time, "sleep", lambda _: None)

    yield install
    for upstream in clients:
        upstream.close()


@pytest.mark.parametrize("fetch,args,source", [
    (lit.pubmed_fetch_records, (["123"],), "pubmed"),
    (lit.pubmed_search_records, ("evidence",), "pubmed"),
    (lit.pmcid_to_pmid, ("PMC123",), "europepmc"),
    (lit.resolve_pmcid, ("10.1000/example",), "europepmc"),
    (lit.epmc_citation, ("PMC123",), "europepmc"),
    (lit.epmc_fulltext_sections, ("PMC123",), "europepmc"),
    (lit.epmc_fulltext_paragraphs, ("PMC123",), "europepmc"),
])
@pytest.mark.parametrize("failure", ["network", "503"])
def test_adapters_preserve_unavailability(upstream_http, fetch, args, source, failure):
    def handle(request):
        if failure == "network":
            raise httpx.ConnectError("offline", request=request)
        return httpx.Response(503)

    upstream_http(handle)
    with pytest.raises(lit.UpstreamError) as raised:
        fetch(*args)
    assert raised.value.source == source
    assert not isinstance(raised.value, lit.UpstreamNotFound)


def test_actual_absence_remains_distinct(upstream_http):
    upstream_http(lambda request: httpx.Response(404))
    assert lit.pubmed_fetch_records(["123"]) == []
    assert lit.pubmed_search_records("evidence") == (0, [])
    assert lit.pmcid_to_pmid("PMC123") == ""
    assert lit.resolve_pmcid("10.1000/example")[0] == ""
    assert lit.epmc_fulltext_sections("PMC123") == []
    assert lit.epmc_fulltext_paragraphs("PMC123") == []
    with pytest.raises(lit.UpstreamNotFound):
        lit.s2_paper("missing")


def test_transient_ncbi_failure_recovers(upstream_http):
    responses = iter([httpx.Response(503), httpx.Response(200, text=(
        "<PubmedArticleSet><PubmedArticle><MedlineCitation><PMID>123</PMID>"
        "<Article><ArticleTitle>Recovered evidence</ArticleTitle></Article>"
        "</MedlineCitation></PubmedArticle></PubmedArticleSet>"))])
    upstream_http(lambda request: next(responses))
    assert lit.pubmed_fetch_records(["123"])[0]["title"] == "Recovered evidence"


def test_s2_fulltext_mapping_does_not_hide_failure(upstream_http):
    upstream_http(lambda request: httpx.Response(503))
    with pytest.raises(lit.UpstreamError) as raised:
        lit.resolve_pmcid("s2-paper-id")
    assert raised.value.source == "semantic_scholar"


def test_ask_keeps_abstract_when_fulltext_service_fails(upstream_http, tmp_path):
    upstream_http(lambda request: httpx.Response(503))
    paper = {"pmid": "123", "pmcid": "PMC123", "doi": "", "title": "Evidence",
             "abstract": "Existing abstract remains available.", "authors": "Author", "journal": "Journal", "year": "2025"}
    result = ask.fetch_fulltext(paper, str(tmp_path), 20000, emit=lambda event: None)
    assert result["source"] == "abstract"
    assert "Existing abstract remains available." in result["text"]


def test_ask_search_source_can_degrade(upstream_http):
    upstream_http(lambda request: httpx.Response(503))
    assert ask.pubmed_search("evidence", 1, ask.Filters()) == []


def test_related_endpoints_omit_tldr_field(upstream_http):
    """S2 的 citations / references / recommendations 对 tldr 回 400；带上就是恒定 502。"""
    asked: list[str] = []

    def handle(request):
        asked.append(request.url.params.get("fields", ""))
        return httpx.Response(200, json={"data": [], "recommendedPapers": []})

    upstream_http(handle)
    lit.s2_citations("PMID:1", 5)
    lit.s2_references("PMID:1", 5)
    lit.s2_recommendations("PMID:1", 5)

    assert len(asked) == 3
    assert all("tldr" not in fields for fields in asked)
    assert all("paperId" in fields and "externalIds" in fields for fields in asked)
    # 单篇与检索仍要 tldr：那是列表卡片上的一句话摘要
    assert "tldr" in lit.PAPER_FIELDS
    assert "tldr" in lit.SHORT_FIELDS
