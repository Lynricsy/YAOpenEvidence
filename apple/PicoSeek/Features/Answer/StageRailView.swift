import SwiftUI
import PicoSeekKit

/// 阶段节点条：运行中的流水线与答案页的后台写库共用同一套视觉语言。
/// 节点序列与状态由 kit 的 `askRailNodes` 给出，这里只负责画；
/// 节点下要不要再挂摘要或进度条由调用方通过 `trailing` 决定。
struct StageRailView<Trailing: View>: View {
    let nodes: [RailNode]
    @ViewBuilder var trailing: (RailNode) -> Trailing

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(nodes) { node in
                HStack(alignment: .top, spacing: 10) {
                    glyph(node.status)
                        .frame(width: 20, height: 20)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(node.label)
                            .font(node.status == .running ? .subheadline.weight(.semibold) : .subheadline)
                            .foregroundStyle(node.status == .todo ? .secondary : .primary)

                        if let hint = node.hint, !hint.isEmpty {
                            Text(hint)
                                .font(.caption)
                                .foregroundStyle(node.status == .failed ? Color.red : Color.secondary)
                        }

                        trailing(node)
                    }
                    Spacer()
                }
            }
        }
        .animation(.default, value: nodes)
    }

    @ViewBuilder
    private func glyph(_ status: RailStatus) -> some View {
        switch status {
        case .done:
            Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.accentColor)
        case .running:
            ProgressView().controlSize(.small)
        case .waiting:
            // 排上队但还没轮到：与「还没走到」要能区分开。
            Image(systemName: "clock").foregroundStyle(.secondary)
        case .failed:
            Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(Color.red)
        case .cancelled:
            Image(systemName: "minus.circle").foregroundStyle(.secondary)
        case .todo:
            Image(systemName: "circle").foregroundStyle(.quaternary)
        }
    }
}
