import SwiftUI
import YAOEKit

/// 提问输入框：多行输入 + 字数 + 筛选摘要 + 发送。提问页与答案页底部追问共用。
struct QuestionComposer: View {
    @Binding var text: String
    var placeholder = "例如：SGLT2 抑制剂对 HFpEF 患者有什么获益？"
    var pending = false
    var focused: FocusState<Bool>.Binding?
    let onSubmit: () -> Void

    @Environment(AppModel.self) private var app
    @State private var showFilters = false

    private var trimmed: String { text.trimmingCharacters(in: .whitespacesAndNewlines) }

    private var canSubmit: Bool {
        !pending && !trimmed.isEmpty && trimmed.count <= 2000 && app.filters.isYearRangeValid()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .bottom, spacing: 8) {
                textField
                Button {
                    onSubmit()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.circle)
                .labelStyle(.iconOnly)
                .disabled(!canSubmit)
                .keyboardShortcut(.return, modifiers: .command)
                .accessibilityLabel("提交问题")
            }

            HStack {
                Button {
                    showFilters = true
                } label: {
                    Label(app.filters.summary, systemImage: "line.3.horizontal.decrease.circle")
                        .font(.caption)
                        .lineLimit(1)
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)

                Spacer()

                Text("\(trimmed.count)/2000")
                    .font(.caption2)
                    .foregroundStyle(trimmed.count > 2000 ? .red : .secondary)
                    .monospacedDigit()
            }

            if !app.filters.isYearRangeValid() {
                Text("请填写有效起始年，结束年不得早于起始年。")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .sheet(isPresented: $showFilters) {
            FilterSheet()
        }
    }

    @ViewBuilder
    private var textField: some View {
        let field = TextField(placeholder, text: $text, axis: .vertical)
            .lineLimit(3 ... 8)
            .textFieldStyle(.roundedBorder)
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
