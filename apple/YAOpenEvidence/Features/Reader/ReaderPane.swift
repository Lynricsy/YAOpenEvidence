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
    /// 当前 state 里装的是第几篇，用来在换文献时立刻丢弃旧材料。
    @State private var loadedN: Int?
    @State private var requestSeq = 0

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
                pane(material)
                    .animation(.default, value: tab)
            }
        }
        .navigationTitle("参考文献 \(target.n)")
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
            .sensoryFeedback(.impact(weight: .light), trigger: focusPid)
    }

    // MARK: - 加载

    private func load() async {
        guard let client = session.client else { return }
        // 换文献时必须丢掉上一篇的材料：否则标题已经是「第 2 篇」，正文还停在第 1 篇。
        if loadedN != target.n {
            state = .loading
            tab = .fulltext
            loadedN = target.n
        } else if state.value == nil {
            state = .loading
        }
        focusPid = target.pid
        requestSeq += 1
        let seq = requestSeq
        let n = target.n
        do {
            let detail = try await client.answerPaper(id: answerID, n: n)
            guard seq == requestSeq else { return }
            state = .loaded(Material(detail: detail))
        } catch {
            guard seq == requestSeq else { return }
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
                let markdown = try await client.answerPaperMarkdown(id: answerID, n: n)
                guard seq == requestSeq else { return }
                state = .loaded(Material(legacyMarkdown: markdown))
                tab = .fulltext
            } catch {
                guard seq == requestSeq else { return }
                // 只有回落端点同样 404 才能断定是旧版导入；断网、500 要如实报错。
                state = .failed(error.status == 404 ? "此答案没有保存原文材料" : error.userMessage)
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
                    Text(detail?.title.isEmpty == false ? detail!.title : "参考文献 \(target.n)")
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
                badges(detail)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private func badges(_ detail: AnswerPaperDetail) -> some View {
        FlowLayout {
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
                            .quoteBar()
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
                                Button { focus(pid) } label: {
                                    Label("定位原文", systemImage: "text.line.first.and.arrowtriangle.forward")
                                }
                                .font(.caption.weight(.medium))
                                .buttonStyle(.plain)
                                .foregroundStyle(Color.accentColor)
                            }
                        }
                    }
                    .card()
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
                    Button { onFocus(pid) } label: {
                        Label("定位原文", systemImage: "text.line.first.and.arrowtriangle.forward")
                    }
                    .font(.caption.weight(.medium))
                    .buttonStyle(.plain)
                    .foregroundStyle(Color.accentColor)
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
                    .quoteBar()
            }
        }
        .card()
    }
}
