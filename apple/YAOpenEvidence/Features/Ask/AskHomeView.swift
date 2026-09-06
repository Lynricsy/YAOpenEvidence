import SwiftUI
import YAOEKit

struct AskHomeView: View {
    @Environment(SessionStore.self) private var session
    @Environment(AppModel.self) private var app
    @Environment(ErrorPresenter.self) private var errors

    @FocusState private var inputFocused: Bool
    @State private var pending = false

    private static let samples = [
        "SGLT2抑制剂对HFpEF患者有什么获益？",
        "替尔泊肽与司美格鲁肽在肥胖患者减重和心血管结局上的比较",
        "他汀类药物一级预防在老年人中的获益与风险",
    ]

    var body: some View {
        @Bindable var app = app
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Label("循证医学文献问答", systemImage: "book.closed")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Color.accentColor)

                VStack(alignment: .leading, spacing: 10) {
                    Text("请提出您的临床或科研问题")
                        .font(.system(.largeTitle, design: .serif, weight: .semibold))
                    Text("从 PubMed / Europe PMC 检索并逐篇核实，生成可回溯到原文段落的循证综述。")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                QuestionComposer(
                    text: $app.askDraft,
                    pending: pending,
                    focused: $inputFocused,
                    onSubmit: submit
                )

                VStack(alignment: .leading, spacing: 10) {
                    Text("试试这些问题")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    ForEach(Self.samples, id: \.self) { sample in
                        Button {
                            app.askDraft = sample
                            inputFocused = true
                        } label: {
                            HStack {
                                Text(sample)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                                Image(systemName: "arrow.up.left")
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.quaternary.opacity(0.35), in: .rect(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }

                Text("仅供科研与教学参考，不构成医疗建议")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: 680)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.vertical, 28)
        }
        .navigationTitle("提问")
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
            .toolbar {
                ToolbarItem {
                    Button("新建问答", systemImage: "plus") { app.requestNewQuestion() }
                }
            }
            .accountToolbar()
            .task(id: app.newQuestionToken) { inputFocused = true }
    }

    private func submit() {
        pending = true
        Task {
            defer { pending = false }
            guard let answer = await AskSubmission.create(
                question: app.askDraft,
                session: session,
                app: app,
                errors: errors
            ) else { return }
            app.askDraft = ""
            app.askPath = [.answer(answer.id)]
        }
    }
}
