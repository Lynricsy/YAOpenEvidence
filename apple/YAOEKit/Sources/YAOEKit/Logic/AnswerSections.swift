import Foundation

/// 答案正文的模块类型。`other` 表示前言或未识别标签之间的内容。
public enum AnswerSectionKind: String, Sendable, Hashable {
    case conclusion
    case evidence
    case picos
    case caveats
    case other
}

/// 一个模块：类型 + 该模块的 Markdown 正文（已去首尾空白）。
public struct AnswerSection: Hashable, Sendable {
    public var kind: AnswerSectionKind
    public var markdown: String

    public init(kind: AnswerSectionKind, markdown: String) {
        self.kind = kind
        self.markdown = markdown
    }
}

/// 把 `body_md` 按模型输出的标签切成模块。三端（Web / Apple / Flutter）逐字同源，
/// 改动前先同步另外两端的实现与测试向量。
public enum AnswerSections {
    /// 行内粗体标签：`**结论 / Bottom line** — 正文`，允许前置 `#` 与破折号/冒号分隔。
    private static let boldLabelPattern = #"^\s*(?:#{1,6}\s+)?\*\*([^*\n]+?)\*\*\s*(?:[—–\-:：]\s*)?(.*)$"#
    /// 纯标题标签：`## 结论`。
    private static let headingLabelPattern = #"^\s*#{1,6}\s+([^\n]+?)\s*$"#

    private static let boldLabelRegex = try! NSRegularExpression(pattern: boldLabelPattern)
    private static let headingLabelRegex = try! NSRegularExpression(pattern: headingLabelPattern)

    /// 标签文字 → 模块类型；不是已知模块返回 nil。
    /// 四类一律用「前缀」匹配：问题标题里出现「证据」这类字样很常见（`# Q: …的证据强度`），
    /// 包含匹配会把标题误判成分节头。`picos` 先于 `evidence` 判定，保持三端顺序一致。
    public static func kind(ofLabel label: String) -> AnswerSectionKind? {
        let trimmed = label.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = trimmed.lowercased()
        if trimmed.hasPrefix("结论") || lower.hasPrefix("bottom line") { return .conclusion }
        if lower.hasPrefix("picos") { return .picos }
        if trimmed.hasPrefix("证据") || lower.hasPrefix("evidence") { return .evidence }
        if trimmed.hasPrefix("局限") || lower.hasPrefix("caveat") || lower.hasPrefix("limitation") { return .caveats }
        return nil
    }

    /// 按行扫描切分：命中分节头就把缓冲 flush 成一节，同类模块重复出现时合并。
    public static func split(_ markdown: String) -> [AnswerSection] {
        let normalized = markdown.replacingOccurrences(of: "\r\n", with: "\n")
        guard !normalized.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return [] }

        var sections: [AnswerSection] = []
        var currentKind: AnswerSectionKind = .other
        var buffer: [String] = []

        func flush() {
            let content = buffer.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
            buffer.removeAll(keepingCapacity: true)
            guard !content.isEmpty else { return }
            // 同一模块被写了多次（模型有时分两段写证据）：追加到已有节，不新增节。
            if currentKind != .other, let index = sections.firstIndex(where: { $0.kind == currentKind }) {
                sections[index].markdown += "\n\n" + content
            } else {
                sections.append(AnswerSection(kind: currentKind, markdown: content))
            }
        }

        for line in normalized.split(separator: "\n", omittingEmptySubsequences: false) {
            let text = String(line)
            if let head = header(in: text) {
                flush()
                currentKind = head.kind
                if !head.rest.isEmpty { buffer.append(head.rest) }
            } else {
                buffer.append(text)
            }
        }
        flush()
        return sections
    }

    /// 是否识别出任何已知模块；否则整段按单块渲染。
    public static func hasKnownSections(_ sections: [AnswerSection]) -> Bool {
        sections.contains { $0.kind != .other }
    }

    /// 一行是不是分节头；是则返回模块类型与同行余文。
    private static func header(in line: String) -> (kind: AnswerSectionKind, rest: String)? {
        let range = NSRange(line.startIndex ..< line.endIndex, in: line)
        if let match = boldLabelRegex.firstMatch(in: line, range: range),
           let label = group(match, 1, in: line),
           let kind = kind(ofLabel: label) {
            return (kind, group(match, 2, in: line) ?? "")
        }
        if let match = headingLabelRegex.firstMatch(in: line, range: range),
           let label = group(match, 1, in: line),
           let kind = kind(ofLabel: label) {
            return (kind, "")
        }
        return nil
    }

    private static func group(_ match: NSTextCheckingResult, _ index: Int, in text: String) -> String? {
        guard index < match.numberOfRanges,
              let range = Range(match.range(at: index), in: text) else { return nil }
        return String(text[range])
    }
}
