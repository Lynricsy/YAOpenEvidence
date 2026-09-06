import SwiftUI
import YAOEKit

struct AnswerScreen: View {
    let answerID: String

    @Environment(SessionStore.self) private var session
    @Environment(AppModel.self) private var app
    @Environment(ErrorPresenter.self) private var errors
    @Environment(\.dismiss) private var dismiss
    #if os(iOS)
        @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    @State private var model: AnswerScreenModel
    @State private var followUp = ""
    @State private var submitting = false
    @State private var showDeleteConfirm = false

    init(answerID: String) {
        self.answerID = answerID
        _model = State(initialValue: AnswerScreenModel(answerID: answerID))
    }

    private var isRegular: Bool {
        #if os(iOS)
            horizontalSizeClass == .regular
        #else
            true
        #endif
    }

    var body: some View {
        content
            .navigationTitle("问答")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar { toolbarMenu }
            .task {
                model.configure(session: session, app: app, errors: errors)
                await model.load()
            }
            .onDisappear { model.teardown() }
            .safeAreaInset(edge: .bottom) { composer }
            .modifier(ReaderPresentation(model: model, isRegular: isRegular))
            .confirmationDialog(
                "删除这份答案？",
                isPresented: $showDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button("删除", role: .destructive) {
                    Task { if await model.delete() { dismiss() } }
                }
                Button("保留", role: .cancel) {}
            } message: {
                Text("问答结果与本次阅读材料将被删除，共享文献库不受影响。此操作不可撤销。")
            }
    }

    private var content: some View {
        ScrollView {
            LoadableView(state: model.answer, retry: { Task { await model.load() } }) { answer in
                VStack(alignment: .leading, spacing: 20) {
                    AnswerHeader(answer: answer)
                    body(for: answer)
                }
                .frame(maxWidth: 760)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
    }

    @ViewBuilder
    private func body(for answer: Answer) -> some View {
        switch answer.status {
        case .queued, .running:
            ProgressPipelineView(
                live: model.monitor?.live ?? .empty,
                connection: model.monitor?.connection ?? .idle,
                useKb: AskFilters(options: answer.options).useKb,
                cancelRequested: model.cancelRequested,
                onCancel: { Task { await model.cancel() } }
            )

        case .ready:
            MarkdownDocumentView(blocks: model.blocks, onCite: { model.openReader($0) })
            SourceListView(
                papers: answer.papers,
                nFulltext: answer.nFulltext ?? 0,
                citationCounts: model.citationCounts,
                onOpen: { n, pid in model.reader = ReaderTarget(n: n, pid: pid) }
            )
            reaskButton(answer: answer, title: "重新提问")

        case .failed:
            VStack(alignment: .leading, spacing: 10) {
                Label(JobErrorMessage.text(for: answer.error?.code ?? "internal_error"), systemImage: "exclamationmark.triangle")
                    .font(.headline)
                    .foregroundStyle(.red)
                if let message = answer.error?.message, !message.isEmpty {
                    Text(message)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }
                reaskButton(answer: answer, title: "放宽筛选后重新提问")
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.red.opacity(0.08), in: .rect(cornerRadius: 12))

        case .cancelled:
            VStack(spacing: 12) {
                ContentUnavailableView("任务已取消", systemImage: "xmark.circle")
                reaskButton(answer: answer, title: "重新提问")
            }
        }
    }

    private func reaskButton(answer: Answer, title: String) -> some View {
        Button(title) {
            app.reask(question: answer.question, options: answer.options)
        }
        .buttonStyle(.bordered)
    }

    private var composer: some View {
        QuestionComposer(
            text: $followUp,
            placeholder: "追问或提出新问题…",
            pending: submitting,
            onSubmit: submitFollowUp
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.bar)
    }

    @ToolbarContentBuilder
    private var toolbarMenu: some ToolbarContent {
        ToolbarItem {
            Menu {
                if let answer = model.current {
                    Button("沿用此次筛选重新提问") {
                        app.reask(question: answer.question, options: answer.options)
                    }
                    Button("删除", role: .destructive) { showDeleteConfirm = true }
                        .disabled(answer.status.isActive || model.deleting)
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .disabled(model.current == nil)
        }
    }

    private func submitFollowUp() {
        submitting = true
        Task {
            defer { submitting = false }
            guard let answer = await AskSubmission.create(
                question: followUp,
                session: session,
                app: app,
                errors: errors
            ) else { return }
            followUp = ""
            app.openAnswer(answer.id)
        }
    }
}

/// regular 宽度用右侧检查器，compact 用全屏 sheet。
private struct ReaderPresentation: ViewModifier {
    @Bindable var model: AnswerScreenModel
    let isRegular: Bool

    func body(content: Content) -> some View {
        if isRegular {
            content.inspector(isPresented: Binding(
                get: { model.reader != nil },
                set: { if !$0 { model.reader = nil } }
            )) {
                readerPane
                    .inspectorColumnWidth(min: 360, ideal: 480, max: 720)
            }
        } else {
            content.sheet(item: $model.reader) { target in
                NavigationStack {
                    ReaderPane(
                        answerID: model.answerID,
                        target: target,
                        answerActive: model.current?.status.isActive ?? false,
                        quotes: model.quotes(n: target.n, pid: target.pid)
                    )
                }
                .presentationDetents([.large])
            }
        }
    }

    @ViewBuilder
    private var readerPane: some View {
        if let target = model.reader {
            ReaderPane(
                answerID: model.answerID,
                target: target,
                answerActive: model.current?.status.isActive ?? false,
                quotes: model.quotes(n: target.n, pid: target.pid)
            )
        } else {
            Color.clear
        }
    }
}

struct AnswerHeader: View {
    let answer: Answer

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                StatusBadge(answer.status)
                Text(answer.createdAt, format: .relative(presentation: .named))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .help(answer.createdAt.formatted(.dateTime.year().month().day().hour().minute()))
                if let papers = answer.nPapers {
                    Text("\(papers) 篇文献 · \(answer.nFulltext ?? 0) 篇全文")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text(answer.question)
                .font(.system(.title, design: .serif, weight: .semibold))
                .textSelection(.enabled)

            if let label = answer.filtersLabel, !label.isEmpty {
                Pill(text: label, systemImage: "line.3.horizontal.decrease.circle")
            }

            if !answer.queries.isEmpty {
                DisclosureGroup("检索式（\(answer.queries.count)）") {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(answer.queries, id: \.self) { query in
                            Text(query)
                                .font(.system(.caption, design: .monospaced))
                                .textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.top, 6)
                }
                .font(.subheadline)
            }
        }
    }
}
