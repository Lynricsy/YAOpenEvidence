import Foundation

/// 提问筛选条件。与 Web 端 `FilterState` 一一对应，取值夹紧规则逐字移植 `frontend/src/lib/filters.ts`。
public struct AskFilters: Codable, Sendable, Hashable {
    public enum YearMode: String, Codable, Sendable, Hashable, CaseIterable {
        case any
        case recent
        case range
    }

    public var quartiles: [Int]
    public var keepUnranked: Bool
    public var yearMode: YearMode
    public var years: Int
    public var yearFrom: Int?
    public var yearTo: Int?
    public var journals: [String]
    public var papers: Int
    public var useKb: Bool
    public var kbHits: Int
    public var maxChars: Int

    public init(
        quartiles: [Int] = [],
        keepUnranked: Bool = false,
        yearMode: YearMode = .recent,
        years: Int = 3,
        yearFrom: Int? = nil,
        yearTo: Int? = nil,
        journals: [String] = [],
        papers: Int = 8,
        useKb: Bool = true,
        kbHits: Int = 0,
        maxChars: Int = 28000
    ) {
        self.quartiles = quartiles
        self.keepUnranked = keepUnranked
        self.yearMode = yearMode
        self.years = years
        self.yearFrom = yearFrom
        self.yearTo = yearTo
        self.journals = journals
        self.papers = papers
        self.useKb = useKb
        self.kbHits = kbHits
        self.maxChars = maxChars
    }

    public static let `default` = AskFilters()

    /// 供筛选表单使用的单篇字符预算候选值。
    public static let maxCharsOptions = [12000, 20000, 28000, 40000, 60000]

    /// 期刊快捷预设：展示名 → 实际关键词。
    public static let journalPresets: [(label: String, value: String)] = [
        ("Nature", "nature"),
        ("Lancet", "lancet"),
        ("NEJM", "new england"),
        ("JAMA", "jama"),
        ("BMJ", "bmj"),
        ("Cell", "cell"),
    ]

    // MARK: - 归一化

    /// 逐字段夹紧到后端接受的范围。越界或非法值一律回落默认值。
    public func normalized(currentYear: Int = Calendar(identifier: .gregorian).component(.year, from: Date())) -> AskFilters {
        var out = AskFilters()
        out.quartiles = Array(Set(quartiles.filter { $0 >= 1 && $0 <= 4 })).sorted()
        out.keepUnranked = keepUnranked
        out.yearMode = yearMode
        out.years = Self.clamp(years, fallback: 3, min: 1, max: 50)
        out.yearFrom = yearFrom.map { Self.clamp($0, fallback: 1900, min: 1900, max: 2100) }
        out.yearTo = yearTo.map { Self.clamp($0, fallback: currentYear, min: 1900, max: 2100) }
        var seen = Set<String>()
        out.journals = journals
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { !$0.isEmpty && $0.count <= 100 }
            .filter { seen.insert($0).inserted }
        out.papers = Self.clamp(papers, fallback: 8, min: 1, max: 30)
        out.useKb = useKb
        out.kbHits = Self.clamp(kbHits, fallback: 0, min: 0, max: 20)
        out.maxChars = Self.clamp(maxChars, fallback: 28000, min: 4000, max: 60000)
        return out
    }

    private static func clamp(_ value: Int, fallback: Int, min: Int, max: Int) -> Int {
        value >= min && value <= max ? value : fallback
    }

    /// 自定义年份区间是否可提交。
    public func isYearRangeValid(currentYear: Int = Calendar(identifier: .gregorian).component(.year, from: Date())) -> Bool {
        guard yearMode == .range else { return true }
        guard let from = yearFrom, from >= 1900, from <= currentYear else { return false }
        guard let to = yearTo else { return true }
        return to >= from && to <= currentYear
    }

    // MARK: - 转换

    /// 生成创建任务的请求体：years 与 year_from/year_to 互斥，keep_unranked 仅在选了分区时发送。
    public func answerCreate(question: String) -> AnswerCreate {
        AnswerCreate(
            question: question.trimmingCharacters(in: .whitespacesAndNewlines),
            papers: papers,
            years: yearMode == .recent ? years : nil,
            yearFrom: yearMode == .range ? yearFrom : nil,
            yearTo: yearMode == .range ? yearTo : nil,
            quartiles: quartiles,
            journals: journals,
            keepUnranked: quartiles.isEmpty ? nil : keepUnranked,
            useKb: useKb,
            kbHits: useKb ? kbHits : 0,
            maxChars: maxChars
        )
    }

    /// 从 `Answer.options` 还原筛选条件（用于「沿用此次筛选重新提问」）。
    public init(options: JSONValue) {
        let years = options["years"]?.intValue
        let yearFrom = options["year_from"]?.intValue
        self.init(
            quartiles: options["quartiles"]?.arrayValue?.compactMap(\.intValue) ?? [],
            keepUnranked: options["keep_unranked"]?.boolValue ?? false,
            yearMode: years != nil ? .recent : (yearFrom != nil ? .range : .any),
            years: years ?? 3,
            yearFrom: yearFrom,
            yearTo: options["year_to"]?.intValue,
            journals: options["journals"]?.arrayValue?.compactMap(\.stringValue) ?? [],
            papers: options["papers"]?.intValue ?? 8,
            useKb: options["use_kb"]?.boolValue ?? true,
            kbHits: options["kb_hits"]?.intValue ?? 0,
            maxChars: options["max_chars"]?.intValue ?? 28000
        )
    }

    /// 一行式摘要，例如「近3年 · Q1/Q2 + 未收录 · 期刊含 nature|lancet · 8 篇」。
    public var summary: String {
        var parts: [String] = []
        switch yearMode {
        case .recent: parts.append("近\(years)年")
        case .range: parts.append("\(yearFrom.map(String.init) ?? "起始年")–\(yearTo.map(String.init) ?? "至今")")
        case .any: parts.append("年份不限")
        }
        if quartiles.isEmpty {
            parts.append("分区不限")
        } else {
            parts.append(quartiles.map { "Q\($0)" }.joined(separator: "/") + (keepUnranked ? " + 未收录" : ""))
        }
        if !journals.isEmpty { parts.append("期刊含 " + journals.joined(separator: "|")) }
        parts.append("\(papers) 篇")
        return parts.joined(separator: " · ")
    }
}
