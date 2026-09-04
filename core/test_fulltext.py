import semantic_scholar_mcp as s
print(s.get_fulltext("PMID:34837447")[:1500])
print("\n====\n")
print(s.get_fulltext("PMC9306514", section="Conclusion")[:1200])
print("\n==== paywalled example (NEJM) ====\n")
print(s.get_fulltext("PMID:34449189")[:400])
