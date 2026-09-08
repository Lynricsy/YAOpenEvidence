import SwiftUI
import YAOEKit

@MainActor
@Observable
final class LibraryModel {
    static let pageSize = 20

    var query = "" {
        didSet {
            guard query != oldValue else { return }
            debounceSearch()
        }
    }

    var page: Loadable<Page<PaperMeta>> = .idle

    private var session: SessionStore?
    private var searchTask: Task<Void, Never>?
    private var requestSeq = 0

    /// 首页之后追加的批次。首页留在 `page` 里，重新检索时只需清空这里。
    private(set) var more: [PaperMeta] = []
    private(set) var loadingMore = false

    var items: [PaperMeta] { (page.value?.items ?? []) + more }
    var total: Int { page.value?.total ?? 0 }
    var hasQuery: Bool { !query.trimmingCharacters(in: .whitespaces).isEmpty }
    var canLoadMore: Bool { page.value != nil && !loadingMore && items.count < total }

    func configure(session: SessionStore) {
        self.session = session
    }

    func teardown() {
        requestSeq += 1
        searchTask?.cancel()
        searchTask = nil
    }

    func load() async {
        guard let client = session?.client else { return }
        requestSeq += 1
        let seq = requestSeq
        let q = query.trimmingCharacters(in: .whitespaces)
        if page.value == nil { page = .loading }
        do {
            let result = try await client.papers(q: q, limit: Self.pageSize, offset: 0)
            guard seq == requestSeq else { return }
            page = .loaded(result)
            more = []
        } catch {
            guard seq == requestSeq else { return }
            page = .failed(error.userMessage)
        }
    }

    func loadMore() async {
        guard canLoadMore, let client = session?.client, let first = page.value else { return }
        // 不推进 requestSeq：期间若发生重新检索，序号会变，这次的结果自然被丢弃。
        let seq = requestSeq
        let q = query.trimmingCharacters(in: .whitespaces)
        loadingMore = true
        defer { loadingMore = false }
        do {
            let result = try await client.papers(q: q, limit: Self.pageSize, offset: items.count)
            guard seq == requestSeq else { return }
            more += result.items
            // 空页说明已到末尾：把 total 收敛到本地条数，避免 canLoadMore 永远为真而被反复触发。
            let syncedTotal = result.items.isEmpty ? items.count : result.total
            page = .loaded(Page(items: first.items, total: syncedTotal, limit: first.limit, offset: first.offset))
        } catch {
            // 追加失败不该破坏已展示的列表，本页也没有错误呈现器，静默留待下次触发。
        }
    }

    private func debounceSearch() {
        requestSeq += 1
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled, let self else { return }
            await load()
        }
    }
}

struct LibraryView: View {
    @Environment(SessionStore.self) private var session

    @State private var model = LibraryModel()

    var body: some View {
        @Bindable var model = model
        List {
            ForEach(model.items) { paper in
                NavigationLink(value: PaperRoute(key: paper.key, pid: nil)) {
                    PaperRow(paper: paper)
                }
                .onAppear {
                    guard paper.id == model.items.last?.id else { return }
                    Task { await model.loadMore() }
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
            case .failed(let message):
                ErrorPanel(message: message, retry: { Task { await model.load() } })
            case .loaded(let page):
                if page.items.isEmpty {
                    ContentUnavailableView(
                        model.hasQuery ? "未找到文献" : "文献库为空",
                        systemImage: "books.vertical"
                    )
                }
            }
        }
        .navigationTitle("文献库")
        .searchable(text: $model.query, prompt: "搜索标题或期刊")
        .accountToolbar()
        .refreshable { await model.load() }
        .task {
            model.configure(session: session)
            await model.load()
        }
        .onDisappear { model.teardown() }
    }
}

struct PaperRow: View {
    let paper: PaperMeta

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(paper.title.isEmpty ? "（无标题）" : paper.title)
                .font(.subheadline.weight(.medium))
                .lineLimit(2)
            if !paper.authors.isEmpty {
                Text(paper.authors)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            HStack(spacing: 6) {
                if !paper.journal.isEmpty { Text(paper.journal).italic() }
                if !paper.year.isEmpty { Text(paper.year) }
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            FlowLayout {
                RankBadge(quartile: paper.quartile)
                ForEach(paper.types.prefix(3), id: \.self) { type in
                    Pill(text: type)
                }
            }

            if let indexedAt = paper.indexedAt {
                Text(indexedAt, format: .relative(presentation: .named))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
        .contentShape(.rect)
    }
}
