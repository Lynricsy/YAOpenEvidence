import SwiftUI
import YAOEKit

struct HistoryView: View {
    @Environment(SessionStore.self) private var session
    @Environment(AppModel.self) private var app
    @Environment(ErrorPresenter.self) private var errors

    @State private var model = HistoryModel()
    @State private var pendingDelete: AnswerSummary?

    var body: some View {
        @Bindable var model = model
        List {
            ForEach(model.items) { item in
                Button {
                    app.historyPath.append(.answer(item.id))
                } label: {
                    HistoryRow(item: item, showLegacyBadge: session.isAdmin)
                }
                .buttonStyle(.plain)
                .swipeActions(edge: .trailing) {
                    if item.status.isActive {
                        Button("取消任务") { Task { await model.cancel(item) } }
                            .tint(.orange)
                    } else {
                        Button("删除", role: .destructive) { pendingDelete = item }
                    }
                }
                .contextMenu {
                    if item.status.isActive {
                        Button("取消任务") { Task { await model.cancel(item) } }
                    } else {
                        Button("删除", role: .destructive) { pendingDelete = item }
                    }
                }
            }

            if model.total > 0 {
                HStack {
                    Button("上一页") { model.previousPage() }
                        .disabled(!model.canPrevious)
                    Spacer()
                    Text(model.rangeLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("下一页") { model.nextPage() }
                        .disabled(!model.canNext)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .overlay {
            switch model.page {
            case .idle, .loading:
                ProgressView()
                    .controlSize(.large)
            case .failed(let message):
                ErrorPanel(message: message, retry: { Task { await model.load() } })
            case .loaded(let page):
                if page.items.isEmpty {
                    if model.hasFilter {
                        ContentUnavailableView("没有符合条件的问答", systemImage: "magnifyingglass")
                    } else {
                        ContentUnavailableView {
                            Label("还没有问答，去提问", systemImage: "clock")
                        } actions: {
                            Button("新建问答") { app.requestNewQuestion() }
                                .buttonStyle(.borderedProminent)
                        }
                    }
                }
            }
        }
        .navigationTitle("历史")
        .searchable(text: $model.query, prompt: "搜索历史问题")
        .toolbar {
            ToolbarItem {
                Picker("状态", selection: Binding(get: { model.status }, set: { model.setStatus($0) })) {
                    Text("全部").tag(AnswerStatus?.none)
                    ForEach(AnswerStatus.allCases, id: \.self) { status in
                        Text(StatusBadge.label(for: status)).tag(AnswerStatus?.some(status))
                    }
                }
                .pickerStyle(.menu)
            }
        }
        .accountToolbar()
        .refreshable { await model.load() }
        .task {
            model.configure(session: session, app: app, errors: errors)
            await model.load()
        }
        .task(id: app.answersVersion) {
            guard app.answersVersion > 0 else { return }
            await model.load()
        }
        .onDisappear { model.teardown() }
        .confirmationDialog(
            "删除这份答案？",
            isPresented: Binding(get: { pendingDelete != nil }, set: { if !$0 { pendingDelete = nil } }),
            titleVisibility: .visible
        ) {
            Button("删除", role: .destructive) {
                if let item = pendingDelete {
                    Task { await model.delete(item) }
                }
                pendingDelete = nil
            }
            Button("保留", role: .cancel) { pendingDelete = nil }
        } message: {
            Text("问答结果与本次阅读材料将被删除，共享文献库不受影响。此操作不可撤销。")
        }
    }
}

struct HistoryRow: View {
    let item: AnswerSummary
    let showLegacyBadge: Bool

    /// 管理员可见：历史导入的答案没有筛选标签与文献计数。
    private var isLegacy: Bool {
        item.status == .ready && item.filtersLabel == nil && item.nPapers == nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                StatusBadge(item.status)
                if showLegacyBadge, isLegacy {
                    Pill(text: "历史导入")
                }
            }
            Text(item.question)
                .font(.subheadline)
                .lineLimit(2)
            if let label = item.filtersLabel, !label.isEmpty {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 6) {
                if let papers = item.nPapers {
                    Text("\(papers) 篇文献 · \(item.nFulltext ?? 0) 篇全文")
                }
                Text(item.createdAt, format: .relative(presentation: .named))
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
            if let error = item.error {
                Text(JobErrorMessage.text(for: error.code))
                    .font(.caption2)
                    .foregroundStyle(.red)
            }
        }
        .padding(.vertical, 4)
        .contentShape(.rect)
    }
}
