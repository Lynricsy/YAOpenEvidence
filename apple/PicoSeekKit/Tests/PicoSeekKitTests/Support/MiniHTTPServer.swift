import Foundation
import Network
import Synchronization

/// 测试用极简 HTTP 服务器：收下一个请求、记下原始报文，回一段固定响应然后关闭连接。
/// 用来在没有真实后端的情况下验证请求构造与流式响应处理。
final class MiniHTTPServer: @unchecked Sendable {
    private let listener: NWListener
    private let responseHead: String
    private let responseBody: String
    private let queue = DispatchQueue(label: "mini-http")
    private let recorded = Mutex<String?>(nil)

    var port: UInt16 { listener.port?.rawValue ?? 0 }

    /// 收到的请求行（形如 `GET /v1/kb/search?q=... HTTP/1.1`）。
    var requestLine: String? {
        recorded.withLock { $0 }?.components(separatedBy: "\r\n").first
    }

    /// 收到的请求头。
    func header(_ name: String) -> String? {
        guard let text = recorded.withLock({ $0 }) else { return nil }
        for line in text.components(separatedBy: "\r\n").dropFirst() {
            let parts = line.split(separator: ":", maxSplits: 1).map(String.init)
            guard parts.count == 2, parts[0].caseInsensitiveCompare(name) == .orderedSame else { continue }
            return parts[1].trimmingCharacters(in: .whitespaces)
        }
        return nil
    }

    init(contentType: String, body: String, status: String = "200 OK") throws {
        responseHead = "HTTP/1.1 \(status)\r\nContent-Type: \(contentType)\r\nConnection: close\r\n\r\n"
        responseBody = body
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
            listener.newConnectionHandler = { [weak self] connection in
                guard let self else { return }
                connection.start(queue: queue)
                connection.receive(minimumIncompleteLength: 1, maximumLength: 64 * 1024) { data, _, _, _ in
                    if let data, let text = String(data: data, encoding: .utf8) {
                        self.recorded.withLock { $0 = text }
                    }
                    let response = Data((self.responseHead + self.responseBody).utf8)
                    connection.send(content: response, completion: .contentProcessed { _ in
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
