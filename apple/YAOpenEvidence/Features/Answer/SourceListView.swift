import SwiftUI
import YAOEKit

/// 参考文献：采用的文献在前，`relevance == 0` 的折叠进「其他已阅读文献」。
struct SourceListView: View {
    let papers: [AnswerPaper]
    let onOpen: (Int, Int?) -> Void

    private var ordered: [AnswerPaper] { papers.sorted { $0.n < $1.n } }
    private var used: [AnswerPaper] { ordered.filter { $0.relevance != 0 } }
    private var unused: [AnswerPaper] { ordered.filter { $0.relevance == 0 } }

    var body: some View {
        if papers.isEmpty {
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeading(module: .sources, count: "\(papers.count) 篇")

                ForEach(used) { paper in
                    SourceCard(paper: paper, onOpen: onOpen)
                }

                if !unused.isEmpty {
                    DisclosureGroup("其他已阅读文献（\(unused.count)）") {
                        VStack(spacing: 10) {
                            ForEach(unused) { paper in
                                SourceCard(paper: paper, onOpen: onOpen)
                            }
                        }
                        .padding(.top, 8)
                    }
                    .font(.subheadline)
                }
            }
        }
    }
}

struct SourceCard: View {
    let paper: AnswerPaper
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

                    badges

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
            .card()
        }
        .buttonStyle(.pressableCard)
    }

    /// 只保留读者能判断可信度的信息：分区、全文来源、引文核实比例。
    private var badges: some View {
        FlowLayout {
            RankBadge(quartile: paper.quartile, rankLabel: paper.rankLabel)
            SourceBadge(source: paper.source)
            if paper.nCitations > 0 {
                let verified = paper.nCitationsVerified == paper.nCitations
                Pill(
                    text: "\(paper.nCitationsVerified)/\(paper.nCitations) 条引文已核实",
                    tone: verified ? .green : .orange,
                    systemImage: verified ? "checkmark.seal.fill" : "exclamationmark.triangle.fill"
                )
            }
        }
    }
}
