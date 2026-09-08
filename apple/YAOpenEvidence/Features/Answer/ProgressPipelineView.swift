import SwiftUI
import YAOEKit

/// 实时进度面板：阶段列表 + 当前阶段进度 + 候选文献。
/// 刻意不展示 SSE 连接态与运行日志——那是排障信息，只有网络确实中断时才提示一句。
struct ProgressPipelineView: View {
    let live: JobLive
    let connection: JobLiveMonitor.Connection
    var useKb = true
    var cancelRequested = false
    let onCancel: () -> Void

    private var stages: [StageKey] {
        StageKey.askPipeline.filter { useKb || $0 != .kb }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("正在生成答案", systemImage: "sparkles")
                    .font(.headline)
                    .symbolEffect(.pulse)
                Spacer()
                Button(cancelRequested ? "取消中…" : "取消", action: onCancel)
                    .buttonStyle(.plain)
                    .font(.subheadline)
                    .foregroundStyle(.red)
                    .disabled(cancelRequested)
            }

            VStack(alignment: .leading, spacing: 12) {
                ForEach(stages, id: \.self) { stage in
                    stageRow(stage)
                }
            }
            .animation(.default, value: live.stages)

            if connection == .reconnecting {
                Label("网络不稳定，正在重新连接…", systemImage: "wifi.exclamationmark")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            candidates
        }
        .card(padding: 16)
    }

    @ViewBuilder
    private var candidates: some View {
        if let papers = live.search?.papers, !papers.isEmpty {
            DisclosureGroup("候选文献（\(papers.count)）") {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(papers) { paper in
                        HStack(alignment: .top, spacing: 8) {
                            Text(paper.n.map { "\($0)" } ?? "·")
                                .font(.caption.monospacedDigit())
                                .foregroundStyle(.secondary)
                                .frame(width: 22, alignment: .trailing)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(paper.title ?? "（无标题）")
                                    .font(.caption)
                                    .lineLimit(2)
                                Text([paper.journal, paper.year].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " · "))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if let label = paper.rankLabel, !label.isEmpty {
                                Pill(text: label)
                            }
                        }
                    }
                }
                .padding(.top, 6)
            }
            .font(.subheadline)
        }
    }

    @ViewBuilder
    private func stageRow(_ stage: StageKey) -> some View {
        let state = live.stages[stage]
        let running = state?.status == .running
        HStack(alignment: .top, spacing: 10) {
            Group {
                switch state?.status {
                case .finished:
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.accentColor)
                case .running:
                    ProgressView().controlSize(.small)
                case nil:
                    Image(systemName: "circle").foregroundStyle(.quaternary)
                }
            }
            .frame(width: 20, height: 20)

            VStack(alignment: .leading, spacing: 4) {
                Text(stage.label)
                    .font(running ? .subheadline.weight(.semibold) : .subheadline)
                    .foregroundStyle(state == nil ? .secondary : .primary)

                // 只在阶段结束后给摘要：进行中的 detail 只有 total，会渲染出一串 0。
                if state?.status == .finished, let detail = state?.detail {
                    let caption = Self.stageCaption(stage, detail: detail)
                    if !caption.isEmpty {
                        Text(caption)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                if running, live.terminal == nil, let progress = live.progress,
                   progress.stage == stage, progress.total > 0 {
                    ProgressView(value: Double(progress.current), total: Double(progress.total))
                        .tint(Color.accentColor)
                    if let title = progress.title, !title.isEmpty {
                        Text(title)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            Spacer()
        }
    }

    /// 面向用户的阶段摘要。kit 的 `stageSummary` 与 Web 端逐字对齐（含 `dropped` 明细等
    /// 排障字段），这里只挑用户关心的数字重写一份。
    private static func stageCaption(_ stage: StageKey, detail: [String: JSONValue]) -> String {
        func int(_ key: String) -> Int { detail[key]?.intValue ?? 0 }
        switch stage {
        case .queries:
            guard let count = detail["queries"]?.arrayValue?.count else { return "" }
            return "\(count) 条检索式"
        case .search:
            return "候选 \(int("candidates")) 篇，保留 \(int("kept")) 篇"
        case .fulltext:
            return "\(int("fulltext"))/\(int("total")) 篇获得全文"
        case .read:
            return "\(int("relevant"))/\(int("total")) 篇相关"
        case .kb:
            return "知识库共 \(int("items")) 条知识"
        case .synthesize, .reindex:
            return ""
        }
    }
}
