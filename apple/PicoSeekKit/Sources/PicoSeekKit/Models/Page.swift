import Foundation

/// 分页信封：`GET /v1/answers`、`/v1/papers`、`/v1/auth/users` 共用。
public struct Page<T: Codable & Sendable & Hashable>: Codable, Sendable, Hashable {
    public var items: [T]
    public var total: Int
    public var limit: Int
    public var offset: Int

    public init(items: [T], total: Int, limit: Int, offset: Int) {
        self.items = items
        self.total = total
        self.limit = limit
        self.offset = offset
    }
}
