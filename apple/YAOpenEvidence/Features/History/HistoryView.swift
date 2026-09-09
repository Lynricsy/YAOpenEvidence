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
                NavigationLink(value: AskRoute.answer(item.id)) {
                    HistoryRow(item: item)
                }
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
                .onAppear {
                    if item.id == model.items.last?.id {
                        Task { await model.loadMore() }
                    }
                }
            }

            if model.loadingMore {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
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
                Menu {
                    Picker("状态", selection: Binding(get: { model.status }, set: { model.setStatus($0) })) {
                        Text("全部").tag(AnswerStatus?.none)
                        ForEach(AnswerStatus.allCases, id: \.self) { status in
                            Text(StatusBadge.label(for: status)).tag(AnswerStatus?.some(status))
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
        }
        .accountToolbar()
        .refreshable { await model.refresh() }
        .task {
            model.configure(session: session, app: app, errors: errors)
            await model.load()
        }
        .task(id: app.answersVersion) {
            guard app.answersVersion > 0 else { return }
            await model.refresh()
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

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(item.question)
                .font(.body.weight(.medium))
                .lineLimit(2)

            // 一条会话在列表里只占一行，用「始于」把根问题带出来，否则追问后看不出这轮从哪来。
            if let root = item.rootQuestion, !root.isEmpty {
                Text("始于：\(root)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            HStack(spacing: 6) {
                // 已完成的答案不需要「已完成」徽标，只有异常状态值得占位。
                if item.status != .ready {
                    StatusBadge(item.status)
                }
                EngineBadge(engine: item.engine)
                if item.nTurns > 1 {
                    Pill(text: "\(item.nTurns) 轮")
                }
                Text(item.createdAt, format: .relative(presentation: .named))
                if let papers = item.nPapers {
                    Text("· \(papers) 篇文献")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            if let label = item.filtersLabel, !label.isEmpty {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }

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
