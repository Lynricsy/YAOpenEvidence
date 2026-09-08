import SwiftUI
import YAOEKit

/// 块级 Markdown 渲染。引用芯片点击回调给上层打开阅读器。
struct MarkdownDocumentView: View {
    let blocks: [MarkdownBlock]
    var onCite: ((CitationRef) -> Void)?
    /// 需要闪烁提示的段落锚点（点击引用后短暂高亮）。
    var flashAnchor: Int?

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 12) {
            ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                view(for: block)
            }
        }
        .handlesCitationLinks(onCite)
    }

    @ViewBuilder
    private func view(for block: MarkdownBlock) -> some View {
        switch block {
        case .heading(let level, let runs):
            let font: Font = switch level {
            case 1: .system(.title, design: .serif, weight: .semibold)
            case 2: .system(.title2, design: .serif, weight: .semibold)
            default: .system(.title3, design: .serif, weight: .semibold)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(InlineRenderer.attributed(runs, base: font, colorScheme: colorScheme))
                    .textSelection(.enabled)
                if level == 2 { Divider() }
            }
            .padding(.top, 4)

        case .paragraph(let runs, let anchor):
            Text(InlineRenderer.attributed(runs, base: .body, colorScheme: colorScheme))
                .textSelection(.enabled)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(6)
                .background(
                    Color.accentColor.opacity(anchor != nil && anchor == flashAnchor ? 0.14 : 0),
                    in: .rect(cornerRadius: 8)
                )
                .animation(.easeOut(duration: 0.6), value: flashAnchor)
                .accessibilityLabel(InlineRenderer.spokenText(runs))
                .modifier(AnchorID(anchor: anchor))

        case .blockQuote(let inner):
            HStack(alignment: .top, spacing: 10) {
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(Color.accentColor)
                    .frame(width: 3)
                MarkdownDocumentView(blocks: inner, onCite: onCite)
            }

        case .list(let ordered, let start, let items):
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    HStack(alignment: .top, spacing: 8) {
                        Text(ordered ? "\(start + index)." : "•")
                            .font(.body.monospacedDigit())
                            .foregroundStyle(.secondary)
                        MarkdownDocumentView(blocks: item, onCite: onCite)
                    }
                }
            }

        case .codeBlock(_, let code):
            ScrollView(.horizontal, showsIndicators: false) {
                Text(code)
                    .font(.system(.callout, design: .monospaced))
                    .textSelection(.enabled)
                    .padding(10)
            }
            .background(.quaternary.opacity(0.4), in: .rect(cornerRadius: 8))

        case .table(let header, let rows):
            // 列宽必须写死：横向 ScrollView 用「未指定宽度」向内容问理想高度，
            // 若靠 `maxWidth` 夹紧再换行，行高会按单行算出来，换行后的第二行被容器裁掉。
            // 首列是 `[n]` 引用编号，给窄列宽即可。
            let width = { (index: Int) in index == 0 ? 56.0 : 200.0 }
            ScrollView(.horizontal) {
                Grid(alignment: .topLeading, horizontalSpacing: 0, verticalSpacing: 0) {
                    GridRow {
                        ForEach(Array(header.enumerated()), id: \.offset) { index, cell in
                            Text(InlineRenderer.attributed(cell, base: .caption.weight(.semibold), colorScheme: colorScheme))
                                .foregroundStyle(.secondary)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 10)
                                .frame(width: width(index), alignment: .topLeading)
                                .background(Color.cardFill)
                        }
                    }
                    ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                        Divider()
                        GridRow {
                            ForEach(Array(row.enumerated()), id: \.offset) { index, cell in
                                Text(InlineRenderer.attributed(cell, base: .callout, colorScheme: colorScheme))
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 10)
                                    .frame(width: width(index), alignment: .topLeading)
                            }
                        }
                    }
                }
            }
            .clipShape(.rect(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(.quaternary))

        case .thematicBreak:
            Divider()

        case .html(let raw):
            Text(raw)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
        }
    }
}

extension View {
    /// 拦截引用链接（`InlineRenderer` 生成的自定义 scheme），交给上层打开阅读器；
    /// 其余链接照系统行为处理。PICOS 卡片等复用行内渲染的视图也需要挂上它。
    func handlesCitationLinks(_ onCite: ((CitationRef) -> Void)?) -> some View {
        environment(\.openURL, OpenURLAction { url in
            if let ref = InlineRenderer.citationRef(from: url) {
                onCite?(ref)
                return .handled
            }
            return .systemAction
        })
    }
}

/// 给带锚点的段落挂上滚动定位 id。
private struct AnchorID: ViewModifier {
    let anchor: Int?

    func body(content: Content) -> some View {
        if let anchor {
            content.id("p\(anchor)")
        } else {
            content
        }
    }
}
