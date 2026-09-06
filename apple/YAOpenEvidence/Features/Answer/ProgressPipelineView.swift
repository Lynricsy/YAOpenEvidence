import SwiftUI
import YAOEKit

/// 实时进度面板：阶段列表 + 当前进度条 + 候选文献 + 运行日志 + 连接态。
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
        VStack(alignment: .leading, spacing: 14) {
            header

            VStack(alignment: .leading, spacing: 10) {
                ForEach(stages, id: \.self) { stage in
                    stageRow(stage)
                }
            }

            if let progress = live.progress, live.terminal == nil, progress.total > 0 {
                VStack(alignment: .leading, spacing: 4) {
                    ProgressView(value: Double(progress.current), total: Double(progress.total))
                    Text("\(progress.title ?? progress.stage.label) \(progress.current)/\(progress.total)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

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

            if !live.logs.isEmpty {
                DisclosureGroup("运行日志（\(live.logs.count)）") {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(live.logs) { line in
                            Text(line.message)
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundStyle(line.level == .warning ? .orange : .secondary)
                                .textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.top, 6)
                }
                .font(.subheadline)
            }
        }
        .padding(16)
        .background(.quaternary.opacity(0.25), in: .rect(cornerRadius: 14))
    }

    private var header: some View {
        HStack {
            Label(connection.label, systemImage: "dot.radiowaves.left.and.right")
                .font(.caption)
                .foregroundStyle(connectionTone)
            Spacer()
            Button(cancelRequested ? "取消中…" : "取消", action: onCancel)
                .buttonStyle(.bordered)
                .controlSize(.small)
                .disabled(cancelRequested)
        }
    }

    private var connectionTone: Color {
        switch connection {
        case .open: .green
        case .reconnecting: .orange
        default: .secondary
        }
    }

    @ViewBuilder
    private func stageRow(_ stage: StageKey) -> some View {
        let state = live.stages[stage]
        HStack(alignment: .top, spacing: 10) {
            Group {
                switch state?.status {
                case .finished:
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                case .running:
                    ProgressView().controlSize(.small)
                case nil:
                    Image(systemName: "circle").foregroundStyle(.secondary)
                }
            }
            .frame(width: 20, height: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(stage.label)
                    .font(.subheadline)
                    .foregroundStyle(state == nil ? .secondary : .primary)
                if let detail = state?.detail {
                    let summary = stageSummary(stage, detail: detail)
                    if !summary.isEmpty {
                        Text(summary)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            Spacer()
        }
    }
}
