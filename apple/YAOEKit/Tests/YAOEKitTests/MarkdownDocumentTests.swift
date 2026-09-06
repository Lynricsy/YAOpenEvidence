import Foundation
import Testing
@testable import YAOEKit

@Suite("MarkdownDocument")
struct MarkdownDocumentTests {
    private func runs(of block: MarkdownBlock?) -> [InlineRun] {
        switch block {
        case .paragraph(let runs, _): runs
        case .heading(_, let runs): runs
        default: []
        }
    }

    @Test("裸标记只在 1...limit 内识别为引用")
    func markersWithinLimit() {
        let blocks = MarkdownDocument.parse("A[1¶12] B[2] C[9] D[2024]", citationLimit: 3)
        let citations = runs(of: blocks.first).compactMap(\.citation)
        #expect(citations == [CitationRef(n: 1, pid: 12), CitationRef(n: 2, pid: nil)])
        #expect(MarkdownDocument.plainText(of: runs(of: blocks.first)) == "A[1¶12] B[2] C[9] D[2024]")
    }

    @Test("citationLimit 为 nil 时不识别裸标记")
    func noMarkersWithoutLimit() {
        let blocks = MarkdownDocument.parse("A[1¶12]", citationLimit: nil)
        #expect(runs(of: blocks.first).compactMap(\.citation).isEmpty)
    }

    @Test("链接与行内代码里的方括号不算引用")
    func linksAndCodeAreNotMarkers() {
        let blocks = MarkdownDocument.parse("[1](https://example.com) 与 `[2]`", citationLimit: 5)
        let paragraph = runs(of: blocks.first)
        #expect(paragraph.compactMap(\.citation).isEmpty)
        #expect(paragraph.contains { $0.link?.absoluteString == "https://example.com" })
        #expect(paragraph.contains { $0.style.contains(.code) && $0.text == "[2]" })
    }

    @Test("反斜杠转义的标记不识别")
    func escapedMarkerIgnored() {
        let blocks = MarkdownDocument.parse(#"A\[1] B[2]"#, citationLimit: 5)
        let paragraph = runs(of: blocks.first)
        #expect(paragraph.compactMap(\.citation) == [CitationRef(n: 2, pid: nil)])
        #expect(MarkdownDocument.plainText(of: paragraph) == "A[1] B[2]")
    }

    @Test("渲染稿链接形式的引用")
    func answerLinkCitation() {
        let blocks = MarkdownDocument.parse("见 [3¶7](/v1/answers/x/papers/3/markdown#p7)。", citationLimit: nil)
        let paragraph = runs(of: blocks.first)
        #expect(paragraph.compactMap(\.citation) == [CitationRef(n: 3, pid: 7)])
        #expect(paragraph.first { $0.citation != nil }?.text == "3¶7")
    }

    @Test("段落锚点与加粗段号")
    func paragraphAnchor() {
        let blocks = MarkdownDocument.parse(#"<a id="p12"></a>**¶12** 正文内容"#, citationLimit: nil)
        guard case .paragraph(let runs, let anchor) = blocks.first else {
            Issue.record("首块不是段落：\(String(describing: blocks.first))")
            return
        }
        #expect(anchor == 12)
        #expect(runs.first?.text == "¶12")
        #expect(runs.first?.style.contains(.bold) == true)
        #expect(MarkdownDocument.plainText(of: runs) == "¶12 正文内容")
    }

    @Test("标题、列表、引用块、代码块与分隔线")
    func blockKinds() {
        let source = """
        # 标题

        - 甲
        - 乙

        1. 第一
        2. 第二

        > 引文

        ```swift
        let x = 1
        ```

        ---
        """
        let blocks = MarkdownDocument.parse(source, citationLimit: nil)
        #expect(blocks.count == 6)
        if case .heading(let level, _) = blocks[0] { #expect(level == 1) } else { Issue.record("缺少标题") }
        if case .list(let ordered, _, let items) = blocks[1] {
            #expect(ordered == false)
            #expect(items.count == 2)
        } else {
            Issue.record("缺少无序列表")
        }
        if case .list(let ordered, let start, _) = blocks[2] {
            #expect(ordered == true)
            #expect(start == 1)
        } else {
            Issue.record("缺少有序列表")
        }
        if case .blockQuote(let inner) = blocks[3] { #expect(inner.count == 1) } else { Issue.record("缺少引用块") }
        if case .codeBlock(let language, let code) = blocks[4] {
            #expect(language == "swift")
            #expect(code.contains("let x = 1"))
        } else {
            Issue.record("缺少代码块")
        }
        #expect(blocks[5] == .thematicBreak)
    }

    @Test("表格解析为表头与数据行")
    func tables() {
        let source = """
        | 指标 | 值 |
        | --- | --- |
        | HR | 0.8 |
        | CI | 0.6–0.9 |
        """
        let blocks = MarkdownDocument.parse(source, citationLimit: nil)
        guard case .table(let header, let rows) = blocks.first else {
            Issue.record("首块不是表格：\(String(describing: blocks.first))")
            return
        }
        #expect(header.map { MarkdownDocument.plainText(of: $0) } == ["指标", "值"])
        #expect(rows.count == 2)
        #expect(rows[1].map { MarkdownDocument.plainText(of: $0) } == ["CI", "0.6–0.9"])
    }

    @Test("中文段落里的引用位置正确切分")
    func chineseSegmentation() {
        let blocks = MarkdownDocument.parse("恩格列净降低住院风险[1¶45]，且耐受良好[2¶7]。", citationLimit: 2)
        let paragraph = runs(of: blocks.first)
        #expect(paragraph.map(\.text) == ["恩格列净降低住院风险", "[1¶45]", "，且耐受良好", "[2¶7]", "。"])
        #expect(paragraph.compactMap(\.citation) == [CitationRef(n: 1, pid: 45), CitationRef(n: 2, pid: 7)])
    }
}
