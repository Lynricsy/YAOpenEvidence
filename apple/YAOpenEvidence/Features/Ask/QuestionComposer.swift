import SwiftUI
import YAOEKit

/// 提问输入框：多行输入 + 字数 + 筛选摘要 + 发送。提问页与答案页底部追问共用。
struct QuestionComposer: View {
    @Binding var text: String
    var placeholder = "输入临床或科研问题…"
    var pending = false
    var focused: FocusState<Bool>.Binding?
    let onSubmit: () -> Void

    @Environment(AppModel.self) private var app
    @State private var showFilters = false
    @State private var sendCount = 0

    private var trimmed: String { text.trimmingCharacters(in: .whitespacesAndNewlines) }

    private var canSubmit: Bool {
        !pending && !trimmed.isEmpty && trimmed.count <= 2000 && app.filters.isYearRangeValid()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            textField

            if !app.filters.isYearRangeValid() {
                Text("筛选里的年份范围无效，请先修正。")
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            HStack(spacing: 8) {
                filterChip
                Spacer(minLength: 8)
                // 只在接近上限时提示字数，常驻计数器是噪音。
                if trimmed.count >= 1800 {
                    Text("\(trimmed.count)/2000")
                        .font(.caption2)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .foregroundStyle(trimmed.count > 2000 ? .red : .secondary)
                }
                sendButton
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 10)
        .glassEffect(.regular, in: .rect(cornerRadius: Metrics.composerRadius))
        .sensoryFeedback(.impact(weight: .light), trigger: sendCount)
        .sheet(isPresented: $showFilters) {
            FilterSheet()
        }
    }

    private var filterChip: some View {
        Button {
            showFilters = true
        } label: {
            Label(app.filters.summary, systemImage: "line.3.horizontal.decrease")
                .font(.caption.weight(.medium))
                .lineLimit(1)
                .truncationMode(.tail)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.fill.tertiary, in: .capsule)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.secondary)
    }

    private var sendButton: some View {
        Button {
            sendCount += 1
            onSubmit()
        } label: {
            ZStack {
                Circle().fill(canSubmit ? Color.accentColor : Color.secondary.opacity(0.25))
                if pending {
                    ProgressView().controlSize(.small).tint(.white)
                } else {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(canSubmit ? .white : .secondary)
                }
            }
            .frame(width: 32, height: 32)
        }
        .buttonStyle(.plain)
        .disabled(!canSubmit)
        .keyboardShortcut(.return, modifiers: .command)
        .accessibilityLabel("发送")
        .animation(.snappy, value: canSubmit)
    }

    @ViewBuilder
    private var textField: some View {
        let field = TextField(placeholder, text: $text, axis: .vertical)
            .lineLimit(1 ... 6)
            .textFieldStyle(.plain)
            .font(.body)
        if let focused {
            field.focused(focused)
        } else {
            field
        }
    }
}

/// 提交提问的共用流程：创建任务 → 通知列表刷新 → 返回新答案。
@MainActor
enum AskSubmission {
    static func create(
        question: String,
        session: SessionStore,
        app: AppModel,
        errors: ErrorPresenter
    ) async -> Answer? {
        guard let client = session.client else { return nil }
        let trimmed = question.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        do {
            let answer = try await client.createAnswer(app.filters.answerCreate(question: trimmed))
            app.noteAnswersChanged()
            return answer
        } catch {
            if error.code == "too_many_jobs" {
                errors.present(message: error.userMessage)
            } else {
                errors.present(error)
            }
            return nil
        }
    }
}
