import Foundation

/// 一次请求的描述。`path` 不含 `/v1` 前缀，由 `APIClient` 统一拼接。
public struct Endpoint: Sendable {
    public var method: String
    public var path: String
    public var query: [URLQueryItem]
    public var body: Data?
    public var requiresAuth: Bool

    public init(
        method: String = "GET",
        path: String,
        query: [URLQueryItem] = [],
        body: Data? = nil,
        requiresAuth: Bool = true
    ) {
        self.method = method
        self.path = path
        self.query = query
        self.body = body
        self.requiresAuth = requiresAuth
    }

    /// 路径参数转义：`key` 允许 `.-_`，仍需防止斜杠等注入。
    public static func escape(_ component: String) -> String {
        component.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? component
    }
}
