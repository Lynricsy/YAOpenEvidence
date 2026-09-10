import SwiftUI
import YAOEKit

/// 文献详情：全文（带段落锚点）与抽取出的事实。
struct PaperDetailView: View {
    let route: PaperRoute

    @Environment(SessionStore.self) private var session

    private enum Tab: String, CaseIterable, Identifiable {
        case fulltext
        case facts

        var id: String { rawValue }
        var label: String { self == .fulltext ? "全文" : "事实" }
    }

    @State private var meta: Loadable<PaperMeta> = .idle
    @State private var fulltext: Loadable<String> = .idle
    @State private var facts: Loadable<[Fact]> = .idle
    @State private var metaNotFound = false
    @State private var tab: Tab = .fulltext
    @State private var focusPid: Int?

    var body: some View {
        Group {
            if metaNotFound {
                ContentUnavailableView("文献不存在", systemImage: "doc.questionmark")
            } else {
                LoadableView(state: meta, retry: { Task { await loadMeta() } }) { meta in
                    material(meta)
                }
            }
        }
        .navigationTitle("文献详情")
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
            .task(id: route) { await load() }
    }

    private func material(_ meta: PaperMeta) -> some View {
        VStack(alignment: .leading, spacing: 0) {
                header(meta)
                Picker("视图", selection: $tab) {
                    ForEach(Tab.allCases) { item in
                        Text(item.label).tag(item)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)

                switch tab {
                case .fulltext:
                    LoadableView(state: fulltext, retry: { Task { await loadFulltext() } }) { text in
                        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            ContentUnavailableView("暂无全文", systemImage: "doc.plaintext")
                        } else {
                            ParagraphMarkdownView(markdown: text, focusPid: focusPid)
                        }
                    }
                case .facts:
                    LoadableView(state: facts, retry: { Task { await loadFacts() } }) { facts in
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 12) {
                                if facts.isEmpty {
                                    ContentUnavailableView("没有抽取到事实", systemImage: "list.bullet.rectangle")
                                }
                                ForEach(Array(facts.enumerated()), id: \.offset) { _, fact in
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
    }

    private func header(_ meta: PaperMeta) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(meta.title.isEmpty ? "（无标题）" : meta.title)
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

            badges(meta)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func badges(_ meta: PaperMeta) -> some View {
        FlowLayout {
            RankBadge(quartile: meta.quartile)
            SourceBadge(source: meta.source)
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
        meta = .loading
        metaNotFound = false
        fulltext = .loading
        facts = .loading
        focusPid = route.pid
        async let metaRequest: Void = loadMeta()
        async let fulltextRequest: Void = loadFulltext()
        async let factsRequest: Void = loadFacts()
        _ = await (metaRequest, fulltextRequest, factsRequest)
    }

    private func loadMeta() async {
        guard let client = session.client else { return }
        metaNotFound = false
        meta = .loading
        do {
            let result = try await client.paper(key: route.key)
            guard !Task.isCancelled else { return }
            meta = .loaded(result)
        } catch {
            guard !Task.isCancelled else { return }
            metaNotFound = error.status == 404
            meta = .failed(error.userMessage)
        }
    }

    private func loadFulltext() async {
        guard let client = session.client else { return }
        fulltext = .loading
        do {
            let result = try await client.paperFulltext(key: route.key)
            guard !Task.isCancelled else { return }
            fulltext = .loaded(result)
        } catch {
            guard !Task.isCancelled else { return }
            fulltext = .failed(error.userMessage)
        }
    }

    private func loadFacts() async {
        guard let client = session.client else { return }
        facts = .loading
        do {
            let result = try await client.paperFacts(key: route.key)
            guard !Task.isCancelled else { return }
            facts = .loaded(result.items)
        } catch {
            guard !Task.isCancelled else { return }
            facts = .failed(error.userMessage)
        }
    }
}
