import Foundation

/// 正文里的一处引用：第 `n` 篇文献的第 `pid` 段（`pid` 可缺省）。
public struct CitationRef: Hashable, Sendable {
    public var n: Int
    public var pid: Int?

    public init(n: Int, pid: Int?) {
        self.n = n
        self.pid = pid
    }
}

public enum Citations {
    /// 裸标记 `[n]` 或 `[n¶pid]`（¶ = U+00B6）。
    public static let markerPattern = #"\[(\d{1,2})(?:¶(\d{1,4}))?\]"#

    /// 渲染稿里的引用链接：`/v1/answers/{id}/papers/{n}/markdown#p{pid}`。
    public static let answerLinkPattern = #"^/v1/answers/[^/]+/papers/(\d+)/markdown(?:#p(\d+))?$"#

    private static let markerRegex = try! NSRegularExpression(pattern: markerPattern)
    private static let answerLinkRegex = try! NSRegularExpression(pattern: answerLinkPattern)

    /// 解析渲染稿的引用链接；不是引用链接则返回 nil。
    public static func parseAnswerLink(_ destination: String) -> CitationRef? {
        let range = NSRange(destination.startIndex ..< destination.endIndex, in: destination)
        guard let match = answerLinkRegex.firstMatch(in: destination, range: range) else { return nil }
        guard let n = intGroup(match, 1, in: destination) else { return nil }
        return CitationRef(n: n, pid: intGroup(match, 2, in: destination))
    }

    /// 在一段文本里查找所有裸标记，返回 (UTF-16 区间, 引用) 列表。
    public static func markers(in text: String) -> [(range: Range<String.Index>, ref: CitationRef)] {
        let full = NSRange(text.startIndex ..< text.endIndex, in: text)
        return markerRegex.matches(in: text, range: full).compactMap { match in
            guard let range = Range(match.range, in: text), let n = intGroup(match, 1, in: text) else { return nil }
            return (range, CitationRef(n: n, pid: intGroup(match, 2, in: text)))
        }
    }

    /// 统计正文里每篇文献被引用的次数（来源卡「正文引用 N 处」）。
    public static func countMarkers(in markdown: String) -> [Int: Int] {
        var counts: [Int: Int] = [:]
        for marker in markers(in: markdown) {
            counts[marker.ref.n, default: 0] += 1
        }
        return counts
    }

    /// 引用色板，与 Web 端一致。
    public static let palette = [
        "#087f96", "#956124", "#6366a0", "#297d54",
        "#b34f69", "#397bb5", "#89742c", "#7d5b9e",
    ]

    public static func colorHex(n: Int) -> String {
        guard n >= 1 else { return palette[0] }
        return palette[(n - 1) % palette.count]
    }

    private static func intGroup(_ match: NSTextCheckingResult, _ index: Int, in text: String) -> Int? {
        guard index < match.numberOfRanges,
              let range = Range(match.range(at: index), in: text) else { return nil }
        return Int(text[range])
    }
}
