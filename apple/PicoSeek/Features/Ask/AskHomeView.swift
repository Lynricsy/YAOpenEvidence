import SwiftUI
import PicoSeekKit

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
            VStack(alignment: .leading, spacing: 28) {
                // 品牌区：标志与主标题同源于登录页，随系统外观切换。
                VStack(alignment: .leading, spacing: 12) {
                    BrandLogo(size: 40)
                    Text("请提出您的临床或科研问题")
                        .font(.system(.title, design: .serif, weight: .semibold))
                    Text("从 PubMed / Europe PMC 检索并逐篇核实，生成可回溯到原文段落的循证综述。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 24)

                VStack(alignment: .leading, spacing: 10) {
                    Text("试试这些问题")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                    ForEach(Self.samples, id: \.self) { sample in
                        Button {
                            app.askDraft = sample
                            inputFocused = true
                        } label: {
                            HStack {
                                Text(sample)
                                    .font(.subheadline)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.tertiary)
                            }
                            .card()
                        }
                        .buttonStyle(.pressableCard)
                    }
                }
            }
            .frame(maxWidth: Metrics.contentMaxWidth)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Metrics.pageInset)
            .padding(.bottom, 28)
        }
        .scrollDismissesKeyboard(.interactively)
        .floatingComposer {
            QuestionComposer(
                text: $app.askDraft,
                pending: pending,
                focused: $inputFocused,
                onSubmit: submit
            )
        }
        .navigationTitle("提问")
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
            .accountToolbar()
            // 只有主动「新建问答」才抢焦点：一进 App 就弹键盘会挡住底部 Tab 栏。
            .task(id: app.newQuestionToken) {
                if app.newQuestionToken > 0 { inputFocused = true }
            }
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
