import SwiftUI
import YAOEKit

/// 文献详情：全文（带段落锚点）与抽取出的事实。
struct PaperDetailView: View {
    let route: PaperRoute

    @Environment(SessionStore.self) private var session

    private struct Material {
        var meta: PaperMeta
        var fulltext: String
        var facts: [Fact]
    }

    private enum Tab: String, CaseIterable, Identifiable {
        case fulltext
        case facts

        var id: String { rawValue }
        var label: String { self == .fulltext ? "全文" : "事实" }
    }

    @State private var state: Loadable<Material> = .idle
    @State private var tab: Tab = .fulltext
    @State private var focusPid: Int?

    var body: some View {
        LoadableView(state: state, retry: { Task { await load() } }) { material in
            VStack(alignment: .leading, spacing: 0) {
                header(material.meta)
                Picker("视图", selection: $tab) {
                    ForEach(Tab.allCases) { item in
                        Text(item.label).tag(item)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                Divider()

                switch tab {
                case .fulltext:
                    ParagraphMarkdownView(markdown: material.fulltext, focusPid: focusPid)
                case .facts:
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            if material.facts.isEmpty {
                                ContentUnavailableView("没有抽取到事实", systemImage: "list.bullet.rectangle")
                            }
                            ForEach(Array(material.facts.enumerated()), id: \.offset) { _, fact in
                                FactRow(fact: fact) { pid in
                                    tab = .fulltext
                                    focusPid = pid
                                }
                            }
                        }
                        .padding(16)
                    }
                }
            }
        }
        .navigationTitle("文献详情")
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
            .task(id: route) { await load() }
    }

    private func header(_ meta: PaperMeta) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(meta.title.isEmpty ? meta.key : meta.title)
                .font(.headline)
                .lineLimit(3)
            if !meta.authors.isEmpty {
                Text(meta.authors)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            HStack(spacing: 6) {
                if !meta.journal.isEmpty { Text(meta.journal).italic() }
                if !meta.year.isEmpty { Text(meta.year) }
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            ViewThatFits(in: .horizontal) {
                badges(meta)
                VStack(alignment: .leading, spacing: 6) { badges(meta) }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func badges(_ meta: PaperMeta) -> some View {
        HStack(spacing: 6) {
            RankBadge(quartile: meta.quartile)
            ForEach(meta.types.prefix(3), id: \.self) { type in
                Pill(text: type)
            }
            if !meta.pmid.isEmpty, let url = URL(string: "https://pubmed.ncbi.nlm.nih.gov/\(meta.pmid)/") {
                Link("PubMed", destination: url).font(.caption)
            }
            if !meta.doi.isEmpty, let url = URL(string: "https://doi.org/\(meta.doi)") {
                Link("DOI", destination: url).font(.caption)
            }
        }
    }

    private func load() async {
        guard let client = session.client else { return }
        if state.value == nil { state = .loading }
        focusPid = route.pid
        do {
            async let meta = client.paper(key: route.key)
            async let fulltext = client.paperFulltext(key: route.key)
            async let facts = client.paperFacts(key: route.key)
            state = .loaded(Material(
                meta: try await meta,
                fulltext: try await fulltext,
                facts: try await facts.items
            ))
        } catch {
            let apiError = error as? APIError
            state = .failed(apiError?.status == 404 ? "文献不存在" : (apiError?.userMessage ?? "网络连接失败，请稍后重试"))
        }
    }
}
