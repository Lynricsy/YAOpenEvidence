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
    @State private var showQueries = false
    @State private var collapse = ComposerCollapse()

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
            .floatingComposer { composer }
            .modifier(ReaderPresentation(model: model, isRegular: isRegular))
            .sheet(isPresented: $showQueries) {
                QueriesSheet(queries: model.current?.queries ?? [])
            }
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
                VStack(alignment: .leading, spacing: Metrics.sectionSpacing) {
                    AnswerHeader(answer: answer, thread: model.thread)
                    body(for: answer)
                }
                .frame(maxWidth: Metrics.contentMaxWidth)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, Metrics.pageInset)
                .padding(.vertical, 24)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        // 仿 Safari 地址栏：向下滚动把提问框缩成小药丸，向上滚动或回到顶部再展开。
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentOffset.y + geometry.contentInsets.top
        } action: { _, offset in
            collapse.track(offset: offset)
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
                engine: answer.engine,
                cancelRequested: model.cancelRequested,
                onCancel: { Task { await model.cancel() } }
            )

        case .ready:
            VStack(alignment: .leading, spacing: 28) {
                AnswerSectionsView(sections: model.sections, onCite: { model.openReader($0) })
                if answer.engine == .codex {
                    // 智能体不留逐篇原文快照，来源列表无从可列；能给的溯源就是这条轨迹。
                    if !answer.trace.isEmpty {
                        DisclosureGroup("检索轨迹（\(answer.trace.count)）") {
                            TraceListView(calls: answer.trace)
                                .padding(.top, 10)
                        }
                        .font(.subheadline)
                        .card()
                    }
                } else {
                    SourceListView(
                        papers: answer.papers,
                        onOpen: { n, pid in model.reader = ReaderTarget(n: n, pid: pid) }
                    )
                }
                if !answer.kbHits.isEmpty {
                    KbSupplementView(hits: answer.kbHits)
                }
                // 智能体的下一步是底部追问，不是把同一个问题再问一遍。
                if answer.engine != .codex {
                    reaskButton(answer: answer, title: "重新提问")
                }
            }

        case .failed:
            VStack(alignment: .leading, spacing: 12) {
                Label(
                    JobErrorMessage.text(for: answer.error?.code ?? "internal_error"),
                    systemImage: "exclamationmark.triangle.fill"
                )
                .font(.headline)
                .foregroundStyle(.red)
                reaskButton(
                    answer: answer,
                    title: answer.engine == .codex ? "重新提问" : "放宽筛选后重新提问"
                )
            }
            .card()

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
        .buttonBorderShape(.capsule)
    }

    private var composer: some View {
        // 智能体答完才谈得上续接；其余情况底部输入框就是「开一个新问题」。
        let continuing = model.current.map { $0.engine == .codex && $0.status == .ready } ?? false
        return QuestionComposer(
            text: $followUp,
            placeholder: "继续提问…",
            pending: submitting,
            mode: continuing ? .followUp : .ask,
            collapsible: true,
            scrolledDown: collapse.scrolledDown,
            onSubmit: continuing ? submitFollowUp : submitNew
        )
    }

    @ToolbarContentBuilder
    private var toolbarMenu: some ToolbarContent {
        ToolbarItem {
            Menu {
                if let answer = model.current {
                    Button("沿用此次筛选重新提问") {
                        app.reask(question: answer.question, options: answer.options)
                    }
                    Button("查看检索式") { showQueries = true }
                        .disabled(answer.queries.isEmpty)
                    Button("删除", role: .destructive) { showDeleteConfirm = true }
                        .disabled(answer.status.isActive || model.deleting)
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .disabled(model.current == nil)
        }
    }

    /// 续接同一智能体会话：新一轮沿用上一轮的筛选与 thread。
    private func submitFollowUp() {
        guard let client = session.client else { return }
        let question = followUp.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty else { return }
        submitting = true
        Task {
            defer { submitting = false }
            do {
                let created = try await client.followUp(id: answerID, question: question)
                followUp = ""
                app.noteAnswersChanged()
                app.openAnswer(created.id)
            } catch {
                errors.present(error)
            }
        }
    }

    private func submitNew() {
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
    /// 智能体会话的回合列表；只有一轮时不渲染脉络。
    var thread: [AnswerSummary] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Text(answer.createdAt, format: .relative(presentation: .named))
                    .help(answer.createdAt.formatted(.dateTime.year().month().day().hour().minute()))
                // 进行中由进度卡表达、失败由错误卡表达，头部不再重复状态徽标。
                if answer.status == .ready, let papers = answer.nPapers {
                    Text("·")
                    Text("\(papers) 篇文献")
                }
                EngineBadge(engine: answer.engine)
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            if thread.count > 1 {
                ThreadNavView(turns: thread, currentID: answer.id)
            }

            Text(answer.question)
                .font(.system(.title, design: .serif, weight: .semibold))
                .textSelection(.enabled)

            if let label = answer.filtersLabel, !label.isEmpty {
                Pill(text: label, systemImage: "line.3.horizontal.decrease.circle")
            }
        }
    }
}

/// 检索式：研究者复现检索时才打开，不占答案页正文。
private struct QueriesSheet: View {
    let queries: [String]

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(queries, id: \.self) { query in
                Text(query)
                    .font(.system(.footnote, design: .monospaced))
                    .textSelection(.enabled)
            }
            .navigationTitle("检索式")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
