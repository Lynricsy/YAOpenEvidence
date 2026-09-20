import Foundation
import PicoSeekKit

@MainActor
@Observable
final class HistoryModel {
    static let pageSize = 20
    /// 刷新时一次最多重取的条数：滚动很深时不为了保住滚动位置去拉一个巨大的页。
    private static let refreshCap = 100

    var status: AnswerStatus?
    var query = "" {
        didSet {
            guard query != oldValue else { return }
            debounceSearch()
        }
    }

    var page: Loadable<Page<AnswerSummary>> = .idle
    /// 无限滚动追加的后续页。首页始终留在 `page` 里，便于 `LoadableView` 表达三态。
    private(set) var more: [AnswerSummary] = []
    private(set) var loadingMore = false

    private var session: SessionStore?
    private var app: AppModel?
    private var errors: ErrorPresenter?
    private var searchTask: Task<Void, Never>?
    private var pollTask: Task<Void, Never>?
    private var requestSeq = 0

    /// 离开页面时取消防抖与轮询。
    func teardown() {
        requestSeq += 1
        searchTask?.cancel()
        searchTask = nil
        pollTask?.cancel()
        pollTask = nil
    }

    var items: [AnswerSummary] { (page.value?.items ?? []) + more }
    var total: Int { page.value?.total ?? 0 }
    var hasFilter: Bool { status != nil || !query.trimmingCharacters(in: .whitespaces).isEmpty }
    var canLoadMore: Bool { page.value != nil && !loadingMore && items.count < total }

    func configure(session: SessionStore, app: AppModel, errors: ErrorPresenter) {
        self.session = session
        self.app = app
        self.errors = errors
    }

    /// 首次加载与换筛选条件：回到列表顶部。
    func load() async {
        guard let client = session?.client else { return }
        requestSeq += 1
        let seq = requestSeq
        let snapshot = (status: status, query: query.trimmingCharacters(in: .whitespaces))
        if page.value == nil { page = .loading }
        do {
            let result = try await client.answers(
                status: snapshot.status,
                q: snapshot.query,
                limit: Self.pageSize,
                offset: 0
            )
            guard seq == requestSeq else { return }
            page = .loaded(result)
            more = []
            schedulePollIfNeeded()
        } catch {
            guard seq == requestSeq else { return }
            page = .failed(error.userMessage)
        }
    }

    /// 下拉刷新与轮询：重取当前已展开的全部条数，避免列表塌缩回第一页。
    func refresh() async {
        guard let client = session?.client else { return }
        requestSeq += 1
        let seq = requestSeq
        let snapshot = (status: status, query: query.trimmingCharacters(in: .whitespaces))
        let limit = min(max(Self.pageSize, items.count), Self.refreshCap)
        do {
            let result = try await client.answers(
                status: snapshot.status,
                q: snapshot.query,
                limit: limit,
                offset: 0
            )
            guard seq == requestSeq else { return }
            page = .loaded(result)
            more = []
            schedulePollIfNeeded()
        } catch {
            guard seq == requestSeq else { return }
            // 刷新失败不该抹掉已显示的列表：保留旧内容，下一轮再试。
            if page.value == nil { page = .failed(error.userMessage) }
        }
    }

    /// 滚动到底时追加下一页。
    func loadMore() async {
        guard canLoadMore, let client = session?.client, let first = page.value else { return }
        loadingMore = true
        defer { loadingMore = false }
        let seq = requestSeq
        let snapshot = (status: status, query: query.trimmingCharacters(in: .whitespaces))
        do {
            let result = try await client.answers(
                status: snapshot.status,
                q: snapshot.query,
                limit: Self.pageSize,
                offset: items.count
            )
            guard seq == requestSeq else { return }
            more += result.items
            // 空页说明已到末尾：把 total 收敛到本地条数，避免上游总数与实际条数不一致时反复请求。
            let syncedTotal = result.items.isEmpty ? items.count : result.total
            page = .loaded(Page(items: first.items, total: syncedTotal, limit: first.limit, offset: first.offset))
        } catch {
            guard seq == requestSeq else { return }
            errors?.present(error)
        }
    }

    func setStatus(_ value: AnswerStatus?) {
        status = value
        Task { await load() }
    }

    func cancel(_ item: AnswerSummary) async {
        guard let client = session?.client, let jobID = item.jobId else { return }
        do {
            try await client.cancelJob(id: jobID)
            app?.noteAnswersChanged()
        } catch {
            errors?.present(error)
        }
    }

    func delete(_ item: AnswerSummary) async {
        guard let client = session?.client else { return }
        do {
            try await client.deleteAnswer(id: item.id)
            app?.noteAnswersChanged()
        } catch {
            errors?.present(error)
        }
    }

    private func debounceSearch() {
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled, let self else { return }
            await load()
        }
    }

    /// 列表里还有进行中的任务时每 5 秒刷新一次。
    private func schedulePollIfNeeded() {
        pollTask?.cancel()
        pollTask = nil
        guard items.contains(where: { $0.status.isActive }) else { return }
        pollTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(5))
            guard !Task.isCancelled, let self else { return }
            await refresh()
        }
    }
}
