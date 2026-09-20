import SwiftUI
import PicoSeekKit

/// 行内 run → `AttributedString`。引用 run 用自定义 URL 承载点击目标。
enum InlineRenderer {
    static let citationScheme = "picoseek-cite"

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
                // 正文只显示文献编号：`¶12` 段落号是内部定位信息，点击后阅读器仍按 pid 跳转。
                piece = AttributedString("[\(citation.n)]")
                let color = CitationPalette.color(citation.n, colorScheme)
                piece.font = base.weight(.semibold).monospacedDigit()
                piece.foregroundColor = color
                piece.backgroundColor = color.opacity(0.12)
                piece.link = citationURL(citation)
            } else if let link = run.link {
                piece.link = link
                piece.foregroundColor = .accentColor
            }
            output.append(piece)
        }
        return output
    }

    /// VoiceOver 朗读文本：把 `[1¶45]` 这类标记换成可读的中文描述。
    static func spokenText(_ runs: [InlineRun]) -> String {
        runs.map { run in
            guard let citation = run.citation else { return run.text }
            return "，引用 第 \(citation.n) 篇" + (citation.pid.map { " 段落 \($0)" } ?? "") + "，"
        }.joined()
    }
}
