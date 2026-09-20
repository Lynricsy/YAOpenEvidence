import SwiftUI
import PicoSeekKit

/// 一条智能体会话的全部回合。追问把上下文摊在答案页上，不必回历史里翻。
struct ThreadNavView: View {
    let turns: [AnswerSummary]
    let currentID: String

    @Environment(AppModel.self) private var app

    private var at: Int {
        turns.firstIndex { $0.id == currentID } ?? 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("对话脉络 · 第 \(at + 1)/\(turns.count) 轮")
                .font(.caption)
                .foregroundStyle(.secondary)

            ForEach(Array(turns.enumerated()), id: \.element.id) { index, turn in
                row(index: index, turn: turn)
            }
        }
        .card(padding: 12)
        .accessibilityLabel("对话脉络")
    }

    @ViewBuilder
    private func row(index: Int, turn: AnswerSummary) -> some View {
        let current = turn.id == currentID
        Button {
            guard !current else { return }
            app.openAnswer(turn.id)
        } label: {
            HStack(spacing: 8) {
                Text("\(index + 1)")
                    .font(.caption2.monospacedDigit())
                    .frame(width: 20, height: 20)
                    .overlay(Circle().strokeBorder(.tertiary))
                Text(turn.question)
                    .font(.subheadline)
                    .fontWeight(current ? .semibold : .regular)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                if turn.status != .ready {
                    StatusBadge(turn.status)
                }
                Spacer(minLength: 0)
            }
            .foregroundStyle(current ? .primary : .secondary)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .disabled(current)
        .accessibilityAddTraits(current ? [.isSelected] : [])
    }
}
