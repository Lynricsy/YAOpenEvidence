import Foundation

public struct HealthResponse: Codable, Sendable, Hashable {
    public var status: String
    public var version: String
    public var time: Date
}

public struct DependencyCheck: Codable, Sendable, Hashable {
    public var ok: Bool
    public var detail: String
}

public struct ReadinessChecks: Codable, Sendable, Hashable {
    public var db: DependencyCheck
    public var redis: DependencyCheck
    public var llm: DependencyCheck
    public var kb: DependencyCheck
    public var ranks: DependencyCheck
}

/// `/v1/health/ready` 是唯一一个非 2xx 也不返回 Problem 的端点（503 仍是本模型）。
public struct ReadinessResponse: Codable, Sendable, Hashable {
    public var status: String
    public var checks: ReadinessChecks
}
