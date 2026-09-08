import Foundation
import YAOEKit

/// 阅读器目标：第 n 篇文献，可选定位段落。
struct ReaderTarget: Identifiable, Hashable {
    var n: Int
    var pid: Int?

    var id: String { "\(n)#\(pid ?? 0)" }
}

@MainActor
@Observable
final class AnswerScreenModel {
    let answerID: String

    var answer: Loadable<Answer> = .idle
    /// 旧版导入答案没有 `body_md`，回落到渲染稿。
    var legacyMarkdown: String?
    var reader: ReaderTarget?
    var monitor: JobLiveMonitor?
    var cancelRequested = false
    var deleting = false

    private var session: SessionStore?
    private var app: AppModel?
    private var errors: ErrorPresenter?
    private var pollTask: Task<Void, Never>?
    /// answer GET 的请求序号：多个刷新在途时只采用最新一次的结果。
    private var fetchSeq = 0

    init(answerID: String) {
        self.answerID = answerID
    }

    /// 离开页面时停止事件流与轮询。
    func teardown() {
        monitor?.stop()
        pollTask?.cancel()
        pollTask = nil
    }

    var current: Answer? { answer.value }

    /// 正文块：优先 `body_md`（带引用标记），否则用渲染稿。
    var blocks: [MarkdownBlock] {
        if let body = current?.bodyMd, !body.isEmpty {
            return MarkdownDocument.parse(body, citationLimit: current?.papers.count ?? 0)
        }
        if let legacyMarkdown {
            return MarkdownDocument.parse(legacyMarkdown, citationLimit: nil)
        }
        return []
    }

    func configure(session: SessionStore, app: AppModel, errors: ErrorPresenter) {
        self.session = session
        self.app = app
        self.errors = errors
    }

    // MARK: - 加载

    func load() async {
        guard let client = session?.client else { return }
        await fetch(showLoading: answer.value == nil)
        startMonitorIfNeeded(client: client)
        startPollingIfNeeded()
    }

    func reload() async {
        await fetch(showLoading: false)
    }

    /// 唯一的 answer 读取入口。序号守卫保证旧的在途结果不会覆盖新结果
    /// （每个 stage 事件都会触发刷新，running 的旧响应可能晚于终态响应到达）。
    private func fetch(showLoading: Bool) async {
        guard let client = session?.client else { return }
        if showLoading { answer = .loading }
        fetchSeq += 1
        let seq = fetchSeq
        do {
            let loaded = try await client.answer(id: answerID)
            guard seq == fetchSeq else { return }
            apply(loaded)
        } catch {
            // 已有内容时保留旧状态，交给轮询继续重试；只有首屏失败才显示错误页。
            if answer.value == nil { answer = .failed(error.userMessage) }
        }
    }

    private func apply(_ loaded: Answer) {
        answer = .loaded(loaded)
        if loaded.status == .ready, loaded.bodyMd == nil || loaded.bodyMd?.isEmpty == true {
            Task { await loadLegacyMarkdown() }
        }
        // 只有确认答案已进入终态才停轮询：终态刷新失败时轮询是唯一兜底。
        if !loaded.status.isActive {
            pollTask?.cancel()
            pollTask = nil
        }
    }

    private func loadLegacyMarkdown() async {
        guard legacyMarkdown == nil, let client = session?.client else { return }
        legacyMarkdown = try? await client.answerMarkdown(id: answerID)
    }

    /// 首次进入创建监视器；从其他 Tab 回到本页时续订同一个监视器（保留已收到的阶段与日志位置）。
    private func startMonitorIfNeeded(client: APIClient) {
        guard let answer = current, answer.status.isActive, let jobID = answer.jobId else { return }
        if monitor == nil {
            monitor = JobLiveMonitor(jobID: jobID, client: client) { [weak self] live, event in
                self?.handle(live: live, event: event)
            }
        }
        guard let monitor, !monitor.isRunning else { return }
        monitor.start()
    }

    /// SSE 断开时兜底轮询；连接正常就不打扰后端。
    private func startPollingIfNeeded() {
        guard pollTask == nil, current?.status.isActive == true else { return }
        pollTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(5))
                guard let self, current?.status.isActive == true else { return }
                if monitor?.connection != .open { await reload() }
            }
        }
    }

    private func handle(live: JobLive, event: SSEEvent) {
        if event.event == "stage" || live.terminal != nil {
            Task { await reload() }
        }
        if live.terminal != nil {
            app?.noteAnswersChanged()
            monitor?.stop()
        }
    }

    // MARK: - 操作

    func cancel() async {
        guard let client = session?.client, let jobID = current?.jobId else { return }
        cancelRequested = true
        do {
            try await client.cancelJob(id: jobID)
        } catch {
            cancelRequested = false
            errors?.present(error)
            return
        }
        await reload()
    }

    func delete() async -> Bool {
        guard let client = session?.client else { return false }
        deleting = true
        defer { deleting = false }
        do {
            try await client.deleteAnswer(id: answerID)
            app?.noteAnswersChanged()
            return true
        } catch {
            errors?.present(error)
            return false
        }
    }

    func openReader(_ ref: CitationRef) {
        reader = ReaderTarget(n: ref.n, pid: ref.pid)
    }

    /// 某一处引用对应的原文引文片段（用于阅读器里高亮）。
    func quotes(n: Int, pid: Int?) -> [String] {
        guard let pid, let answer = current else { return [] }
        var seen = Set<String>()
        return answer.citations
            .filter { $0.n == n && $0.pid == pid }
            .flatMap(\.quotes)
            .filter { seen.insert($0).inserted }
    }
}
