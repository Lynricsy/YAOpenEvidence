"""Quick smoke test of the literature tools (no LLM needed)."""
import semantic_scholar_mcp as s
print("### pubmed_search"); print(s.pubmed_search("SGLT2 inhibitors heart failure preserved ejection fraction", limit=2, year="2020-2024", publication_types="Meta-Analysis,Randomized Controlled Trial")[:1500])
print("\n### search_papers (S2, falls back to PubMed if 429)"); print(s.search_papers("SGLT2 inhibitors HFpEF", limit=2, year="2021-2024")[:1200])
