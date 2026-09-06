import SwiftUI
import YAOEKit

/// 带段落锚点的原文视图：定位到 `focusPid`、闪烁提示，并给命中的引文片段加高亮。
struct ParagraphMarkdownView: View {
    let markdown: String
    var focusPid: Int?
    var quotes: [String] = []

    @State private var flashPid: Int?

    private var blocks: [MarkdownBlock] {
        let parsed = MarkdownDocument.parse(markdown, citationLimit: nil)
        guard let focusPid, !quotes.isEmpty else { return parsed }
        return parsed.map { block in
            guard case .paragraph(let runs, let anchor) = block, anchor == focusPid else { return block }
            return .paragraph(runs: InlineRenderer.highlighting(runs, quotes: quotes), anchor: anchor)
        }
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                MarkdownDocumentView(blocks: blocks, flashAnchor: flashPid)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
            .task(id: focusPid) {
                guard let focusPid else { return }
                try? await Task.sleep(for: .milliseconds(80))
                withAnimation(.easeInOut(duration: 0.25)) {
                    proxy.scrollTo("p\(focusPid)", anchor: .center)
                }
                flashPid = focusPid
                try? await Task.sleep(for: .seconds(2))
                flashPid = nil
            }
        }
    }
}
