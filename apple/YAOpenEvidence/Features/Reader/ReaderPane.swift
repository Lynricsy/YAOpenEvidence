import SwiftUI
import YAOEKit

/// 逐篇阅读材料：原文 / 阅读笔记 / 核实引文 / 事实。旧版导入答案只有原文。
struct ReaderPane: View {
    let answerID: String
    let target: ReaderTarget
    let answerActive: Bool
    var quotes: [String] = []

    @Environment(SessionStore.self) private var session
    @Environment(\.dismiss) private var dismiss

    enum Tab: String, CaseIterable, Identifiable {
        case fulltext
        case notes
        case citations
        case facts

        var id: String { rawValue }

        var label: String {
            switch self {
            case .fulltext: "原文"
            case .notes: "阅读笔记"
            case .citations: "核实引文"
            case .facts: "事实"
            }
        }
    }

    private struct Material {
        var detail: AnswerPaperDetail?
        var legacyMarkdown: String?
    }

    @State private var state: Loadable<Material> = .idle
    @State private var tab: Tab = .fulltext
    @State private var focusPid: Int?

    var body: some View {
        LoadableView(state: state, retry: { Task { await load() } }) { material in
            VStack(alignment: .leading, spacing: 0) {
                header(material)
                if material.detail != nil {
                    Picker("视图", selection: $tab) {
                        ForEach(Tab.allCases) { item in
                            Text(item.label).tag(item)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
                Divider()
                pane(material)
            }
        }
        .navigationTitle("第 \(target.n) 篇")
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        #endif
            .task(id: target.n) { await load() }
            .task(id: target.pid) { focusPid = target.pid }
    }

    // MARK: - 加载

    private func load() async {
        guard let client = session.client else { return }
        if state.value == nil { state = .loading }
        focusPid = target.pid
        do {
            let detail = try await client.answerPaper(id: answerID, n: target.n)
            state = .loaded(Material(detail: detail))
        } catch {
            guard error.status == 404 else {
                state = .failed(error.userMessage)
                return
            }
            if answerActive {
                state = .failed("该文献尚未阅读完成")
                return
            }
            // 旧版导入的答案没有逐篇材料，回落到原文快照。
            do {
                let markdown = try await client.answerPaperMarkdown(id: answerID, n: target.n)
                state = .loaded(Material(legacyMarkdown: markdown))
                tab = .fulltext
            } catch {
                state = .failed("此答案没有逐篇材料（旧版导入）")
            }
        }
    }

    // MARK: - 视图

    @ViewBuilder
    private func header(_ material: Material) -> some View {
        let detail = material.detail
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 10) {
                CitationSquare(n: target.n, size: 26)
                VStack(alignment: .leading, spacing: 4) {
                    Text(detail?.title.isEmpty == false ? detail!.title : "第 \(target.n) 篇文献")
                        .font(.headline)
                        .lineLimit(3)
                    if let detail {
                        if !detail.authors.isEmpty {
                            Text(detail.authors)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                        HStack(spacing: 6) {
                            if !detail.journal.isEmpty { Text(detail.journal).italic() }
                            if !detail.year.isEmpty { Text(detail.year) }
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
            }

            if let detail {
                ViewThatFits(in: .horizontal) {
                    badges(detail)
                    VStack(alignment: .leading, spacing: 6) { badges(detail) }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private func badges(_ detail: AnswerPaperDetail) -> some View {
        HStack(spacing: 6) {
            RankBadge(quartile: detail.quartile, rankLabel: detail.rankLabel)
            SourceBadge(source: detail.source)
            if !detail.pmid.isEmpty, let url = URL(string: "https://pubmed.ncbi.nlm.nih.gov/\(detail.pmid)/") {
                Link("PubMed", destination: url).font(.caption)
            }
            if !detail.doi.isEmpty, let url = URL(string: "https://doi.org/\(detail.doi)") {
                Link("DOI", destination: url).font(.caption)
            }
        }
    }

    @ViewBuilder
    private func pane(_ material: Material) -> some View {
        if let detail = material.detail {
            switch tab {
            case .fulltext:
                ParagraphMarkdownView(
                    markdown: detail.fulltextMd,
                    focusPid: focusPid,
                    quotes: mergedQuotes(detail)
                )
            case .notes:
                ScrollView {
                    MarkdownDocumentView(blocks: MarkdownDocument.parse(detail.notesMd, citationLimit: nil))
                        .padding(16)
                }
            case .citations:
                citationList(detail)
            case .facts:
                factList(detail.facts)
            }
        } else if let markdown = material.legacyMarkdown {
            ParagraphMarkdownView(markdown: markdown, focusPid: focusPid, quotes: quotes)
        }
    }

    private func mergedQuotes(_ detail: AnswerPaperDetail) -> [String] {
        var seen = Set<String>()
        let fromDetail = detail.citations.filter { $0.pid == focusPid }.map(\.quote)
        return (fromDetail + quotes).filter { !$0.isEmpty && seen.insert($0).inserted }
    }

    private func citationList(_ detail: AnswerPaperDetail) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                if detail.citations.isEmpty {
                    ContentUnavailableView("没有核实引文", systemImage: "text.quote")
                }
                ForEach(Array(detail.citations.enumerated()), id: \.offset) { _, citation in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            VerifiedPill(verified: citation.verified)
                            if citation.keyFinding { Pill(text: "关键发现", tone: .accentColor) }
                            if let section = citation.noteSection, !section.isEmpty {
                                Pill(text: section)
                            }
                        }
                        Text(citation.quote)
                            .font(.callout)
                            .padding(.leading, 10)
                            .overlay(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 1.5)
                                    .fill(.tertiary)
                                    .frame(width: 3)
                            }
                            .textSelection(.enabled)
                        HStack(spacing: 8) {
                            if let sec = citation.sec, !sec.isEmpty {
                                Text(sec).font(.caption).foregroundStyle(.secondary)
                            }
                            if let page = citation.page {
                                Text("第 \(page) 页").font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            if let pid = citation.pid {
                                Button("¶\(pid)") { focus(pid) }
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)
                            }
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.quaternary.opacity(0.2), in: .rect(cornerRadius: 10))
                }
            }
            .padding(16)
        }
    }

    private func factList(_ facts: [Fact]) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                if facts.isEmpty {
                    ContentUnavailableView("没有抽取到事实", systemImage: "list.bullet.rectangle")
                }
                ForEach(Array(facts.enumerated()), id: \.offset) { _, fact in
                    FactRow(fact: fact) { pid in focus(pid) }
                }
            }
            .padding(16)
        }
    }

    private func focus(_ pid: Int) {
        tab = .fulltext
        focusPid = pid
    }
}

/// 事实条目（阅读器与文献详情共用）。
struct FactRow: View {
    let fact: Fact
    var onFocus: ((Int) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Pill(text: fact.kindLabel, tone: .accentColor)
                VerifiedPill(verified: fact.verified)
                if let sec = fact.sec, !sec.isEmpty {
                    Text(sec).font(.caption).foregroundStyle(.secondary)
                }
                if let page = fact.page {
                    Text("第 \(page) 页").font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                if let pid = fact.pid, let onFocus {
                    Button("¶\(pid)") { onFocus(pid) }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                }
            }
            Text(fact.fact)
                .font(.callout)
                .textSelection(.enabled)
            if !fact.factZh.isEmpty {
                Text(fact.factZh)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
            }
            if !fact.quote.isEmpty {
                Text(fact.quote)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 10)
                    .overlay(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 1.5).fill(.tertiary).frame(width: 3)
                    }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary.opacity(0.2), in: .rect(cornerRadius: 10))
    }
}
