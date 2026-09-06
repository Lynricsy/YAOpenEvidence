import Foundation
import YAOEKit

@MainActor
@Observable
final class HistoryModel {
    static let pageSize = 20

    var status: AnswerStatus?
    var query = "" {
        didSet {
            guard query != oldValue else { return }
            debounceSearch()
        }
    }

    var page: Loadable<Page<AnswerSummary>> = .idle
    var offset = 0

    private var session: SessionStore?
    private var errors: ErrorPresenter?
    private var searchTask: Task<Void, Never>?
    private var pollTask: Task<Void, Never>?

    /// 离开页面时取消防抖与轮询。
    func teardown() {
        searchTask?.cancel()
        searchTask = nil
        pollTask?.cancel()
        pollTask = nil
    }

    var items: [AnswerSummary] { page.value?.items ?? [] }
    var total: Int { page.value?.total ?? 0 }
    var hasFilter: Bool { status != nil || !query.trimmingCharacters(in: .whitespaces).isEmpty }

    /// 「第 a–b 条，共 N 条」。
    var rangeLabel: String {
        guard total > 0 else { return "共 0 条" }
        let start = offset + 1
        let end = min(offset + items.count, total)
        return "第 \(start)–\(end) 条，共 \(total) 条"
    }

    var canPrevious: Bool { offset > 0 }
    var canNext: Bool { offset + Self.pageSize < total }

    func configure(session: SessionStore, errors: ErrorPresenter) {
        self.session = session
        self.errors = errors
    }

    func load() async {
        guard let client = session?.client else { return }
        if page.value == nil { page = .loading }
        do {
            let result = try await client.answers(
                status: status,
                q: query.trimmingCharacters(in: .whitespaces),
                limit: Self.pageSize,
                offset: offset
            )
            page = .loaded(result)
            schedulePollIfNeeded()
        } catch {
            page = .failed(error.userMessage)
        }
    }

    func setStatus(_ value: AnswerStatus?) {
        status = value
        offset = 0
        Task { await load() }
    }

    func previousPage() {
        guard canPrevious else { return }
        offset = max(0, offset - Self.pageSize)
        Task { await load() }
    }

    func nextPage() {
        guard canNext else { return }
        offset += Self.pageSize
        Task { await load() }
    }

    func cancel(_ item: AnswerSummary) async {
        guard let client = session?.client, let jobID = item.jobId else { return }
        do {
            try await client.cancelJob(id: jobID)
            await load()
        } catch {
            errors?.present(error)
        }
    }

    func delete(_ item: AnswerSummary) async {
        guard let client = session?.client else { return }
        do {
            try await client.deleteAnswer(id: item.id)
            // 删掉本页最后一项时回退一页，避免停在空页。
            if items.count == 1, offset > 0 { offset = max(0, offset - Self.pageSize) }
            await load()
        } catch {
            errors?.present(error)
        }
    }

    private func debounceSearch() {
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled, let self else { return }
            offset = 0
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
            await load()
        }
    }
}
