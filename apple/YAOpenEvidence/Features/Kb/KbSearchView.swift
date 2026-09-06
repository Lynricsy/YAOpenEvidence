import SwiftUI
import YAOEKit

@MainActor
@Observable
final class KbModel {
    var stats: Loadable<KbStats> = .idle
    var results: Loadable<KbSearchResult> = .idle
    var query = ""
    var kind: KbKind?
    var topK = 8

    var reindexJob: Job?
    var reindexMonitor: JobLiveMonitor?
    var reindexPending = false

    private var session: SessionStore?
    private var errors: ErrorPresenter?
    private var pollTask: Task<Void, Never>?
    private var requestSeq = 0

    static let topKOptions = [5, 8, 15, 30]

    func configure(session: SessionStore, errors: ErrorPresenter) {
        self.session = session
        self.errors = errors
    }

    func teardown() {
        requestSeq += 1
        reindexMonitor?.stop()
        pollTask?.cancel()
        pollTask = nil
    }

    /// 回到页面时续订重建任务的事件流与兜底轮询；任务已终态则什么都不做。
    func resume() {
        guard let job = reindexJob, job.status.isActive else { return }
        if let monitor = reindexMonitor, !monitor.isRunning { monitor.start() }
        startPolling()
    }

    func loadStats() async {
        guard let client = session?.client else { return }
        if stats.value == nil { stats = .loading }
        do {
            stats = .loaded(try await client.kbStats())
        } catch {
            stats = .failed(error.userMessage)
        }
    }

    func search() async {
        guard let client = session?.client else { return }
        let text = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        requestSeq += 1
        let seq = requestSeq
        let snapshot = (q: text, kind: kind, topK: topK)
        if results.value == nil { results = .loading }
        do {
            let result = try await client.kbSearch(q: snapshot.q, kind: snapshot.kind, topK: snapshot.topK)
            guard seq == requestSeq else { return }
            results = .loaded(result)
        } catch {
            guard seq == requestSeq else { return }
            results = .failed(error.userMessage)
        }
    }

    // MARK: - 重建索引（管理员）

    func reindex() async {
        guard !reindexPending, reindexJob?.status.isActive != true else { return }
        guard let client = session?.client, let session else { return }
        reindexPending = true
        defer { reindexPending = false }
        do {
            let job = try await client.reindexKb()
            await noteJobFinished(job)
            let monitor = JobLiveMonitor(jobID: job.id, client: client, session: session) { [weak self] live, _ in
                guard let self, live.terminal != nil else { return }
                Task { await self.refreshJob() }
            }
            reindexMonitor = monitor
            if job.status.isActive {
                monitor.start()
                startPolling()
            }
        } catch {
            errors?.present(error)
        }
    }

    /// SSE 之外每 5 秒兜底刷新任务状态。
    private func startPolling() {
        pollTask?.cancel()
        pollTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(5))
                guard let self, let job = reindexJob, job.status.isActive else { return }
                await refreshJob()
            }
        }
    }

    private func refreshJob() async {
        guard let client = session?.client, let id = reindexJob?.id else { return }
        guard let job = try? await client.job(id: id) else { return }
        guard reindexJob?.id == id, reindexJob?.status.isActive == true else { return }
        await noteJobFinished(job)
    }

    private func noteJobFinished(_ job: Job) async {
        let firstSuccess = job.status == .succeeded &&
            (reindexJob?.id != job.id || reindexJob?.status != .succeeded)
        reindexJob = job
        if !job.status.isActive {
            reindexMonitor?.stop()
            if firstSuccess { await loadStats() }
            guard reindexJob?.id == job.id else { return }
            pollTask?.cancel()
            pollTask = nil
        }
    }

    /// 成功文案里的条目数与论文数：优先取 SSE 事件，回落到任务结果。
    var reindexResult: (items: Int, papers: Int)? {
        if case .succeeded(_, let items, let papers) = reindexMonitor?.live.terminal, let items, let papers {
            return (items, papers)
        }
        if let result = reindexJob?.result, let items = result["items"]?.intValue, let papers = result["papers"]?.intValue {
            return (items, papers)
        }
        return nil
    }
}

struct KbSearchView: View {
    @Environment(SessionStore.self) private var session
    @Environment(AppModel.self) private var app
    @Environment(ErrorPresenter.self) private var errors

    @State private var model = KbModel()

    var body: some View {
        @Bindable var model = model
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                statsCard
                if session.isAdmin { reindexCard }
                searchForm
                resultList
            }
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .navigationTitle("知识库")
        .accountToolbar()
        .refreshable { await model.loadStats() }
        .task {
            model.configure(session: session, errors: errors)
            model.resume()
            await model.loadStats()
        }
        .onDisappear { model.teardown() }
    }

    // MARK: - 统计

    @ViewBuilder
    private var statsCard: some View {
        LoadableView(state: model.stats, retry: { Task { await model.loadStats() } }) { stats in
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 16) {
                    StatBlock(title: "条目", value: stats.items)
                    StatBlock(title: "论文", value: stats.papers)
                    ForEach(stats.byKind.keys.sorted(), id: \.self) { key in
                        StatBlock(title: KbLabels.kindLabel(key), value: stats.byKind[key] ?? 0)
                    }
                }
                Text("嵌入模型：\(stats.embedder ?? "未加载") · 维度：\(stats.dim.map(String.init) ?? "未知")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.quaternary.opacity(0.25), in: .rect(cornerRadius: 14))
        }
    }

    // MARK: - 重建索引

    @ViewBuilder
    private var reindexCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("索引维护").font(.headline)
                Spacer()
                Button(model.reindexPending ? "提交中…" : "重建索引") { Task { await model.reindex() } }
                    .buttonStyle(.bordered)
                    .disabled(model.reindexPending || model.reindexJob?.status.isActive == true)
            }

            if let job = model.reindexJob {
                HStack(spacing: 8) {
                    StatusBadge(job.status)
                    if let progress = job.progress, let current = progress.current, let total = progress.total, total > 0 {
                        ProgressView(value: Double(current), total: Double(total))
                            .frame(maxWidth: 200)
                        Text("\(current)/\(total)")
                            .font(.caption)
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    }
                }
                if job.status == .succeeded, let result = model.reindexResult {
                    Text("索引已更新 · \(result.items) 条条目 · \(result.papers) 篇论文")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
                if let error = job.error {
                    ErrorPanel(message: JobErrorMessage.text(for: error.code), detail: error.message)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary.opacity(0.25), in: .rect(cornerRadius: 14))
    }

    // MARK: - 检索

    private var searchForm: some View {
        @Bindable var model = model
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                TextField("检索问题", text: $model.query)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { Task { await model.search() } }
                Button("检索") { Task { await model.search() } }
                    .buttonStyle(.borderedProminent)
                    .disabled(model.query.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            HStack {
                Picker("类型", selection: $model.kind) {
                    Text("全部").tag(KbKind?.none)
                    ForEach(KbKind.allCases, id: \.self) { kind in
                        Text(kind.label).tag(KbKind?.some(kind))
                    }
                }
                .pickerStyle(.segmented)

                Picker("返回条数", selection: $model.topK) {
                    ForEach(KbModel.topKOptions, id: \.self) { value in
                        Text("\(value)").tag(value)
                    }
                }
                .pickerStyle(.menu)
            }
        }
    }

    @ViewBuilder
    private var resultList: some View {
        switch model.results {
        case .idle:
            EmptyView()
        case .loading:
            VStack(spacing: 8) {
                ProgressView()
                Text("首次检索需要加载嵌入模型，约 15 秒…")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
        case .failed(let message):
            ErrorPanel(message: message, retry: { Task { await model.search() } })
        case .loaded(let result):
            if result.items.isEmpty {
                ContentUnavailableView("未找到相关条目", systemImage: "magnifyingglass")
            } else {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(result.items.enumerated()), id: \.offset) { _, hit in
                        KbHitCard(hit: hit) { route in
                            app.kbPath.append(route)
                        }
                    }
                }
            }
        }
    }
}

private struct StatBlock: View {
    let title: String
    let value: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(value)")
                .font(.title3.monospacedDigit().weight(.semibold))
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

enum KbLabels {
    /// 知识库条目类型文案（含事实 kind）。
    static func kindLabel(_ key: String) -> String {
        switch key {
        case "fact": "事实"
        case "paragraph": "段落"
        case "finding": "发现"
        case "method": "方法"
        case "limitation": "局限"
        case "background": "背景"
        default: key
        }
    }
}

struct KbHitCard: View {
    let hit: KbHit
    let onOpenSource: (PaperRoute) -> Void

    /// 只有 pmid 形如文献库 key 且有段落号时才能跳转原文。
    private var sourceRoute: PaperRoute? {
        guard let pid = hit.pid, pid > 0,
              hit.pmid.range(of: #"^[A-Za-z0-9._-]{1,80}$"#, options: .regularExpression) != nil
        else { return nil }
        return PaperRoute(key: hit.pmid, pid: pid)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Pill(text: KbLabels.kindLabel(hit.factKind ?? hit.kind.rawValue), tone: .accentColor)
                if let verified = hit.verified { VerifiedPill(verified: verified) }
                Spacer()
                Text("相似度 \(String(format: "%.3f", hit.score))")
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            Text(hit.text)
                .font(.callout)
                .textSelection(.enabled)
            if let zh = hit.textZh, !zh.isEmpty {
                Text(zh)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            if let quote = hit.quote, !quote.isEmpty {
                Text(quote)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 10)
                    .overlay(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 1.5).fill(.tertiary).frame(width: 3)
                    }
            }

            Text(hit.title.isEmpty ? hit.pmid : hit.title)
                .font(.subheadline.weight(.medium))
                .lineLimit(2)
            HStack(spacing: 6) {
                if !hit.journal.isEmpty { Text(hit.journal).italic() }
                if !hit.year.isEmpty { Text(hit.year) }
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            HStack(spacing: 6) {
                RankBadge(quartile: hit.quartile)
                Text(locationText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                if !hit.pmid.isEmpty, let url = URL(string: "https://pubmed.ncbi.nlm.nih.gov/\(hit.pmid)/") {
                    Link("PubMed", destination: url).font(.caption)
                }
                if let route = sourceRoute {
                    Button("查看原文段落") { onOpenSource(route) }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary.opacity(0.2), in: .rect(cornerRadius: 12))
    }

    private var locationText: String {
        var parts: [String] = []
        if let sec = hit.sec, !sec.isEmpty { parts.append(sec) }
        if let pid = hit.pid { parts.append("¶\(pid)") }
        if let page = hit.page { parts.append("第 \(page) 页") }
        return parts.joined(separator: " · ")
    }
}
