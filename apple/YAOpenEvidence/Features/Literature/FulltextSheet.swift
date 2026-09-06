import SwiftUI
import YAOEKit

/// 上游全文面板：先取目录与摘要，再按章节读正文。
struct FulltextSheet: View {
    let record: LiteratureRecord

    @Environment(SessionStore.self) private var session
    @Environment(\.dismiss) private var dismiss

    @State private var state: Loadable<FulltextResult> = .idle
    @State private var section: String = ""
    @State private var loadingSection = false

    private static let maxChars = 20000

    var body: some View {
        LoadableView(state: state, retry: { Task { await load(section: "") } }) { result in
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text(result.citation)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)

                    if !result.sections.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("章节").font(.headline)
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 8)], spacing: 8) {
                                ForEach(result.sections) { item in
                                    Button {
                                        Task { await load(section: item.title) }
                                    } label: {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(item.title).font(.caption).lineLimit(2)
                                            Text("\(item.chars) 字").font(.caption2).foregroundStyle(.secondary)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(section == item.title ? .accentColor : .secondary)
                                }
                            }
                        }
                    }

                    if loadingSection {
                        ProgressView().frame(maxWidth: .infinity)
                    }

                    if let text = result.text, !text.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(result.section ?? "正文").font(.headline)
                            MarkdownDocumentView(blocks: MarkdownDocument.parse(text, citationLimit: nil))
                        }
                    } else if !result.abstract.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("摘要").font(.headline)
                            Text(result.abstract)
                                .font(.callout)
                                .textSelection(.enabled)
                        }
                    }

                    if result.truncated {
                        Text("已按 \(Self.maxChars) 字符截断")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle(record.title.isEmpty ? "全文" : record.title)
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        #endif
            .task { await load(section: "") }
    }

    private func load(section target: String) async {
        guard let client = session.client, let ident = record.fulltextIdent else {
            state = .failed("无可用全文")
            return
        }
        if state.value == nil { state = .loading } else { loadingSection = true }
        defer { loadingSection = false }
        do {
            let result = try await client.literatureFulltext(ident: ident, section: target, maxChars: Self.maxChars)
            section = target
            state = .loaded(result)
        } catch {
            if error.code == "fulltext_unavailable" || error.status == 404 {
                state = .failed("无可用全文")
            } else if state.value == nil {
                state = .failed(error.userMessage)
            }
        }
    }
}
