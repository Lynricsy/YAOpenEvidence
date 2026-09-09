import Foundation
import Testing
@testable import YAOEKit

@Suite("请求构造")
struct RequestBuildingTests {
    /// `+` 必须百分号转义：服务端按表单规则会把字面 `+` 解成空格，检索词与全文章节名会被静默改写。
    @Test("查询参数里的加号、空格与中文都被百分号转义")
    func encodesQuery() async throws {
        let server = try MiniHTTPServer(
            contentType: "application/json",
            body: #"{"query":"x","items":[]}"#
        )
        await server.start()
        defer { server.stop() }

        let client = APIClient(
            baseURL: URL(string: "http://127.0.0.1:\(server.port)")!,
            tokenProvider: { "token" },
            onUnauthorized: {}
        )
        _ = try await client.kbSearch(q: "HER2+ 乳腺癌", kind: .fact, topK: 5)

        let line = try #require(server.requestLine)
        #expect(line.contains("q=HER2%2B%20%E4%B9%B3%E8%85%BA%E7%99%8C"))
        #expect(!line.contains("HER2+ "))
        #expect(line.contains("top_k=5"))
        #expect(line.contains("kind=fact"))
        #expect(server.header("Authorization") == "Bearer token")
    }

    /// 就绪探针在 503 时仍返回 `ReadinessResponse`，里面才有各依赖的失败原因。
    @Test("就绪探针 503 仍按业务模型解码")
    func decodesDegradedReadiness() async throws {
        let body = """
        {"status":"degraded","checks":{
        "db":{"ok":false,"detail":"database is locked"},
        "redis":{"ok":true,"detail":"ok"},
        "llm":{"ok":true,"detail":"ok"},
        "kb":{"ok":true,"detail":"ok"},
        "ranks":{"ok":true,"detail":"ok"}}}
        """
        let server = try MiniHTTPServer(
            contentType: "application/json",
            body: body,
            status: "503 Service Unavailable"
        )
        await server.start()
        defer { server.stop() }

        let client = APIClient(
            baseURL: URL(string: "http://127.0.0.1:\(server.port)")!,
            tokenProvider: { nil },
            onUnauthorized: {}
        )
        let readiness = try await client.ready()
        #expect(readiness.status == "degraded")
        #expect(readiness.checks.db.ok == false)
        #expect(readiness.checks.db.detail == "database is locked")
        // 未鉴权端点不应带 Authorization 头。
        #expect(server.header("Authorization") == nil)
    }

    /// 其他端点的非 2xx 必须仍然按 Problem 处理，不能被 `alsoAccept` 放宽。
    @Test("普通端点的 409 仍解析为 Problem 文案")
    func mapsProblemForOtherEndpoints() async throws {
        let server = try MiniHTTPServer(
            contentType: "application/problem+json",
            body: #"{"type":"urn:yaoe:error:conflict","title":"Conflict","status":409,"detail":"answer is active","code":"conflict"}"#,
            status: "409 Conflict"
        )
        await server.start()
        defer { server.stop() }

        let client = APIClient(
            baseURL: URL(string: "http://127.0.0.1:\(server.port)")!,
            tokenProvider: { "token" },
            onUnauthorized: {}
        )
        await #expect(throws: APIError.self) {
            try await client.deleteAnswer(id: "a1")
        }
        do {
            try await client.deleteAnswer(id: "a1")
        } catch {
            #expect(error.status == 409)
            #expect(error.code == "conflict")
            #expect(error.userMessage == "当前状态不允许该操作")
        }
    }

    /// 分区表与机构状态是只读观测端点：路径写错会静默变成「状态未知」，必须钉住。
    @Test("分区表与机构状态请求路径")
    func hitsMetaEndpoints() async throws {
        let tablesServer = try MiniHTTPServer(
            contentType: "application/json",
            body: #"{"tables":[],"issns":0,"titles":0}"#
        )
        await tablesServer.start()
        defer { tablesServer.stop() }

        let tablesClient = APIClient(
            baseURL: URL(string: "http://127.0.0.1:\(tablesServer.port)")!,
            tokenProvider: { "token" },
            onUnauthorized: {}
        )
        let tables = try await tablesClient.rankTables()
        #expect(tables.tables.isEmpty)
        #expect(try #require(tablesServer.requestLine).contains("GET /v1/journals/tables"))

        let paywallServer = try MiniHTTPServer(
            contentType: "application/json",
            body: #"{"configured":true,"saved_at":"2026-09-08T10:00:00Z","final_url":"https://www.sciencedirect.com/","has_session_storage":false,"has_context_meta":true,"playwright_available":true}"#
        )
        await paywallServer.start()
        defer { paywallServer.stop() }

        let paywallClient = APIClient(
            baseURL: URL(string: "http://127.0.0.1:\(paywallServer.port)")!,
            tokenProvider: { "token" },
            onUnauthorized: {}
        )
        let status = try await paywallClient.paywallStatus()
        #expect(status.configured)
        #expect(status.finalUrl == "https://www.sciencedirect.com/")
        #expect(status.hasContextMeta)
        #expect(status.savedAt != nil)
        #expect(try #require(paywallServer.requestLine).contains("GET /v1/paywall/status"))
    }

    /// 追问与会话脉络是两个新端点：方法或路径写错只会变成 404/405，页面上看不出原因。
    @Test("追问与会话回合的请求构造")
    func hitsThreadEndpoints() async throws {
        let followServer = try MiniHTTPServer(
            contentType: "application/json",
            body: """
            {"id":"a2","status":"queued","question":"再总结一句","engine":"codex","n_turns":2,
            "root_question":"根问题","parent_id":"a1","created_at":"2026-09-08T10:00:00Z",
            "queries":[],"papers":[],"citations":[],"kb_hits":[],"trace":[]}
            """,
            status: "202 Accepted"
        )
        await followServer.start()
        defer { followServer.stop() }

        let followClient = APIClient(
            baseURL: URL(string: "http://127.0.0.1:\(followServer.port)")!,
            tokenProvider: { "token" },
            onUnauthorized: {}
        )
        let created = try await followClient.followUp(id: "a1", question: "再总结一句")
        #expect(created.parentId == "a1")
        #expect(created.engine == .codex)
        #expect(try #require(followServer.requestLine).contains("POST /v1/answers/a1/followup"))

        let threadServer = try MiniHTTPServer(
            contentType: "application/json",
            body: """
            [{"id":"a1","status":"ready","question":"根问题","engine":"codex","n_turns":2,
            "created_at":"2026-09-08T10:00:00Z"},
            {"id":"a2","status":"ready","question":"再总结一句","engine":"codex","n_turns":2,
            "root_question":"根问题","created_at":"2026-09-08T10:01:00Z"}]
            """
        )
        await threadServer.start()
        defer { threadServer.stop() }

        let threadClient = APIClient(
            baseURL: URL(string: "http://127.0.0.1:\(threadServer.port)")!,
            tokenProvider: { "token" },
            onUnauthorized: {}
        )
        let turns = try await threadClient.answerThread(id: "a1")
        #expect(turns.map(\.id) == ["a1", "a2"])
        #expect(turns.last?.rootQuestion == "根问题")
        #expect(try #require(threadServer.requestLine).contains("GET /v1/answers/a1/thread"))
    }
}
