import Foundation

/// 后端 REST + SSE 客户端。所有请求都走同一个 `URLSession`，鉴权令牌由宿主提供。
public actor APIClient {
    private let baseURL: URL
    private let tokenProvider: @Sendable () -> String?
    private let onUnauthorized: @Sendable () -> Void
    private let session: URLSession

    public init(
        baseURL: URL,
        tokenProvider: @escaping @Sendable () -> String?,
        onUnauthorized: @escaping @Sendable () -> Void
    ) {
        self.baseURL = baseURL
        self.tokenProvider = tokenProvider
        self.onUnauthorized = onUnauthorized
        let config = URLSessionConfiguration.ephemeral
        // 知识库首次检索要加载嵌入模型，约 15 秒；留足余量。
        config.timeoutIntervalForRequest = 60
        config.waitsForConnectivity = false
        session = URLSession(configuration: config)
    }

    // MARK: - 请求

    public func json<T: Decodable & Sendable>(_ endpoint: Endpoint) async throws(APIError) -> T {
        let data = try await perform(endpoint, accept: "application/json").0
        do {
            return try JSONCoding.decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decoding(underlying: error)
        }
    }

    public func text(_ endpoint: Endpoint) async throws(APIError) -> String {
        let data = try await perform(endpoint, accept: "text/markdown").0
        return String(decoding: data, as: UTF8.self)
    }

    public func noContent(_ endpoint: Endpoint) async throws(APIError) {
        _ = try await perform(endpoint, accept: "application/json")
    }

    /// 二进制下载的结果。文件名来自服务端，客户端不自己拼。
    public struct Download: Sendable {
        public var data: Data
        public var filename: String?

        public init(data: Data, filename: String?) {
            self.data = data
            self.filename = filename
        }
    }

    public func download(_ endpoint: Endpoint, accept: String) async throws(APIError) -> Download {
        let (data, http) = try await perform(endpoint, accept: accept)
        return Download(
            data: data,
            filename: Self.filename(fromContentDisposition: http.value(forHTTPHeaderField: "Content-Disposition"))
        )
    }

    /// 附件文件名：优先 RFC 5987 的 `filename*=UTF-8''…`（服务端用它传中文，百分号解码失败按缺失处理），
    /// 其次退回 ASCII 的 `filename="…"`；都没有返回 nil，由调用方兜底命名。
    public static func filename(fromContentDisposition header: String?) -> String? {
        guard let header else { return nil }
        let range = NSRange(header.startIndex ..< header.endIndex, in: header)
        if let match = extendedFilenameRegex.firstMatch(in: header, range: range) {
            guard let value = Range(match.range(at: 1), in: header) else { return nil }
            return String(header[value]).removingPercentEncoding
        }
        if let match = quotedFilenameRegex.firstMatch(in: header, range: range),
           let value = Range(match.range(at: 1), in: header) {
            return String(header[value])
        }
        return nil
    }

    private static let extendedFilenameRegex = try! NSRegularExpression(
        pattern: #"filename\*\s*=\s*UTF-8''([^;]+)"#,
        options: [.caseInsensitive]
    )
    private static let quotedFilenameRegex = try! NSRegularExpression(
        pattern: #"filename\s*=\s*"([^"]+)""#,
        options: [.caseInsensitive]
    )

    private func perform(_ endpoint: Endpoint, accept: String) async throws(APIError) -> (Data, HTTPURLResponse) {
        let request = try makeRequest(endpoint, accept: accept)
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.transport(underlying: error)
        }
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200 ..< 300).contains(http.statusCode) || endpoint.alsoAccept.contains(http.statusCode) else {
            throw failure(status: http.statusCode, headers: http, body: data, path: endpoint.path)
        }
        return (data, http)
    }

    private func makeRequest(_ endpoint: Endpoint, accept: String) throws(APIError) -> URLRequest {
        var components = URLComponents(
            url: baseURL.appending(path: "/\(YAOEKit.apiVersion)\(endpoint.path)"),
            resolvingAgainstBaseURL: false
        )
        // 不能用 `queryItems`：它保留字面 `+`，而 FastAPI 按表单规则把 `+` 解成空格，
        // 会静默改写 `HER2+`、DOI 与全文章节名。这里自己按 unreserved 字符集编码。
        if !endpoint.query.isEmpty {
            components?.percentEncodedQuery = endpoint.query
                .map { "\(Endpoint.encodeQueryComponent($0.name))=\(Endpoint.encodeQueryComponent($0.value ?? ""))" }
                .joined(separator: "&")
        }
        guard let url = components?.url else { throw APIError.invalidResponse }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.setValue(accept, forHTTPHeaderField: "Accept")
        if let body = endpoint.body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        if endpoint.requiresAuth, let token = tokenProvider() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    /// 非 2xx → `APIError.http`；登录端点自身的 401 不触发会话失效。
    private func failure(status: Int, headers: HTTPURLResponse, body: Data, path: String) -> APIError {
        if status == 401, path != "/auth/login" { onUnauthorized() }
        let problem = (try? JSONCoding.decoder.decode(Problem.self, from: body)) ?? Problem()
        let retryAfter = headers.value(forHTTPHeaderField: "Retry-After").flatMap(Int.init).flatMap { $0 > 0 ? $0 : nil }
        return .http(
            status: status,
            code: problem.code ?? "internal_error",
            detail: problem.detail ?? "",
            errors: problem.errors,
            retryAfter: retryAfter
        )
    }

    // MARK: - SSE

    /// 订阅任务事件流。断线重连由调用方负责（传入上一次收到的 `Last-Event-ID`）。
    public func events(jobID: String, lastEventID: String) -> AsyncThrowingStream<SSEEvent, any Error> {
        let path = "/jobs/\(Endpoint.escape(jobID))/events"
        var request = URLRequest(url: baseURL.appending(path: "/\(YAOEKit.apiVersion)\(path)"))
        request.httpMethod = "GET"
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        request.setValue(lastEventID, forHTTPHeaderField: "Last-Event-ID")
        if let token = tokenProvider() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        // 心跳约 15 秒一次；90 秒无任何字节才判定为断流。
        request.timeoutInterval = 90

        let session = session
        let streamRequest = request
        let notifyUnauthorized = onUnauthorized
        let onFailure: @Sendable (Int, HTTPURLResponse, Data) -> APIError = { status, http, body in
            if status == 401 { notifyUnauthorized() }
            let problem = (try? JSONCoding.decoder.decode(Problem.self, from: body)) ?? Problem()
            let retryAfter = http.value(forHTTPHeaderField: "Retry-After").flatMap(Int.init).flatMap { $0 > 0 ? $0 : nil }
            return .http(
                status: status,
                code: problem.code ?? "internal_error",
                detail: problem.detail ?? "",
                errors: problem.errors,
                retryAfter: retryAfter
            )
        }

        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let (bytes, response) = try await session.bytes(for: streamRequest)
                    guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
                    guard (200 ..< 300).contains(http.statusCode) else {
                        var body = Data()
                        for try await byte in bytes { body.append(byte) }
                        throw onFailure(http.statusCode, http, body)
                    }
                    // 不能用 `bytes.lines`：Foundation 的行序列会吞掉空行，
                    // 而空行正是 SSE 的帧分隔符，用它会导致一帧都派发不出来。
                    var parser = SSEParser()
                    var line = [UInt8]()
                    for try await byte in bytes {
                        guard byte != UInt8(ascii: "\n") else {
                            let text = String(decoding: line, as: UTF8.self)
                            line.removeAll(keepingCapacity: true)
                            if let event = parser.feed(line: text) { continuation.yield(event) }
                            continue
                        }
                        line.append(byte)
                    }
                    continuation.finish()
                } catch let error as APIError {
                    continuation.finish(throwing: error)
                } catch {
                    continuation.finish(throwing: APIError.transport(underlying: error))
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
