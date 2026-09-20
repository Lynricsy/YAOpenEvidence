import SwiftUI
import PicoSeekKit

/// 智能体的检索轨迹：实时（`JobLive.tools`）与落库（`Answer.trace`）两处共用同一行结构，
/// 同一次调用在进行中和完成后长得一样，只有右侧状态变。
struct TraceListView: View {
    let calls: [ToolCall]

    var body: some View {
        if !calls.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(calls) { call in
                    row(call)
                }
            }
        }
    }

    private func row(_ call: ToolCall) -> some View {
        HStack(spacing: 10) {
            Image(systemName: ToolPresentation.symbol(tool: call.tool))
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 24, height: 24)
                .background(.fill.tertiary, in: .rect(cornerRadius: 6))

            VStack(alignment: .leading, spacing: 1) {
                Text(ToolPresentation.label(server: call.server, tool: call.tool))
                    .font(.subheadline)
                let args = ToolPresentation.describeArgs(call.args)
                if !args.isEmpty {
                    Text(args)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }

            Spacer(minLength: 8)
            status(call)
        }
    }

    @ViewBuilder
    private func status(_ call: ToolCall) -> some View {
        switch call.status {
        case .started:
            ProgressView()
                .controlSize(.small)
        case .completed:
            HStack(spacing: 4) {
                Image(systemName: "checkmark")
                    .foregroundStyle(.green)
                Text(ToolPresentation.formatDuration(call.durationMs))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            .font(.caption)
        case .failed:
            HStack(spacing: 4) {
                Image(systemName: "xmark")
                Text(call.error ?? "失败")
                    .lineLimit(1)
            }
            .font(.caption)
            .foregroundStyle(.red)
            .frame(maxWidth: 180, alignment: .trailing)
        }
    }
}
