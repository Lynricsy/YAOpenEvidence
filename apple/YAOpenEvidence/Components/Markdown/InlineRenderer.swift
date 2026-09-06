import SwiftUI
import YAOEKit

/// 行内 run → `AttributedString`。引用 run 用自定义 URL 承载点击目标。
enum InlineRenderer {
    static let citationScheme = "yaoe-cite"

    static func citationURL(_ ref: CitationRef) -> URL? {
        URL(string: "\(citationScheme)://\(ref.n)/\(ref.pid.map(String.init) ?? "")")
    }

    static func citationRef(from url: URL) -> CitationRef? {
        guard url.scheme == citationScheme, let n = Int(url.host() ?? "") else { return nil }
        let pid = Int(url.lastPathComponent)
        return CitationRef(n: n, pid: pid)
    }

    static func attributed(_ runs: [InlineRun], base: Font, colorScheme: ColorScheme) -> AttributedString {
        var output = AttributedString()
        for run in runs {
            var piece = AttributedString(run.text)
            var font = base
            if run.style.contains(.bold) { font = font.bold() }
            if run.style.contains(.italic) { font = font.italic() }
            if run.style.contains(.code) { font = font.monospaced() }
            piece.font = font
            if run.style.contains(.strikethrough) { piece.strikethroughStyle = .single }
            if run.style.contains(.highlight) { piece.backgroundColor = .yellow.opacity(0.35) }

            if let citation = run.citation {
                piece.font = base.monospaced()
                piece.foregroundColor = CitationPalette.color(citation.n, colorScheme)
                piece.link = citationURL(citation)
            } else if let link = run.link {
                piece.link = link
                piece.foregroundColor = .accentColor
            }
            output.append(piece)
        }
        return output
    }

    /// 在 run 序列里给命中的引文片段打高亮（每条 quote 只标注首次出现）。
    static func highlighting(_ runs: [InlineRun], quotes: [String]) -> [InlineRun] {
        let plain = MarkdownDocument.plainText(of: runs)
        guard !plain.isEmpty else { return runs }
        let characters = Array(plain)

        var ranges: [Range<Int>] = []
        for quote in quotes {
            let needle = quote.trimmingCharacters(in: .whitespacesAndNewlines)
            guard needle.count >= 4, let found = plain.range(of: needle) else { continue }
            let start = plain.distance(from: plain.startIndex, to: found.lowerBound)
            let end = plain.distance(from: plain.startIndex, to: found.upperBound)
            ranges.append(start ..< end)
        }
        guard !ranges.isEmpty else { return runs }

        var marked = [Bool](repeating: false, count: characters.count)
        for range in ranges {
            for index in range where index < marked.count { marked[index] = true }
        }

        var output: [InlineRun] = []
        var cursor = 0
        for run in runs {
            let length = run.text.count
            guard length > 0 else { continue }
            var segmentStart = 0
            var index = 1
            while index <= length {
                let boundary = index == length || marked[cursor + index] != marked[cursor + segmentStart]
                if boundary {
                    let slice = String(characters[(cursor + segmentStart) ..< (cursor + index)])
                    var piece = run
                    piece.text = slice
                    if marked[cursor + segmentStart] { piece.style.insert(.highlight) }
                    output.append(piece)
                    segmentStart = index
                }
                index += 1
            }
            cursor += length
        }
        return output
    }
}
