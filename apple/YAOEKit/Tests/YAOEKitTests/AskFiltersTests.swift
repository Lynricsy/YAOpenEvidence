import Foundation
import Testing
@testable import YAOEKit

@Suite("AskFilters")
struct AskFiltersTests {
    private func encoded(_ create: AnswerCreate) throws -> [String: Any] {
        let data = try JSONCoding.encoder.encode(create)
        return try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }

    @Test("默认筛选只发 years，不发 year_from / keep_unranked")
    func defaultPayload() throws {
        let payload = try encoded(AskFilters.default.answerCreate(question: "  问题  "))
        #expect(payload["question"] as? String == "问题")
        #expect(payload["years"] as? Int == 3)
        #expect(payload["year_from"] == nil)
        #expect(payload["keep_unranked"] == nil)
        #expect(payload["kb_hits"] as? Int == 0)
        #expect(payload["max_chars"] as? Int == 28000)
        #expect(payload["engine"] as? String == "ask")
    }

    @Test("智能体引擎不发字符预算 / 知识库命中 / 含未收录期刊")
    func codexPayload() throws {
        var filters = AskFilters.default
        filters.engine = .codex
        filters.quartiles = [1]
        filters.keepUnranked = true
        filters.kbHits = 5
        let payload = try encoded(filters.answerCreate(question: "问题"))
        #expect(payload["engine"] as? String == "codex")
        #expect(payload["kb_hits"] == nil)
        #expect(payload["max_chars"] == nil)
        #expect(payload["keep_unranked"] == nil)
        // 筛选本身仍然发：它会作为检索要求写进提示词。
        #expect(payload["quartiles"] as? [Int] == [1])
        #expect(payload["years"] as? Int == 3)
        #expect(payload["use_kb"] as? Bool == true)
    }

    @Test("options 里的 engine 能还原，未知值回落标准")
    func engineFromOptions() {
        #expect(AskFilters(options: .object(["engine": .string("codex")])).engine == .codex)
        #expect(AskFilters(options: .object(["engine": .string("quantum")])).engine == .ask)
        #expect(AskFilters(options: .object([:])).engine == .ask)
    }

    @Test("升级前保存的筛选没有 engine 键，仍能解出而不是被整份丢弃")
    func decodesPersistedFiltersWithoutEngine() throws {
        // AppModel 对解码失败只能回落默认值，用户攒下的分区/期刊会被静默清空。
        let legacy = """
        {"quartiles":[1,2],"keep_unranked":true,"year_mode":"range","years":3,
         "year_from":2019,"year_to":2024,"journals":["lancet"],"papers":12,
         "use_kb":false,"kb_hits":4,"max_chars":40000}
        """
        let filters = try JSONCoding.decoder.decode(
            AskFilters.self, from: #require(legacy.data(using: .utf8)))
        #expect(filters.engine == .ask)
        #expect(filters.quartiles == [1, 2])
        #expect(filters.journals == ["lancet"])
        #expect(filters.maxChars == 40000)
    }

    @Test("自定义区间 + 分区时发 year_from/year_to 与 keep_unranked，不发 years")
    func rangePayload() throws {
        var filters = AskFilters.default
        filters.yearMode = .range
        filters.yearFrom = 2019
        filters.yearTo = 2023
        filters.quartiles = [1, 2]
        filters.keepUnranked = true
        let payload = try encoded(filters.answerCreate(question: "问题"))
        #expect(payload["years"] == nil)
        #expect(payload["year_from"] as? Int == 2019)
        #expect(payload["year_to"] as? Int == 2023)
        #expect(payload["keep_unranked"] as? Bool == true)
        #expect(payload["quartiles"] as? [Int] == [1, 2])
    }

    @Test("use_kb 关闭时 kb_hits 强制为 0")
    func kbHitsZeroWhenDisabled() throws {
        var filters = AskFilters.default
        filters.useKb = false
        filters.kbHits = 12
        let payload = try encoded(filters.answerCreate(question: "问题"))
        #expect(payload["use_kb"] as? Bool == false)
        #expect(payload["kb_hits"] as? Int == 0)
    }

    @Test("options 往返保持一致")
    func roundTrip() {
        var filters = AskFilters.default
        filters.yearMode = .range
        filters.yearFrom = 2015
        filters.yearTo = 2020
        filters.quartiles = [2, 1]
        filters.keepUnranked = true
        filters.journals = ["Nature ", "nature", "lancet"]
        filters.papers = 12
        filters.kbHits = 5
        let normalized = filters.normalized(currentYear: 2026)

        let options = JSONValue.object([
            "years": .null,
            "year_from": .number(2015),
            "year_to": .number(2020),
            "quartiles": .array([.number(1), .number(2)]),
            "keep_unranked": .bool(true),
            "journals": .array([.string("nature"), .string("lancet")]),
            "papers": .number(12),
            "use_kb": .bool(true),
            "kb_hits": .number(5),
            "max_chars": .number(28000),
        ])
        #expect(AskFilters(options: options).normalized(currentYear: 2026) == normalized)
        #expect(normalized.journals == ["nature", "lancet"])
    }

    @Test("越界取值回落默认")
    func clamping() {
        var filters = AskFilters.default
        filters.papers = 99
        filters.years = 0
        filters.kbHits = 50
        filters.maxChars = 100
        filters.quartiles = [4, 4, 9, 1]
        let normalized = filters.normalized(currentYear: 2026)
        #expect(normalized.papers == 8)
        #expect(normalized.years == 3)
        #expect(normalized.kbHits == 0)
        #expect(normalized.maxChars == 28000)
        #expect(normalized.quartiles == [1, 4])
    }

    @Test("年份区间校验")
    func yearRangeValidation() {
        var filters = AskFilters.default
        filters.yearMode = .range
        #expect(filters.isYearRangeValid(currentYear: 2026) == false) // 缺起始年
        filters.yearFrom = 2020
        #expect(filters.isYearRangeValid(currentYear: 2026) == true) // 至今
        filters.yearTo = 2019
        #expect(filters.isYearRangeValid(currentYear: 2026) == false) // 结束年早于起始年
        filters.yearTo = 2030
        #expect(filters.isYearRangeValid(currentYear: 2026) == false) // 结束年超过今年
    }

    @Test("摘要文案")
    func summaryText() {
        var filters = AskFilters.default
        #expect(filters.summary == "近3年 · 分区不限 · 8 篇")
        filters.quartiles = [1, 2]
        filters.keepUnranked = true
        filters.journals = ["nature", "lancet"]
        #expect(filters.summary == "近3年 · Q1/Q2 + 未收录 · 期刊含 nature|lancet · 8 篇")
        filters.yearMode = .range
        filters.yearFrom = 2019
        #expect(filters.summary.hasPrefix("2019–至今"))
        filters.yearMode = .any
        #expect(filters.summary.hasPrefix("年份不限"))
    }
}
