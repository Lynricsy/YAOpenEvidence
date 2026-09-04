"""文献透传端点的消费者可见行为。"""
from __future__ import annotations

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
