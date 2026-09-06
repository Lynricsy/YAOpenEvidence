import SwiftUI
import YAOEKit

/// 来源列表：采用的文献在前，`relevance == 0` 的折叠进「已阅读但未采用」。
struct SourceListView: View {
    let papers: [AnswerPaper]
    let nFulltext: Int
    let citationCounts: [Int: Int]
    let onOpen: (Int, Int?) -> Void

    private var ordered: [AnswerPaper] { papers.sorted { $0.n < $1.n } }
    private var used: [AnswerPaper] { ordered.filter { $0.relevance != 0 } }
    private var unused: [AnswerPaper] { ordered.filter { $0.relevance == 0 } }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("来源 \(papers.count) 篇 · \(nFulltext) 篇全文")
                .font(.headline)

            ForEach(used) { paper in
                SourceCard(paper: paper, citedCount: citationCounts[paper.n] ?? 0, onOpen: onOpen)
            }

            if !unused.isEmpty {
                DisclosureGroup("已阅读但未采用（\(unused.count)）") {
                    VStack(spacing: 10) {
                        ForEach(unused) { paper in
                            SourceCard(paper: paper, citedCount: citationCounts[paper.n] ?? 0, onOpen: onOpen)
                        }
                    }
                    .padding(.top, 8)
                }
                .font(.subheadline)
            }
        }
    }
}

struct SourceCard: View {
    let paper: AnswerPaper
    let citedCount: Int
    let onOpen: (Int, Int?) -> Void

    var body: some View {
        Button {
            onOpen(paper.n, nil)
        } label: {
            HStack(alignment: .top, spacing: 12) {
                CitationSquare(n: paper.n, size: 26)

                VStack(alignment: .leading, spacing: 6) {
                    Text(paper.title.isEmpty ? "（无标题）" : paper.title)
                        .font(.subheadline.weight(.medium))
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.primary)

                    if !paper.authors.isEmpty {
                        Text(paper.authors)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }

                    HStack(spacing: 6) {
                        if !paper.journal.isEmpty {
                            Text(paper.journal).italic()
                        }
                        if !paper.year.isEmpty {
                            Text(paper.year)
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    ViewThatFits(in: .horizontal) {
                        badges
                        VStack(alignment: .leading, spacing: 6) { badges }
                    }

                    HStack(spacing: 12) {
                        if !paper.pmid.isEmpty, let url = URL(string: "https://pubmed.ncbi.nlm.nih.gov/\(paper.pmid)/") {
                            Link("PubMed", destination: url)
                        }
                        if !paper.doi.isEmpty, let url = URL(string: "https://doi.org/\(paper.doi)") {
                            Link("DOI", destination: url)
                        }
                    }
                    .font(.caption)
                }
                Spacer(minLength: 0)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.quaternary.opacity(0.22), in: .rect(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var badges: some View {
        HStack(spacing: 6) {
            RankBadge(quartile: paper.quartile, rankLabel: paper.rankLabel)
            SourceBadge(source: paper.source)
            if let relevance = paper.relevance {
                Pill(text: "相关性 \(relevance)")
            }
            if paper.nCitations > 0 {
                Pill(
                    text: "引文核实 \(paper.nCitationsVerified)/\(paper.nCitations)",
                    tone: paper.nCitationsVerified == paper.nCitations ? .green : .orange
                )
            }
            if citedCount > 0 {
                Text("正文引用 \(citedCount) 处")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
