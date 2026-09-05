"""文献库、知识库与期刊分区端点的消费者行为。"""
from __future__ import annotations

from .conftest import ADMIN_KEY, READ_KEY, auth


def test_papers_list_and_paragraph(client):
    response = client.get("/v1/papers", headers=auth(READ_KEY))
    assert response.status_code == 200
    body = response.json()
    assert body["total"] == 1
    assert body["items"][0]["key"] == "39133485"
    assert body["items"][0]["n_paragraphs"] == 49

    response = client.get("/v1/papers/39133485/paragraphs/2", headers=auth(READ_KEY))
    assert response.status_code == 200
    assert response.json()["text"].startswith("In this cohort study")


def test_missing_paragraph_is_problem(client):
    response = client.get("/v1/papers/39133485/paragraphs/9999", headers=auth(READ_KEY))
    assert response.status_code == 404
    assert response.headers["content-type"] == "application/problem+json"
    assert response.json()["code"] == "not_found"


def test_paper_key_cannot_escape_library(client):
    response = client.get("/v1/papers/..%2Fx", headers=auth(READ_KEY))
    assert response.status_code == 404
    assert response.json()["code"] == "not_found"


def test_paper_fulltext(client):
    response = client.get("/v1/papers/39133485/fulltext", headers=auth(READ_KEY))
    assert response.status_code == 200
    assert response.headers["content-type"] == "text/markdown; charset=utf-8"
    assert '<a id="p2">' in response.text
    schema = client.get("/v1/openapi.json").json()
    content = schema["paths"]["/v1/papers/{key}/fulltext"]["get"]["responses"]["200"]["content"]
    assert content == {"text/markdown": {"schema": {"type": "string"}}}


def test_kb_search_and_stats(client):
    response = client.get("/v1/kb/search", params={"q": "tirzepatide mortality"},
                          headers=auth(READ_KEY))
    assert response.status_code == 200
    assert response.json()["items"]
    assert response.json()["items"][0]["pmid"] == "39133485"

    response = client.get("/v1/kb/search", params={"q": "x", "kind": "fact"},
                          headers=auth(READ_KEY))
    assert response.status_code == 200
    assert all(item["kind"] == "fact" for item in response.json()["items"])

    response = client.get("/v1/kb/stats", headers=auth(READ_KEY))
    assert response.status_code == 200
    body = response.json()
    assert body["items"] > 0
    assert body["papers"] == 1
    assert body["embedder"] == "hash-bow-v1"


def test_kb_reindex_requires_admin_and_enqueues(client, arq):
    response = client.post("/v1/kb/reindex", headers=auth(READ_KEY))
    assert response.status_code == 403

    response = client.post("/v1/kb/reindex", headers=auth(ADMIN_KEY))
    assert response.status_code == 202
    body = response.json()
    assert body["kind"] == "kb_reindex"
    assert body["status"] == "queued"
    job_id = body["id"]
    assert arq.calls == [("run_kb_reindex_job", (job_id,), {"_job_id": job_id})]


def test_journal_rank(client):
    response = client.get("/v1/journals/rank", params={"title": "Lancet"},
                          headers=auth(READ_KEY))
    assert response.status_code == 200
    body = response.json()
    assert body["found"] is True
    assert body["rank"]["quartile"] == "Q1"
    assert body["rank"]["zone"] == 1


def test_journal_rank_requires_query(client):
    response = client.get("/v1/journals/rank", headers=auth(READ_KEY))
    assert response.status_code == 422
    assert response.json()["code"] == "validation_error"


def test_cached_search_survives_same_mtime_generation_change(tmp_path, monkeypatch):
    import asyncio
    import os
    import threading
    from concurrent.futures import ThreadPoolExecutor

    import knowledge_store as ks
    from app.services import kb as service_module

    class Embedder:
        name = "test-cache"

        def encode(self, texts):
            return ks.np.array([[1.0, 0.0] for _ in texts], dtype="float32")

    path = tmp_path / ks.INDEX_FILE
    info = {"embedder": "test-cache", "dim": 2}
    ks.write_index(str(path), [{"pmid": "1001", "kind": "paragraph"}],
                   ks.np.array([[1.0, 0.0]], dtype="float32"), info)
    monkeypatch.setattr(service_module, "KB_DIR", str(tmp_path))
    embedder = Embedder()
    store = ks.KnowledgeStore(str(tmp_path), embedder)
    service = service_module.KbService()
    service._store = store
    service._mtime = service._index_mtime()
    scored, resume = threading.Event(), threading.Event()
    real_argsort = ks.np.argsort

    def gated_argsort(scores):
        scored.set()
        assert resume.wait(10)
        return real_argsort(scores)

    monkeypatch.setattr(ks.np, "argsort", gated_argsort)
    with ThreadPoolExecutor() as pool:
        result = pool.submit(asyncio.run, service.search("query"))
        try:
            assert scored.wait(10)
            old_stat = path.stat()
            ks.write_index(str(path), [{"pmid": "2001", "kind": "paragraph"}],
                           ks.np.array([[0.0, 1.0]], dtype="float32"), info)
            os.utime(path, ns=(old_stat.st_atime_ns, old_stat.st_mtime_ns))
            assert service.stats()["papers"] == 1
        finally:
            resume.set()
        assert result.result(timeout=10)[0]["pmid"] == "1001"
    assert asyncio.run(service.search("query"))[0]["pmid"] == "2001"
    assert service.get_store().embedder is embedder
