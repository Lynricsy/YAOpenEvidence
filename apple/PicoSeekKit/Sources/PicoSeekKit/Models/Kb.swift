import Foundation

public enum KbKind: String, Codable, Sendable, Hashable, CaseIterable {
    case fact
    case paragraph

    public var label: String {
        switch self {
        case .fact: "事实"
        case .paragraph: "段落"
        }
    }
}

/// 知识库检索命中的一条事实或段落。
public struct KbHit: Codable, Sendable, Hashable {
    public var kind: KbKind
    public var pmid: String
    public var doi: String
    public var pmcid: String
    public var title: String
    public var year: String
    public var journal: String
    public var quartile: String
    public var source: String
    public var authors: String
    public var pid: Int?
    public var sec: String?
    public var page: Int?
    public var text: String
    public var textZh: String?
    public var factKind: String?
    public var quote: String?
    public var verified: Bool?
    public var score: Double
}

public struct KbSearchResult: Codable, Sendable, Hashable {
    public var query: String
    public var items: [KbHit]
}

public struct KbStats: Codable, Sendable, Hashable {
    public var items: Int
    public var papers: Int
    public var byKind: [String: Int]
    public var embedder: String?
    public var dim: Int?
}
