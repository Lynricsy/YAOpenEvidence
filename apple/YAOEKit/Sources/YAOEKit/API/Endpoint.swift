import Foundation

/// 一次请求的描述。`path` 不含 `/v1` 前缀，由 `APIClient` 统一拼接。
public struct Endpoint: Sendable {
    public var method: String
    public var path: String
    public var query: [URLQueryItem]
    public var body: Data?
    public var requiresAuth: Bool
    /// 除 2xx 之外也视为成功、需要按正常模型解码的状态码（如就绪探针的 503）。
    public var alsoAccept: Set<Int>

    public init(
        method: String = "GET",
        path: String,
        query: [URLQueryItem] = [],
        body: Data? = nil,
        requiresAuth: Bool = true,
        alsoAccept: Set<Int> = []
    ) {
        self.method = method
        self.path = path
        self.query = query
        self.body = body
        self.requiresAuth = requiresAuth
        self.alsoAccept = alsoAccept
    }

    /// 路径参数转义：`key` 允许 `.-_`，仍需防止斜杠等注入。
    public static func escape(_ component: String) -> String {
        component.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? component
    }

    /// 查询参数按 RFC 3986 unreserved 字符集编码：`+`、空格、CJK 一律百分号转义，
    /// 避免服务端把 `+` 当成空格。
    public static func encodeQueryComponent(_ text: String) -> String {
        text.addingPercentEncoding(withAllowedCharacters: queryUnreserved) ?? text
    }

    private static let queryUnreserved = CharacterSet(
        charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"
    )
}
