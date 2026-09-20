import SwiftUI
import PicoSeekKit

/// 一个已解析的模块：切分得到的类型 + 该节的块级结构。
struct RenderedSection: Hashable {
    let kind: AnswerSectionKind
    let blocks: [MarkdownBlock]
}

/// 答案正文的模块化渲染：结论卡 → 证据 → PICOS → 局限，顺序沿用文档顺序。
struct AnswerSectionsView: View {
    let sections: [RenderedSection]
    let onCite: (CitationRef) -> Void

    #if os(iOS)
        @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    private var isCompact: Bool {
        #if os(iOS)
            horizontalSizeClass == .compact
        #else
            false
        #endif
    }

    var body: some View {
        // MarkdownBlock.id == hashValue，同内容块会撞 id，只能用 offset。
        VStack(alignment: .leading, spacing: 28) {
            ForEach(Array(sections.enumerated()), id: \.offset) { _, section in
                view(for: section)
            }
        }
    }

    @ViewBuilder
    private func view(for section: RenderedSection) -> some View {
        switch section.kind {
        case .conclusion:
            VStack(alignment: .leading, spacing: 12) {
                SectionHeading(module: .conclusion, rule: false)
                MarkdownDocumentView(blocks: section.blocks, onCite: onCite)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.accentColor.opacity(0.08), in: .rect(cornerRadius: Metrics.cardRadius))
            .overlay(
                RoundedRectangle(cornerRadius: Metrics.cardRadius)
                    .strokeBorder(Color.accentColor.opacity(0.22))
            )

        case .evidence:
            plain(module: .evidence, blocks: section.blocks)

        case .caveats:
            plain(module: .caveats, blocks: section.blocks)

        case .picos:
            VStack(alignment: .leading, spacing: 16) {
                SectionHeading(module: .picos, count: picosCount(section.blocks))
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(section.blocks.enumerated()), id: \.offset) { _, block in
                        picosBlock(block)
                    }
                }
            }

        case .other:
            MarkdownDocumentView(blocks: section.blocks, onCite: onCite)
        }
    }

    private func plain(module: AnswerModule, blocks: [MarkdownBlock]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeading(module: module)
            MarkdownDocumentView(blocks: blocks, onCite: onCite)
        }
    }

    /// 窄屏把 PICOS 表拆成每篇一张卡；其余块照常渲染。
    @ViewBuilder
    private func picosBlock(_ block: MarkdownBlock) -> some View {
        if case .table(let header, let rows) = block, isCompact {
            PicosCardList(header: header, rows: rows, onCite: onCite)
        } else {
            MarkdownDocumentView(blocks: [block], onCite: onCite)
        }
    }

    /// 计数取第一个表格的表体行数；没有表格就不显示计数。
    private func picosCount(_ blocks: [MarkdownBlock]) -> String? {
        for block in blocks {
            if case .table(_, let rows) = block, !rows.isEmpty { return "\(rows.count) 篇" }
        }
        return nil
    }
}

/// PICOS 表的窄屏形态：每个表体行一张卡，首列在顶部，其余列按「表头标签 + 内容」逐行排。
struct PicosCardList: View {
    let header: [[InlineRun]]
    let rows: [[[InlineRun]]]
    let onCite: (CitationRef) -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 10) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                card(for: row)
            }
        }
        .handlesCitationLinks(onCite)
    }

    @ViewBuilder
    private func card(for row: [[InlineRun]]) -> some View {
        // 表头与行的列数不一致时以较少的一方为准，避免越界。
        let columns = min(header.count, row.count)
        VStack(alignment: .leading, spacing: 8) {
            if let first = row.first {
                Text(InlineRenderer.attributed(first, base: .subheadline.weight(.semibold), colorScheme: colorScheme))
            }
            if columns > 1 {
                Divider()
                ForEach(1 ..< columns, id: \.self) { index in
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Text(MarkdownDocument.plainText(of: header[index]))
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                            .frame(width: 84, alignment: .leading)
                        Text(InlineRenderer.attributed(row[index], base: .callout, colorScheme: colorScheme))
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .card()
    }
}
