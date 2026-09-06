import Foundation

public struct ValidationIssue: Codable, Sendable, Hashable {
    public var loc: [String]
    public var msg: String
    public var type: String

    public init(loc: [String], msg: String, type: String) {
        self.loc = loc
        self.msg = msg
        self.type = type
    }

    /// FastAPI 的 `loc` 元素可能是字符串或整数（数组下标），统一转成字符串。
    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let rawLoc = try c.decodeIfPresent([JSONValue].self, forKey: .loc) ?? []
        loc = rawLoc.map { $0.stringValue ?? $0.intValue.map(String.init) ?? "" }
        msg = try c.decodeIfPresent(String.self, forKey: .msg) ?? ""
        type = try c.decodeIfPresent(String.self, forKey: .type) ?? ""
    }
}

/// RFC 9457 Problem Details。全部字段可选：反向代理或网关可能返回非标准错误体。
public struct Problem: Codable, Sendable, Hashable {
    public var type: String?
    public var title: String?
    public var status: Int?
    public var detail: String?
    public var instance: String?
    public var code: String?
    public var errors: [ValidationIssue]?

    public init(
        type: String? = nil,
        title: String? = nil,
        status: Int? = nil,
        detail: String? = nil,
        instance: String? = nil,
        code: String? = nil,
        errors: [ValidationIssue]? = nil
    ) {
        self.type = type
        self.title = title
        self.status = status
        self.detail = detail
        self.instance = instance
        self.code = code
        self.errors = errors
    }
}
