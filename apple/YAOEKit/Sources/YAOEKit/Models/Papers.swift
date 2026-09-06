import Foundation

public struct Paragraph: Codable, Sendable, Hashable, Identifiable {
    public var id: Int
    public var sec: String
    public var page: Int?
    public var text: String

    public init(id: Int, sec: String, page: Int? = nil, text: String) {
        self.id = id
        self.sec = sec
        self.page = page
        self.text = text
    }
}

public struct Fact: Codable, Sendable, Hashable {
    public var fact: String
    public var factZh: String
    public var kind: String
    public var pid: Int?
    public var sec: String?
    public var page: Int?
    public var quote: String
    public var score: Double
    public var verified: Bool

    /// 事实类型中文文案（未知类型原样显示）。
    public var kindLabel: String {
        switch kind {
        case "finding": "研究发现"
        case "method": "研究方法"
        case "background": "背景"
        case "limitation": "局限性"
        default: kind
        }
    }
}

/// 模型笔记里的一条引文及其核实结果。
public struct VerifiedQuote: Codable, Sendable, Hashable {
    public var claimedPid: Int
    public var pid: Int?
    public var sec: String?
    public var page: Int?
    public var quote: String
    public var score: Double
    public var verified: Bool
    public var noteSection: String?
    public var keyFinding: Bool
}

/// 共享文献库中的一篇文献。
public struct PaperMeta: Codable, Sendable, Hashable, Identifiable {
    public var key: String
    public var pmid: String
    public var doi: String
    public var pmcid: String
    public var title: String
    public var year: String
    public var journal: String
    public var issn: String
    public var quartile: String
    public var authors: String
    public var source: String
    public var types: [String]
    public var indexedAt: Date?
    public var nParagraphs: Int
    public var nFacts: Int

    public var id: String { key }
}

public struct ParagraphList: Codable, Sendable, Hashable {
    public var items: [Paragraph]
}

public struct FactList: Codable, Sendable, Hashable {
    public var items: [Fact]
}
