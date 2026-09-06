import Foundation
import Testing
@testable import YAOEKit

@Suite("SSE 事件流")
struct SSEStreamTests {
    /// 守住「空行是帧分隔符」这条契约：曾经用 `bytes.lines` 读流，空行被吞掉，一帧都派发不出来。
    @Test("空行分隔的帧全部派发，注释心跳被忽略")
    func streamsFrames() async throws {
        let body = """
        : ping\n\n\
        id: 1-0\nevent: stage\ndata: {"stage":"search","status":"started"}\n\n\
        : ping\n\n\
        id: 1-1\nevent: log\ndata: {"level":"info","message":"hello"}\n\n\
        id: 2-0\nevent: succeeded\ndata: {"answer_id":"a1"}\n\n
        """
        let server = try MiniHTTPServer(contentType: "text/event-stream", body: body)
        await server.start()
        defer { server.stop() }

        let client = APIClient(
            baseURL: URL(string: "http://127.0.0.1:\(server.port)")!,
            tokenProvider: { "token" },
            onUnauthorized: {}
        )

        var live = JobLive.empty
        var events: [SSEEvent] = []
        for try await event in await client.events(jobID: "job-1", lastEventID: "5-0") {
            events.append(event)
            live = live.applying(event)
        }

        #expect(events.map(\.event) == ["stage", "log", "succeeded"])
        #expect(events.map(\.id) == ["1-0", "1-1", "2-0"])
        #expect(live.stages[.search]?.status == .running)
        #expect(live.logs.map(\.message) == ["hello"])
        #expect(live.terminal == .succeeded(answerId: "a1", items: nil, papers: nil))
        // 续订必须带上调用方给的位置，否则重连会重放已消费过的日志。
        #expect(server.requestLine == "GET /v1/jobs/job-1/events HTTP/1.1")
        #expect(server.header("Last-Event-ID") == "5-0")
        #expect(server.header("Accept") == "text/event-stream")
    }
}
