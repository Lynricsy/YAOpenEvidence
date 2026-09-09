import Testing
@testable import YAOEKit

@Suite("工具展示")
struct ToolPresentationTests {
    @Test("参数摘要按键优先级取第一个非 null 的值")
    func argKeyPriority() {
        #expect(ToolPresentation.describeArgs(.object([
            "name": .string("N"), "query": .string("Q"), "paper_id": .string("P"),
        ])) == "「Q」")
        #expect(ToolPresentation.describeArgs(.object([
            "paper_id": .string("P"), "path": .string("x.pdf"),
        ])) == "「P」")
        // null 与「键不存在」等价，继续往后找。
        #expect(ToolPresentation.describeArgs(.object([
            "query": .null, "path": .string("x.pdf"),
        ])) == "「x.pdf」")
        // 一个登记键都没有时给空串，不要把无关参数摊到轨迹上。
        #expect(ToolPresentation.describeArgs(.object(["limit": .number(5)])) == "")
    }

    @Test("超长参数截断到 60 字，section 追加在后面")
    func clipsAndAppendsSection() {
        let exact = String(repeating: "阿", count: 60)
        #expect(ToolPresentation.describeArgs(.object(["query": .string(exact)])) == "「\(exact)」")
        let long = String(repeating: "阿", count: 80)
        #expect(ToolPresentation.describeArgs(.object([
            "query": .string(long), "section": .string("Methods"),
        ])) == "「\(exact)…」 · Methods")
    }

    @Test("耗时保留一位小数，未知给空串")
    func duration() {
        #expect(ToolPresentation.formatDuration(820) == "0.8s")
        #expect(ToolPresentation.formatDuration(12340) == "12.3s")
        #expect(ToolPresentation.formatDuration(nil) == "")
    }

    @Test("未登记的工具退回 server/tool 原文")
    func labels() {
        #expect(ToolPresentation.label(server: "semantic_scholar", tool: "read_pdf") == "读取 PDF")
        #expect(ToolPresentation.symbol(tool: "read_pdf") == "doc.richtext")
        #expect(ToolPresentation.label(server: "shell", tool: "mystery") == "shell/mystery")
        #expect(ToolPresentation.symbol(tool: "mystery") == "wrench")
    }
}
