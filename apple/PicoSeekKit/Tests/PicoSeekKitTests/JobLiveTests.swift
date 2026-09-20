import Testing
@testable import PicoSeekKit

@Suite("JobLive")
struct JobLiveTests {
    private func event(_ name: String, _ json: String) -> SSEEvent {
        SSEEvent(id: nil, event: name, data: json)
    }

    @Test("search 完成后写入摘要，succeeded 不清空既有状态")
    func searchThenSucceeded() {
        var live = JobLive.empty
        live = live.applying(event("progress", #"{"stage":"read","current":2,"total":5,"title":"某篇"}"#))
        live = live.applying(event("stage", """
        {"stage":"search","status":"finished","detail":{"candidates":30,"kept":8,
        "dropped":{"year":10,"quartile":7,"unranked":3,"journal":2},
        "papers":[{"n":1,"pmid":"1","title":"T","year":"2024","journal":"J","rank_label":"Q1","pmcid":"PMC1"}]}}
        """))
        live = live.applying(event("succeeded", #"{"answer_id":"a1"}"#))

        #expect(live.stages[.search]?.status == .finished)
        #expect(live.search?.candidates == 30)
        #expect(live.search?.kept == 8)
        #expect(live.search?.dropped["year"] == 10)
        #expect(live.search?.papers.first?.pmid == "1")
        #expect(live.search?.papers.first?.rankLabel == "Q1")
        #expect(live.progress?.stage == .read)
        #expect(live.progress?.current == 2)
        #expect(live.terminal == .succeeded(answerId: "a1", items: nil, papers: nil))
    }

    @Test("同一 call_id 的 started 与终态合成一行")
    func toolUpsert() {
        var live = JobLive.empty
        live = live.applying(event("tool", """
        {"call_id":"c1","server":"semantic_scholar","tool":"read_pdf","status":"started",
        "args":{"path":"x.pdf"},"duration_ms":null,"error":null}
        """))
        #expect(live.tools.count == 1)
        #expect(live.tools.first?.status == .started)

        live = live.applying(event("tool", """
        {"call_id":"c1","server":"semantic_scholar","tool":"read_pdf","status":"completed",
        "args":{"path":"x.pdf"},"duration_ms":820,"error":null}
        """))
        #expect(live.tools.count == 1)
        #expect(live.tools.first?.status == .completed)
        #expect(live.tools.first?.durationMs == 820)

        live = live.applying(event("tool", """
        {"call_id":"c2","server":"pubmed","tool":"pubmed_search","status":"started","args":{"query":"q"}}
        """))
        #expect(live.tools.map(\.callId) == ["c1", "c2"])
        // 缺 call_id 的帧无法定位到某一行，只能丢弃。
        #expect(live.applying(event("tool", #"{"server":"s","tool":"t","status":"started"}"#)) == live)
    }

    @Test("agent 阶段进 running，且不混进 ask 流水线")
    func agentStage() {
        let live = JobLive.empty.applying(event("stage", """
        {"stage":"agent","status":"started","detail":{"resumed":false}}
        """))
        #expect(live.stages[.agent]?.status == .running)
        #expect(StageKey.agent.label == "智能体检索与作答")
        #expect(!StageKey.askPipeline.contains(.agent))
    }

    @Test("终态可被后续事件覆盖，不做短路")
    func terminalNotSticky() {
        var live = JobLive.empty.applying(event("failed", #"{"code":"no_papers","message":"没有文献"}"#))
        #expect(live.terminal == .failed(code: "no_papers", message: "没有文献"))
        live = live.applying(event("cancelled", "{}"))
        #expect(live.terminal == .cancelled)
    }

    @Test("失败事件字段缺失时回落默认值")
    func failedDefaults() {
        let live = JobLive.empty.applying(event("failed", "{}"))
        #expect(live.terminal == .failed(code: "internal_error", message: ""))
    }

    @Test("日志上限 200 条，超出丢弃最早的")
    func logsCapped() {
        var live = JobLive.empty
        for index in 1 ... 205 {
            live = live.applying(event("log", #"{"level":"info","message":"\#(index)"}"#))
        }
        #expect(live.logs.count == 200)
        #expect(live.logs.first?.message == "6")
        #expect(live.logs.last?.message == "205")
    }

    @Test("非法与未知事件保持原状")
    func invalidEventsIgnored() {
        let base = JobLive.empty.applying(event("stage", #"{"stage":"queries","status":"started"}"#))
        #expect(base.applying(event("stage", #"{"stage":"unknown","status":"started"}"#)) == base)
        #expect(base.applying(event("stage", #"{"stage":"read","status":"paused"}"#)) == base)
        #expect(base.applying(event("progress", #"{"stage":"nope","current":1,"total":2}"#)) == base)
        #expect(base.applying(event("log", #"{"level":"info"}"#)) == base)
        #expect(base.applying(event("whatever", "{}")) == base)
        #expect(base.applying(event("stage", "not json")) == base)
    }

    @Test("阶段摘要文案")
    func summaries() {
        let searchDetail: [String: JSONValue] = [
            "candidates": .number(30), "kept": .number(8),
            "dropped": .object(["year": .number(10), "quartile": .number(7), "unranked": .number(3), "journal": .number(2)]),
        ]
        #expect(stageSummary(.search, detail: searchDetail) == "候选 30 → 保留 8（年份 -10 / 分区 -7 / 未收录 -3 / 期刊 -2）")
        #expect(stageSummary(.read, detail: ["relevant": .number(4), "total": .number(6)]) == "相关 4/6")
        #expect(stageSummary(.queries, detail: ["queries": .number(3)]) == "检索式 3")
        #expect(stageSummary(.fulltext, detail: ["n_fulltext": .number(2), "papers": .number(5)]) == "全文 2 · 文献 5")
        #expect(stageSummary(.synthesize, detail: ["note": .string("忽略非数字")]) == "")
    }
}
