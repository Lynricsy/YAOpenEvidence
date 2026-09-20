import Foundation

/// `auto` 只作为请求参数出现；响应里只会是 `pubmed` / `s2`。
public enum LiteratureSource: String, Codable, Sendable, Hashable, CaseIterable {
    case auto
    case pubmed
    case s2

    public var label: String {
        switch self {
        case .auto: "自动"
        case .pubmed: "PubMed"
        case .s2: "Semantic Scholar"
        }
    }
}

public struct RankInfo: Codable, Sendable, Hashable {
    public var title: String
    public var issns: [String]
    public var zone: Int
    public var quartile: String
    public var sjr: Double?
    public var hIndex: String?
    public var categories: String
    public var top: Bool
    public var source: String
}

public struct RankQuery: Codable, Sendable, Hashable {
    public var issn: String
    public var title: String
}

public struct RankResult: Codable, Sendable, Hashable {
    public var query: RankQuery
    public var found: Bool
    public var rank: RankInfo?
    public var label: String
}

/// 上游检索结果的一条记录。注意与 answer/paper 系不同：未知字段是 null 而非空串。
public struct LiteratureRecord: Codable, Sendable, Hashable, Identifiable {
    public var source: LiteratureSource
    public var id: String
    public var pmid: String?
    public var pmcid: String?
    public var doi: String?
    public var s2Id: String?
    public var title: String
    public var abstract: String?
    public var year: String?
    public var journal: String?
    public var issn: String?
    public var authors: [String]
    public var types: [String]
    public var citedBy: Int?
    public var openAccessPdf: String?
    public var tldr: String?
    public var rank: RankInfo?

    /// 取全文时使用的标识：优先 PMCID，其次 PMID，再次 DOI。
    public var fulltextIdent: String? {
        for candidate in [pmcid, pmid, doi] {
            if let value = candidate?.trimmingCharacters(in: .whitespaces), !value.isEmpty {
                return value
            }
        }
        return nil
    }
}

public struct LiteratureSearchResult: Codable, Sendable, Hashable {
    public var source: LiteratureSource
    public var total: Int
    public var items: [LiteratureRecord]
    public var fallbackReason: String?
}

public struct FulltextSection: Codable, Sendable, Hashable, Identifiable {
    public var title: String
    public var chars: Int

    public var id: String { title }
}

public struct FulltextResult: Codable, Sendable, Hashable {
    public var pmcid: String
    public var citation: String
    public var sections: [FulltextSection]
    public var abstract: String
    public var section: String?
    public var text: String?
    public var truncated: Bool
}

public struct LiteratureRecordList: Codable, Sendable, Hashable {
    public var items: [LiteratureRecord]
}
