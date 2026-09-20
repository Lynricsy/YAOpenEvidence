import Foundation

/// 已加载的一张期刊分区表。`year` 由后端从文件名推断，推不出来为 nil。
public struct RankTable: Codable, Sendable, Hashable {
    public var file: String
    public var year: Int?
    public var journals: Int
    public var source: String
}

/// 分区筛选的依据。`tables` 为空说明 Q1–Q4 过滤不会生效。
public struct RankTables: Codable, Sendable, Hashable {
    public var tables: [RankTable]
    public var issns: Int
    public var titles: Int
    public var loadedAt: Date?
}

/// 机构订阅登录态的只读观测；决定付费全文能不能取到。
public struct PaywallStatus: Codable, Sendable, Hashable {
    public var configured: Bool
    public var savedAt: Date?
    public var finalUrl: String?
    public var hasSessionStorage: Bool
    public var hasContextMeta: Bool
    public var playwrightAvailable: Bool
}
