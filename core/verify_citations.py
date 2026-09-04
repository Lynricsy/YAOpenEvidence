#!/usr/bin/env python3
"""Check whether the citations in Codex's final answer were actually retrieved by tools.

Usage:  python3 verify_citations.py            # latest session
        python3 verify_citations.py <rollout.jsonl>
Reads ~/.codex/sessions/**/rollout-*.jsonl, collects every PMID / DOI / paperId that appeared
in MCP tool *results*, then compares against the IDs cited in the assistant's final answer.
"""
import glob, json, os, re, sys

PMID = re.compile(r"PMID[:\s]*(\d{6,9})", re.I)
DOI = re.compile(r"10\.\d{4,9}/[^\s\]\)\"',;]+", re.I)


def iter_records(path):
    with open(path, encoding="utf-8") as f:
        for line in f:
            try:
                yield json.loads(line)
            except json.JSONDecodeError:
                continue


def walk_text(obj):
    """Yield every string value inside a nested JSON object."""
    if isinstance(obj, str):
        yield obj
    elif isinstance(obj, dict):
        for v in obj.values():
            yield from walk_text(v)
    elif isinstance(obj, list):
        for v in obj:
            yield from walk_text(v)


def main():
    if len(sys.argv) > 1:
        path = sys.argv[1]
    else:
        files = glob.glob(os.path.expanduser("~/.codex/sessions/**/rollout-*.jsonl"), recursive=True)
        if not files:
            sys.exit("no sessions found")
        path = max(files, key=os.path.getmtime)
    print(f"session: {path}\n")

    tool_calls, tool_pmids, tool_dois = [], set(), set()
    answer = ""
    for rec in iter_records(path):
        payload = rec.get("payload", rec)
        typ = payload.get("type", "")
        # tool invocations
        if typ in ("function_call", "custom_tool_call") or payload.get("name", "").startswith(("semantic_scholar", "mcp")):
            name = payload.get("name") or ""
            if name:
                tool_calls.append((name, str(payload.get("arguments", ""))[:120]))
        # tool results
        if typ in ("function_call_output", "custom_tool_call_output") or "output" in payload and typ.endswith("output"):
            text = " ".join(walk_text(payload.get("output")))
            tool_pmids.update(PMID.findall(text))
            tool_dois.update(d.rstrip(".").lower() for d in DOI.findall(text))
        # last assistant message
        if typ == "message" and payload.get("role") == "assistant":
            answer = " ".join(walk_text(payload.get("content")))

    answer = re.sub(r"<think>.*?</think>", "", answer, flags=re.S)
    cited_pmids = set(PMID.findall(answer))
    cited_dois = set(d.rstrip(".").lower() for d in DOI.findall(answer))

    print(f"tool calls made: {len(tool_calls)}")
    for n, a in tool_calls:
        print(f"  - {n} {a}")
    print(f"\nIDs returned by tools: {len(tool_pmids)} PMIDs, {len(tool_dois)} DOIs")
    print(f"IDs cited in answer:   {len(cited_pmids)} PMIDs, {len(cited_dois)} DOIs\n")

    bad = [("PMID", p) for p in sorted(cited_pmids - tool_pmids)] + \
          [("DOI", d) for d in sorted(cited_dois - tool_dois)]
    ok = [("PMID", p) for p in sorted(cited_pmids & tool_pmids)] + \
         [("DOI", d) for d in sorted(cited_dois & tool_dois)]
    for k, v in ok:
        print(f"  OK        {k}:{v}   (present in tool output)")
    for k, v in bad:
        print(f"  SUSPECT   {k}:{v}   <-- NOT in any tool output: likely hallucinated")
    if not cited_pmids and not cited_dois:
        print("  WARNING: answer cites no PMID/DOI at all")
    elif not tool_calls:
        print("  WARNING: no tool calls in this session -> answer is from memory")
    print(f"\nverdict: {'GROUNDED' if ok and not bad and tool_calls else 'CHECK MANUALLY'}")


if __name__ == "__main__":
    main()
