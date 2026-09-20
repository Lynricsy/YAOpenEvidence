import Foundation

public extension MarkdownDocument {
    /// 给命中引文的片段打上 `highlight`（每条 quote 只标注首次出现）。
    ///
    /// 坐标一律用 Unicode 标量：字素簇会跨 run 合并（例如 `**abcd**&#x301;` 解析出
    /// `["abcd", "\u{301}"]`，拼接后只有 4 个 Character 却有 5 个标量），
    /// 若按 Character 计数逐 run 累加下标就会错位甚至越界。
    static func highlighting(_ runs: [InlineRun], quotes: [String]) -> [InlineRun] {
        let scalarRuns = runs.map { Array($0.text.unicodeScalars) }
        let total = scalarRuns.reduce(0) { $0 + $1.count }
        guard total > 0, !quotes.isEmpty else { return runs }

        let plain = plainText(of: runs)
        var marked = [Bool](repeating: false, count: total)
        var hit = false
        for quote in quotes {
            let needle = quote.trimmingCharacters(in: .whitespacesAndNewlines)
            // 过短的片段容易在正文里误命中，与 Web 端一致地跳过。
            guard needle.count >= 4, let found = plain.range(of: needle) else { continue }
            let start = plain.unicodeScalars.distance(from: plain.unicodeScalars.startIndex, to: found.lowerBound)
            let end = plain.unicodeScalars.distance(from: plain.unicodeScalars.startIndex, to: found.upperBound)
            guard start >= 0, end <= total, start < end else { continue }
            for index in start ..< end { marked[index] = true }
            hit = true
        }
        guard hit else { return runs }

        var output: [InlineRun] = []
        var cursor = 0
        for (index, scalars) in scalarRuns.enumerated() {
            guard !scalars.isEmpty else { continue }
            var segmentStart = 0
            var offset = 1
            while offset <= scalars.count {
                let isBoundary = offset == scalars.count
                    || marked[cursor + offset] != marked[cursor + segmentStart]
                if isBoundary {
                    var piece = runs[index]
                    piece.text = String(String.UnicodeScalarView(scalars[segmentStart ..< offset]))
                    if marked[cursor + segmentStart] { piece.style.insert(.highlight) }
                    output.append(piece)
                    segmentStart = offset
                }
                offset += 1
            }
            cursor += scalars.count
        }
        return output
    }
}
