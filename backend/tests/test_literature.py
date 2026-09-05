"""文献透传端点的消费者可见行为。"""
from __future__ import annotations

import httpx
import pytest
import literature

from .conftest import READ_KEY, auth


def _pubmed_record(pmid: str = "123") -> dict:
    return {
        "pmid": pmid,
        "pmc": "",
        "doi": "10.1/pubmed",
        "title": "PubMed result",
        "abstract": "Abstract",
        "year": "2024",
        "journal": "Test Journal",
        "issn": "",
        "authors": ["A B"],
        "types": ["Journal Article"],
    }


def test_auto_falls_back_to_pubmed(client, monkeypatch):
    def unavailable(*args, **kwargs):
        raise literature.UpstreamError("semantic_scholar", "HTTP 429")

    monkeypatch.setattr(literature, "s2_search", unavailable)
    monkeypatch.setattr(
        literature,
        "pubmed_search_records",
        lambda *args, **kwargs: (1, [_pubmed_record("789")]),
    )

    response = client.get("/v1/literature/search?q=x", headers=auth(READ_KEY))

    assert response.status_code == 200
    body = response.json()
    assert body["source"] == "pubmed"
    assert "429" in body["fallback_reason"]
    assert body["items"][0]["pmid"] == "789"


def test_explicit_s2_failure_is_upstream_error(client, monkeypatch):
    def unavailable(*args, **kwargs):
        raise literature.UpstreamError("semantic_scholar", "HTTP 429")

    monkeypatch.setattr(literature, "s2_search", unavailable)

    response = client.get(
        "/v1/literature/search?source=s2&q=x",
        headers=auth(READ_KEY),
    )

    assert response.status_code == 502
    assert response.json()["code"] == "upstream_unavailable"
    assert "semantic_scholar" in response.json()["detail"]


def test_s2_external_ids_and_enrichment_are_mapped(client, monkeypatch):
    paper = {
        "paperId": "abc",
        "externalIds": {
            "PubMed": "123",
            "DOI": "10.1/x",
            "PubMedCentral": "PMC9",
        },
        "venue": "The Lancet",
        "authors": [{"name": "A B"}],
        "citationCount": 7,
        "openAccessPdf": {"url": "http://x/y.pdf"},
        "tldr": {"text": "t"},
        "year": 2024,
    }
    monkeypatch.setattr(literature, "s2_search", lambda *args, **kwargs: (1, [paper]))

    response = client.get(
        "/v1/literature/search?source=s2&q=x",
        headers=auth(READ_KEY),
    )

    assert response.status_code == 200
    item = response.json()["items"][0]
    assert item["pmid"] == "123"
    assert item["doi"] == "10.1/x"
    assert item["pmcid"] == "PMC9"
    assert item["cited_by"] == 7
    assert item["open_access_pdf"] == "http://x/y.pdf"
    assert item["tldr"] == "t"
    assert item["rank"]["quartile"] == "Q1"


def test_fulltext_unavailable_is_problem_detail(client, monkeypatch):
    monkeypatch.setattr(
        literature,
        "resolve_pmcid",
        lambda ident: ("", "no PMC full text (isOpenAccess=N)"),
    )

    response = client.get(
        "/v1/literature/PMC123/fulltext",
        headers=auth(READ_KEY),
    )

    assert response.status_code == 404
    assert response.json()["code"] == "fulltext_unavailable"
    assert response.headers["content-type"] == "application/problem+json"


def test_fulltext_directory_section_and_all(client, monkeypatch):
    monkeypatch.setattr(literature, "resolve_pmcid", lambda ident: ("PMC9306514", ""))
    monkeypatch.setattr(
        literature,
        "epmc_fulltext_sections",
        lambda pmcid: [("Abstract", "a" * 50), ("Results", "r" * 100)],
    )
    monkeypatch.setattr(literature, "epmc_citation", lambda pmcid: f"CITATION: {pmcid}")
    headers = auth(READ_KEY)

    directory = client.get("/v1/literature/PMC9306514/fulltext", headers=headers)
    assert directory.status_code == 200
    assert len(directory.json()["sections"]) == 2
    assert directory.json()["text"] is None
    assert directory.json()["abstract"]

    result = client.get(
        "/v1/literature/PMC9306514/fulltext?section=result",
        headers=headers,
    )
    assert result.status_code == 200
    assert "## Results" in result.json()["text"]

    missing = client.get(
        "/v1/literature/PMC9306514/fulltext?section=nope",
        headers=headers,
    )
    assert missing.status_code == 404
    assert missing.json()["code"] == "not_found"

    all_sections = client.get(
        "/v1/literature/PMC9306514/fulltext?section=all&max_chars=1000",
        headers=headers,
    )
    assert all_sections.status_code == 200
    assert all_sections.json()["truncated"] is False


def test_search_rejects_conflicting_year_filters(client, monkeypatch):
    monkeypatch.setattr(
        literature,
        "s2_search",
        lambda *args, **kwargs: (_ for _ in ()).throw(AssertionError("must not search")),
    )

    response = client.get(
        "/v1/literature/search?q=x&years=3&year_from=2020",
        headers=auth(READ_KEY),
    )

    assert response.status_code == 422
    assert response.json()["code"] == "validation_error"


def test_search_requires_authentication(client, monkeypatch):
    monkeypatch.setattr(
        literature,
        "s2_search",
        lambda *args, **kwargs: (_ for _ in ()).throw(AssertionError("must not search")),
    )

    response = client.get("/v1/literature/search?q=x")

    assert response.status_code == 401


@pytest.fixture
def upstream_http(monkeypatch):
    """只替换出站 HTTP 传输，保留真实文献适配层和响应解析。"""
    clients = []

    def install(handler):
        upstream = httpx.Client(transport=httpx.MockTransport(handler))
        clients.append(upstream)
        monkeypatch.setattr(literature.httpx, "get", upstream.get)
        monkeypatch.setattr(literature.time, "sleep", lambda _: None)

    yield install
    for upstream in clients:
        upstream.close()


def _pubmed_xml(records=None) -> str:
    if records is None:
        records = [("1", "Other Journal"), ("2", "Target Journal"),
                   ("3", "Target Journal"), ("4", "Target Journal")]
    return "<PubmedArticleSet>" + "".join(
        f"<PubmedArticle><MedlineCitation><PMID>{pmid}</PMID>"
        "<Article><ArticleTitle>Clinical evidence</ArticleTitle>"
        f"<Journal><Title>{journal}</Title></Journal>"
        "</Article></MedlineCitation></PubmedArticle>"
        for pmid, journal in records
    ) + "</PubmedArticleSet>"


@pytest.mark.parametrize("source", ["pubmed", "auto"])
def test_filtered_pubmed_limit_survives_overfetch(client, upstream_http, source):
    def handle(request):
        if request.url.host == "api.semanticscholar.org":
            return httpx.Response(503)
        if request.url.path.endswith("esearch.fcgi"):
            return httpx.Response(200, json={"esearchresult": {"count": "4", "idlist": ["1", "2", "3", "4"]}})
        assert request.url.path.endswith("efetch.fcgi")
        return httpx.Response(200, text=_pubmed_xml())

    upstream_http(handle)
    response = client.get("/v1/literature/search",
                          params={"q": "evidence", "source": source, "limit": 1, "journals": "Target"},
                          headers=auth(READ_KEY))
    assert response.status_code == 200
    assert response.json()["total"] == 4
    assert [p["pmid"] for p in response.json()["items"]] == ["2"]


@pytest.mark.parametrize("path,fail_fetch", [
    ("/v1/literature/123", True),
    ("/v1/literature/search?q=x&source=pubmed", False),
    ("/v1/literature/search?q=x&source=pubmed", True),
])
def test_ncbi_failure_is_not_missing(client, upstream_http, path, fail_fetch):
    def handle(request):
        if fail_fetch and request.url.path.endswith("esearch.fcgi"):
            return httpx.Response(200, json={"esearchresult": {"count": "1", "idlist": ["123"]}})
        return httpx.Response(503)

    upstream_http(handle)
    response = client.get(path, headers=auth(READ_KEY))
    assert response.status_code == 502
    assert response.json()["code"] == "upstream_unavailable"


@pytest.mark.parametrize("ident", ["PMC123", "123", "10.1000/example"])
def test_epmc_fulltext_failure_is_not_missing(client, upstream_http, ident):
    def handle(request):
        if request.url.path.endswith("/search"):
            return httpx.Response(200, json={"resultList": {"result": [{"pmcid": "PMC123"}]}})
        return httpx.Response(503)

    upstream_http(handle)
    response = client.get(f"/v1/literature/{ident}/fulltext", headers=auth(READ_KEY))
    assert response.status_code == 502
    assert response.json()["code"] == "upstream_unavailable"


@pytest.mark.parametrize("path", [
    "/v1/literature/missing-s2",
    "/v1/literature/missing-s2/citations",
    "/v1/literature/missing-s2/references",
    "/v1/literature/missing-s2/recommendations",
])
def test_s2_missing_is_not_upstream_failure(client, upstream_http, path):
    upstream_http(lambda request: httpx.Response(404))
    response = client.get(path, headers=auth(READ_KEY))
    assert response.status_code == 404
    assert response.json()["code"] == "not_found"


@pytest.mark.parametrize("ident", ["10.1000/example", "10.1000%2Fexample", "123"])
@pytest.mark.parametrize("resource", ["", "/fulltext", "/citations", "/references", "/recommendations"])
def test_identifiers_reach_each_literature_resource(client, upstream_http, ident, resource):
    paper = {"paperId": "resolved", "title": "Resolved paper", "externalIds": {"DOI": "10.1000/example"}}

    def handle(request):
        path = request.url.path
        if request.url.host == "eutils.ncbi.nlm.nih.gov":
            return httpx.Response(200, text=_pubmed_xml([("123", "Target Journal")]))
        if request.url.host == "www.ebi.ac.uk":
            if path.endswith("/fullTextXML"):
                return httpx.Response(200, text="<article><abstract><p>Resolved abstract</p></abstract></article>")
            return httpx.Response(200, json={"resultList": {"result": [{"pmcid": "PMC123", "title": "Resolved paper"}]}})
        expected = "PMID:123" if ident == "123" else "DOI:10.1000/example"
        assert expected in path
        if resource == "/citations":
            return httpx.Response(200, json={"data": [{"citingPaper": paper}]})
        if resource == "/references":
            return httpx.Response(200, json={"data": [{"citedPaper": paper}]})
        if resource == "/recommendations":
            return httpx.Response(200, json={"recommendedPapers": [paper]})
        return httpx.Response(200, json=paper)

    upstream_http(handle)
    response = client.get(f"/v1/literature/{ident}{resource}", headers=auth(READ_KEY))
    assert response.status_code == 200
    body = response.json()
    if resource == "/fulltext":
        assert body["abstract"] == "Resolved abstract"
    elif resource:
        assert body["items"][0]["title"] == "Resolved paper"
    elif ident == "123":
        assert body["pmid"] == "123"
    else:
        assert body["doi"] == "10.1000/example"


@pytest.mark.parametrize("s2_status,epmc_status,expected", [(404, 503, 502), (503, 200, 502), (404, 200, 404)])
def test_doi_fallback_preserves_failure(client, upstream_http, s2_status, epmc_status, expected):
    def handle(request):
        if request.url.host == "api.semanticscholar.org":
            return httpx.Response(s2_status)
        return httpx.Response(epmc_status, json={"resultList": {"result": []}})

    upstream_http(handle)
    response = client.get("/v1/literature/10.1000/example", headers=auth(READ_KEY))
    assert response.status_code == expected


@pytest.mark.parametrize("path", ["/v1/literature/PMC123", "/v1/literature/123/fulltext"])
def test_epmc_identifier_lookup_failure_is_not_missing(client, upstream_http, path):
    upstream_http(lambda request: httpx.Response(503))
    response = client.get(path, headers=auth(READ_KEY))
    assert response.status_code == 502


def test_fulltext_citation_failure_is_upstream_error(client, upstream_http):
    def handle(request):
        if request.url.path.endswith("/fullTextXML"):
            return httpx.Response(200, text="<article><abstract><p>Available text</p></abstract></article>")
        return httpx.Response(503)

    upstream_http(handle)
    response = client.get("/v1/literature/PMC123/fulltext", headers=auth(READ_KEY))
    assert response.status_code == 502
