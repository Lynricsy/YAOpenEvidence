import Foundation
import Markdown

/// 行内样式（可叠加）。
public struct InlineStyle: OptionSet, Sendable, Hashable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let bold = InlineStyle(rawValue: 1 << 0)
    public static let italic = InlineStyle(rawValue: 1 << 1)
    public static let code = InlineStyle(rawValue: 1 << 2)
    public static let strikethrough = InlineStyle(rawValue: 1 << 3)
    public static let highlight = InlineStyle(rawValue: 1 << 4)
}

/// 一段行内文本及其样式；`citation` 非空表示这是一处引用芯片。
public struct InlineRun: Hashable, Sendable {
    public var text: String
    public var style: InlineStyle
    public var link: URL?
    public var citation: CitationRef?

    public init(text: String, style: InlineStyle = [], link: URL? = nil, citation: CitationRef? = nil) {
        self.text = text
        self.style = style
        self.link = link
        self.citation = citation
    }
}

/// 块级结构。渲染层按此逐块画 SwiftUI 视图。
public indirect enum MarkdownBlock: Hashable, Sendable, Identifiable {
    case heading(level: Int, runs: [InlineRun])
    /// `anchor` 来自段首的 `<a id="pN"></a>`，供滚动定位。
    case paragraph(runs: [InlineRun], anchor: Int?)
    case blockQuote([MarkdownBlock])
    case list(ordered: Bool, start: Int, items: [[MarkdownBlock]])
    case codeBlock(language: String?, code: String)
    case table(header: [[InlineRun]], rows: [[[InlineRun]]])
    case thematicBreak
    /// 无法识别的 HTML 块，按等宽纯文本显示。
    case html(String)

    public var id: Int { hashValue }
}

public enum MarkdownDocument {
    /// 解析 Markdown。`citationLimit` 非空时把 `[n]` / `[n¶pid]` 裸标记识别为引用（1...limit 之外不识别）。
    public static func parse(_ markdown: String, citationLimit: Int?) -> [MarkdownBlock] {
        let context = Context(source: markdown, citationLimit: citationLimit)
        return blocks(from: Document(parsing: markdown).children, context)
    }

    /// 取一组 run 的纯文本（用于引文高亮定位、无障碍标签）。
    public static func plainText(of runs: [InlineRun]) -> String {
        runs.map(\.text).joined()
    }

    // MARK: - 解析上下文

    /// 缓存源码字节与行首偏移：cmark 的列号是 1-based 的 UTF-8 字节偏移。
    private struct Context {
        let bytes: [UInt8]
        let lineStarts: [Int]
        let citationLimit: Int?

        init(source: String, citationLimit: Int?) {
            let bytes = Array(source.utf8)
            var starts = [0]
            for (offset, byte) in bytes.enumerated() where byte == UInt8(ascii: "\n") {
                starts.append(offset + 1)
            }
            self.bytes = bytes
            lineStarts = starts
            self.citationLimit = citationLimit
        }

        /// 节点对应的原始源码片段（保留转义反斜杠）。
        func rawText(_ range: SourceRange?) -> String? {
            guard let range,
                  range.lowerBound.line >= 1, range.lowerBound.line <= lineStarts.count,
                  range.upperBound.line >= 1, range.upperBound.line <= lineStarts.count
            else { return nil }
            let start = lineStarts[range.lowerBound.line - 1] + range.lowerBound.column - 1
            let end = lineStarts[range.upperBound.line - 1] + range.upperBound.column - 1
            guard start >= 0, end <= bytes.count, start <= end else { return nil }
            return String(decoding: bytes[start ..< end], as: UTF8.self)
        }
    }

    // MARK: - 块级

    private static func blocks(from children: some Sequence<any Markup>, _ context: Context) -> [MarkdownBlock] {
        children.compactMap { block(from: $0, context) }
    }

    private static func block(from markup: any Markup, _ context: Context) -> MarkdownBlock? {
        switch markup {
        case let heading as Heading:
            return .heading(level: heading.level, runs: inlineRuns(heading.children, context).runs)
        case let paragraph as Markdown.Paragraph:
            let built = inlineRuns(paragraph.children, context)
            return .paragraph(runs: built.runs, anchor: built.anchor)
        case let quote as BlockQuote:
            return .blockQuote(blocks(from: quote.children, context))
        case let list as UnorderedList:
            return .list(ordered: false, start: 1, items: list.listItems.map { blocks(from: $0.children, context) })
        case let list as OrderedList:
            return .list(ordered: true, start: Int(list.startIndex), items: list.listItems.map { blocks(from: $0.children, context) })
        case let code as CodeBlock:
            return .codeBlock(language: code.language, code: code.code)
        case let table as Markdown.Table:
            let header = Array(table.head.cells.map { inlineRuns($0.children, context).runs })
            let rows = Array(table.body.rows.map { row in Array(row.cells.map { inlineRuns($0.children, context).runs }) })
            return .table(header: header, rows: rows)
        case is ThematicBreak:
            return .thematicBreak
        case let html as HTMLBlock:
            let text = html.rawHTML.trimmingCharacters(in: .whitespacesAndNewlines)
            return text.isEmpty ? nil : .html(text)
        case let container as any BlockContainer:
            let inner = blocks(from: container.children, context)
            return inner.isEmpty ? nil : .blockQuote(inner)
        default:
            return nil
        }
    }

    // MARK: - 行内

    private struct InlineBuilder {
        var runs: [InlineRun] = []
        var anchor: Int?
        var highlight = false
        /// 段首之前是否已经出现过可见文本（决定 `<a id="pN">` 是否算段落锚点）。
        var sawText = false

        mutating func append(_ text: String, style: InlineStyle, link: URL?, citation: CitationRef?) {
            guard !text.isEmpty else { return }
            var style = style
            if highlight { style.insert(.highlight) }
            runs.append(InlineRun(text: text, style: style, link: link, citation: citation))
            sawText = true
        }
    }

    private static func inlineRuns(_ children: some Sequence<any Markup>, _ context: Context) -> InlineBuilder {
        var builder = InlineBuilder()
        for child in children {
            appendInline(child, style: [], link: nil, into: &builder, context)
        }
        return builder
    }

    private static func appendInline(
        _ markup: any Markup,
        style: InlineStyle,
        link: URL?,
        allowMarkers: Bool = true,
        into builder: inout InlineBuilder,
        _ context: Context
    ) {
        switch markup {
        case let text as Markdown.Text:
            appendText(text, style: style, link: link, allowMarkers: allowMarkers, into: &builder, context)

        case let emphasis as Emphasis:
            for child in emphasis.children {
                appendInline(child, style: style.union(.italic), link: link, allowMarkers: allowMarkers, into: &builder, context)
            }

        case let strong as Strong:
            for child in strong.children {
                appendInline(child, style: style.union(.bold), link: link, allowMarkers: allowMarkers, into: &builder, context)
            }

        case let struck as Strikethrough:
            for child in struck.children {
                appendInline(child, style: style.union(.strikethrough), link: link, allowMarkers: allowMarkers, into: &builder, context)
            }

        case let code as InlineCode:
            // 代码里的方括号不是引用标记。
            builder.append(code.code, style: style.union(.code), link: link, citation: nil)

        case let inlineLink as Markdown.Link:
            let destination = inlineLink.destination ?? ""
            let text = inlineLink.plainText
            if let ref = Citations.parseAnswerLink(destination) {
                builder.append(text, style: style, link: nil, citation: ref)
            } else {
                // 普通链接的标签不再识别裸标记：`[[1]](https://example.com)` 必须留在原链接上，
                // 否则点击会跳到第 1 篇文献（与 Web 端跳过整个 link 子树一致）。
                let url = URL(string: destination)
                for child in inlineLink.children {
                    appendInline(child, style: style, link: url ?? link, allowMarkers: false, into: &builder, context)
                }
            }

        case let image as Markdown.Image:
            let alt = image.plainText.isEmpty ? (image.title ?? "") : image.plainText
            builder.append(alt, style: style, link: link, citation: nil)

        case is SoftBreak:
            builder.append(" ", style: style, link: link, citation: nil)

        case is LineBreak:
            builder.append("\n", style: style, link: link, citation: nil)

        case let html as InlineHTML:
            appendInlineHTML(html.rawHTML, into: &builder)

        case let container as any InlineContainer:
            for child in container.children {
                appendInline(child, style: style, link: link, allowMarkers: allowMarkers, into: &builder, context)
            }

        default:
            break
        }
    }

    /// 段落锚点 `<a id="pN">`、`</a>`、`<mark>` 开关；其余行内 HTML 丢弃。
    private static func appendInlineHTML(_ rawHTML: String, into builder: inout InlineBuilder) {
        let html = rawHTML.trimmingCharacters(in: .whitespaces)
        if !builder.sawText, let anchor = anchorID(in: html) {
            builder.anchor = anchor
            return
        }
        switch html.lowercased() {
        case "<mark>": builder.highlight = true
        case "</mark>": builder.highlight = false
        default: break
        }
    }

    private static let anchorRegex = try! NSRegularExpression(pattern: #"^<a\s+id="p(\d+)"\s*>$"#, options: [.caseInsensitive])

    private static func anchorID(in html: String) -> Int? {
        let range = NSRange(html.startIndex ..< html.endIndex, in: html)
        guard let match = anchorRegex.firstMatch(in: html, range: range),
              let group = Range(match.range(at: 1), in: html) else { return nil }
        return Int(html[group])
    }

    /// 文本节点：按需要切出引用标记。
    private static func appendText(
        _ node: Markdown.Text,
        style: InlineStyle,
        link: URL?,
        allowMarkers: Bool,
        into builder: inout InlineBuilder,
        _ context: Context
    ) {
        guard allowMarkers, let limit = context.citationLimit, limit >= 1 else {
            builder.append(node.string, style: style, link: link, citation: nil)
            return
        }

        // cmark 的行内节点在缩进段落、续行等情形下列号会偏移，实体引用也会让源码与解析结果不等长。
        // 因此只有「反转义后与解析结果完全一致」的源码片段才可信；否则退回解析后的文本，
        // 宁可把 `&#91;1]` 这种实体拼出来的方括号当成引用，也绝不拿错位切片重建正文（会丢字）。
        let raw = context.rawText(node.range)
        let trustedRaw = raw.flatMap { unescape($0) == node.string ? $0 : nil }
        let text = trustedRaw ?? node.string

        var cursor = text.startIndex
        for marker in Citations.markers(in: text) {
            guard marker.ref.n >= 1, marker.ref.n <= limit else { continue }
            // 只有可信源码才能判断转义：`\[1]` 不是引用。
            if trustedRaw != nil, marker.range.lowerBound > text.startIndex,
               text[text.index(before: marker.range.lowerBound)] == "\\" { continue }
            if cursor < marker.range.lowerBound {
                let segment = String(text[cursor ..< marker.range.lowerBound])
                builder.append(trustedRaw == nil ? segment : unescape(segment), style: style, link: link, citation: nil)
            }
            builder.append(String(text[marker.range]), style: style, link: link, citation: marker.ref)
            cursor = marker.range.upperBound
        }
        if cursor < text.endIndex {
            let segment = String(text[cursor...])
            builder.append(trustedRaw == nil ? segment : unescape(segment), style: style, link: link, citation: nil)
        }
    }

    /// 还原 CommonMark 的反斜杠转义（仅 ASCII 标点可被转义）。
    private static func unescape(_ text: String) -> String {
        var out = ""
        out.reserveCapacity(text.count)
        var escaping = false
        for character in text {
            if escaping {
                if !character.isASCII || !character.isPunctuation && !character.isSymbol { out.append("\\") }
                out.append(character)
                escaping = false
            } else if character == "\\" {
                escaping = true
            } else {
                out.append(character)
            }
        }
        if escaping { out.append("\\") }
        return out
    }
}
