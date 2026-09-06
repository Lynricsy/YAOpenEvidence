import Foundation

public enum AnswerStatus: String, Codable, Sendable, Hashable, CaseIterable {
    case queued
    case running
    case ready
    case failed
    case cancelled

    /// 任务尚未进入终态（需要 SSE / 轮询继续跟踪）。
    public var isActive: Bool { self == .queued || self == .running }
}

public struct JobError: Codable, Sendable, Hashable {
    public var code: String
    public var message: String

    public init(code: String, message: String) {
        self.code = code
        self.message = message
    }
}

/// 一篇被阅读的文献在答案中的元信息。注意 `year` 是字符串，未知字段一律为 `""`。
public struct AnswerPaper: Codable, Sendable, Hashable, Identifiable {
    public var n: Int
    public var pmid: String
    public var doi: String
    public var pmcid: String
    public var title: String
    public var year: String
    public var journal: String
    public var issn: String
    public var authors: String
    public var quartile: String
    public var rankLabel: String
    public var source: PaperSource
    public var relevance: Int?
    public var nParagraphs: Int
    public var nCitations: Int
    public var nCitationsVerified: Int

    public var id: Int { n }
}

public enum PaperSource: String, Codable, Sendable, Hashable {
    case pmc
    case pdf
    case inst
    case abstract

    /// 后端未来新增来源时不至于整份答案解码失败。
    public init(from decoder: any Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = PaperSource(rawValue: raw) ?? .abstract
    }

    public var label: String {
        switch self {
        case .pmc: "全文 · PMC"
        case .pdf: "全文 · PDF"
        case .inst: "全文 · 机构"
        case .abstract: "仅摘要"
        }
    }
}

/// 答案正文引用到的一个原文段落。
public struct Citation: Codable, Sendable, Hashable {
    public var n: Int
    public var pmid: String
    public var pid: Int
    public var sec: String
    public var page: Int?
    public var text: String
    public var quotes: [String]
    public var fromMarker: Bool
}

public struct AnswerSummary: Codable, Sendable, Hashable, Identifiable {
    public var id: String
    public var jobId: String?
    public var status: AnswerStatus
    public var question: String
    public var filtersLabel: String?
    public var nPapers: Int?
    public var nFulltext: Int?
    public var createdAt: Date
    public var finishedAt: Date?
    public var error: JobError?
}

public struct Answer: Codable, Sendable, Hashable, Identifiable {
    public var id: String
    public var jobId: String?
    public var status: AnswerStatus
    public var question: String
    public var filtersLabel: String?
    public var nPapers: Int?
    public var nFulltext: Int?
    public var createdAt: Date
    public var finishedAt: Date?
    public var error: JobError?
    public var questionEn: String?
    public var queries: [String]
    @DefaultJSONObject public var options: JSONValue
    public var startedAt: Date?
    public var papers: [AnswerPaper]
    public var bodyMd: String?
    public var citations: [Citation]
    public var kbHits: [KbHit]
}

/// 逐篇阅读材料：在 `AnswerPaper` 之上追加笔记、核实引文、事实与全文。
public struct AnswerPaperDetail: Codable, Sendable, Hashable {
    public var n: Int
    public var pmid: String
    public var doi: String
    public var pmcid: String
    public var title: String
    public var year: String
    public var journal: String
    public var issn: String
    public var authors: String
    public var quartile: String
    public var rankLabel: String
    public var source: PaperSource
    public var relevance: Int?
    public var nParagraphs: Int
    public var nCitations: Int
    public var nCitationsVerified: Int
    public var notesMd: String
    public var citations: [VerifiedQuote]
    public var facts: [Fact]
    public var paragraphs: [Paragraph]
    public var fulltextMd: String
}

/// 创建问答任务的请求体。可选字段为 nil 时不编码（后端对 years / year_from 互斥有校验）。
public struct AnswerCreate: Codable, Sendable, Hashable {
    public var question: String
    public var papers: Int
    public var years: Int?
    public var yearFrom: Int?
    public var yearTo: Int?
    public var quartiles: [Int]
    public var journals: [String]
    public var keepUnranked: Bool?
    public var useKb: Bool
    public var kbHits: Int
    public var maxChars: Int

    public init(
        question: String,
        papers: Int,
        years: Int? = nil,
        yearFrom: Int? = nil,
        yearTo: Int? = nil,
        quartiles: [Int] = [],
        journals: [String] = [],
        keepUnranked: Bool? = nil,
        useKb: Bool = true,
        kbHits: Int = 0,
        maxChars: Int = 28000
    ) {
        self.question = question
        self.papers = papers
        self.years = years
        self.yearFrom = yearFrom
        self.yearTo = yearTo
        self.quartiles = quartiles
        self.journals = journals
        self.keepUnranked = keepUnranked
        self.useKb = useKb
        self.kbHits = kbHits
        self.maxChars = maxChars
    }
}
