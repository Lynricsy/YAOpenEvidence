import Foundation
import Network
import Synchronization
import Testing
@testable import YAOEKit

/// 只发一段固定 SSE 报文然后关闭连接的极简 HTTP 服务器。
/// 用来守住「空行是帧分隔符」这条契约：曾经用 `bytes.lines` 读流，空行被吞掉，一帧都派发不出来。
private final class MiniSSEServer: @unchecked Sendable {
    private let listener: NWListener
    private let body: String
    private let queue = DispatchQueue(label: "mini-sse")

    var port: UInt16 { listener.port?.rawValue ?? 0 }

    init(body: String) throws {
        self.body = body
        let parameters = NWParameters.tcp
        parameters.allowLocalEndpointReuse = true
        listener = try NWListener(using: parameters, on: .any)
    }

    func start() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            let resumed = Mutex(false)
            listener.stateUpdateHandler = { state in
                guard case .ready = state else { return }
                let shouldResume = resumed.withLock { done -> Bool in
                    guard !done else { return false }
                    done = true
                    return true
                }
                if shouldResume { continuation.resume() }
            }
            listener.newConnectionHandler = { [body] connection in
                connection.start(queue: self.queue)
                // 读掉请求头，再一次性回完整报文并关闭（无 Content-Length，靠 EOF 结束）。
                connection.receive(minimumIncompleteLength: 1, maximumLength: 64 * 1024) { _, _, _, _ in
                    let response = "HTTP/1.1 200 OK\r\nContent-Type: text/event-stream\r\nConnection: close\r\n\r\n" + body
                    connection.send(content: Data(response.utf8), completion: .contentProcessed { _ in
                        connection.send(content: nil, isComplete: true, completion: .contentProcessed { _ in
                            connection.cancel()
                        })
                    })
                }
            }
            listener.start(queue: queue)
        }
    }

    func stop() {
        listener.cancel()
    }
}

@Suite("SSE 事件流")
struct SSEStreamTests {
    @Test("空行分隔的帧全部派发，注释心跳被忽略")
    func streamsFrames() async throws {
        let body = """
        : ping\n\n\
        id: 1-0\nevent: stage\ndata: {"stage":"search","status":"started"}\n\n\
        : ping\n\n\
        id: 1-1\nevent: log\ndata: {"level":"info","message":"hello"}\n\n\
        id: 2-0\nevent: succeeded\ndata: {"answer_id":"a1"}\n\n
        """
        let server = try MiniSSEServer(body: body)
        await server.start()
        defer { server.stop() }

        let client = APIClient(
            baseURL: URL(string: "http://127.0.0.1:\(server.port)")!,
            tokenProvider: { "token" },
            onUnauthorized: {}
        )

        var live = JobLive.empty
        var events: [SSEEvent] = []
        for try await event in await client.events(jobID: "job-1", lastEventID: "0-0") {
            events.append(event)
            live = live.applying(event)
        }

        #expect(events.map(\.event) == ["stage", "log", "succeeded"])
        #expect(events.map(\.id) == ["1-0", "1-1", "2-0"])
        #expect(live.stages[.search]?.status == .running)
        #expect(live.logs.map(\.message) == ["hello"])
        #expect(live.terminal == .succeeded(answerId: "a1", items: nil, papers: nil))
    }
}
