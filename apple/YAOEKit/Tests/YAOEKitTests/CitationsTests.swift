import Testing
@testable import YAOEKit

@Suite("Citations")
struct CitationsTests {
    @Test("解析渲染稿引用链接")
    func parseAnswerLink() {
        #expect(Citations.parseAnswerLink("/v1/answers/abc/papers/3/markdown#p7") == CitationRef(n: 3, pid: 7))
        #expect(Citations.parseAnswerLink("/v1/answers/abc/papers/3/markdown") == CitationRef(n: 3, pid: nil))
        #expect(Citations.parseAnswerLink("https://example.com") == nil)
        #expect(Citations.parseAnswerLink("/v1/answers/abc/papers/3/markdown#other") == nil)
    }

    @Test("统计正文引用次数")
    func countMarkers() {
        let counts = Citations.countMarkers(in: "结论 [1¶3] 与 [1] 一致，[2¶9] 不同，[2024] 只是年份。")
        #expect(counts[1] == 2)
        #expect(counts[2] == 1)
        #expect(counts[2024] == nil)
    }

    @Test("引用色板按 n 循环")
    func palette() {
        #expect(Citations.colorHex(n: 1) == "#087f96")
        #expect(Citations.colorHex(n: 8) == "#7d5b9e")
        #expect(Citations.colorHex(n: 9) == "#087f96")
    }
}
