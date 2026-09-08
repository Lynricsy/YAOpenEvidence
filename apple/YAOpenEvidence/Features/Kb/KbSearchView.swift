import SwiftUI
import YAOEKit

@MainActor
@Observable
final class KbModel {
    var stats: Loadable<KbStats> = .idle
    var results: Loadable<KbSearchResult> = .idle
    var query = ""
    var kind: KbKind?
    let topK = 8

    var reindexJob: Job?
    var reindexMonitor: JobLiveMonitor?
    var reindexPending = false

    private var session: SessionStore?
    private var errors: ErrorPresenter?
    private var pollTask: Task<Void, Never>?
    private var requestSeq = 0

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
        guard let client = session?.client else { return }
        reindexPending = true
        defer { reindexPending = false }
        do {
            let job = try await client.reindexKb()
            await noteJobFinished(job)
            let monitor = JobLiveMonitor(jobID: job.id, client: client) { [weak self] live, _ in
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
            VStack(alignment: .leading, spacing: Metrics.sectionSpacing) {
                libraryCard
                resultList
            }
            .frame(maxWidth: Metrics.contentMaxWidth)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Metrics.pageInset)
            .padding(.vertical, 20)
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("知识库")
        .pageSearchable(text: $model.query, prompt: "搜索知识库")
        .searchScopes($model.kind) {
            Text("全部").tag(KbKind?.none)
            ForEach(KbKind.allCases, id: \.self) { kind in
                Text(kind.label).tag(KbKind?.some(kind))
            }
        }
        .onSubmit(of: .search) { Task { await model.search() } }
        .accountToolbar()
        // 切换范围只在已有查询词时重检索，避免空查询触发一次无效请求。
        .onChange(of: model.kind) {
            guard !model.query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
            Task { await model.search() }
        }
        .refreshable { await model.loadStats() }
        .task {
            model.configure(session: session, errors: errors)
            model.resume()
            await model.loadStats()
        }
        .onDisappear { model.teardown() }
    }

    // MARK: - 知识库概览（统计 + 重建索引合为一张卡）

    /// 面向 kind 的构成项：标签、数量、色标。
    private struct KindSlice: Identifiable {
        let label: String
        let value: Int
        let tone: Color
        var id: String { label }
    }

    private func slices(_ byKind: [String: Int]) -> [KindSlice] {
        byKind
            // 后端可能返回尚无中文文案的 kind，跳过它们而不是把原始标识抛给用户。
            .compactMap { key, value -> KindSlice? in
                guard let label = KbLabels.kindLabel(key), value > 0 else { return nil }
                return KindSlice(label: label, value: value, tone: KbLabels.kindTone(key))
            }
            .sorted { ($0.value, $1.label) > ($1.value, $0.label) }
    }

    @ViewBuilder
    private var libraryCard: some View {
        LoadableView(state: model.stats, retry: { Task { await model.loadStats() } }) { stats in
            let kinds = slices(stats.byKind)
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(stats.items.formatted())
                        .font(.system(size: 34, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .contentTransition(.numericText())
                    Text("条知识")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer(minLength: 8)
                    Label("\(stats.papers.formatted()) 篇文献", systemImage: "text.book.closed")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }

                if !kinds.isEmpty {
                    composition(kinds)
                }

                if session.isAdmin {
                    Divider()
                    reindexRow
                }
            }
            .card(padding: 18)
            .sensoryFeedback(.success, trigger: model.reindexJob?.status == .succeeded)
        }
    }

    /// 构成条：按 kind 数量占比分段，比四个并排数字更能看出知识库的组成。
    private func composition(_ kinds: [KindSlice]) -> some View {
        let total = max(1, kinds.reduce(0) { $0 + $1.value })
        return VStack(alignment: .leading, spacing: 8) {
            GeometryReader { proxy in
                HStack(spacing: 2) {
                    ForEach(kinds) { slice in
                        Capsule()
                            .fill(slice.tone)
                            .frame(width: max(4, proxy.size.width * CGFloat(slice.value) / CGFloat(total)))
                    }
                }
            }
            .frame(height: 6)

            FlowLayout(spacing: 14, lineSpacing: 6) {
                ForEach(kinds) { slice in
                    HStack(spacing: 5) {
                        Circle()
                            .fill(slice.tone)
                            .frame(width: 7, height: 7)
                        Text(slice.label)
                            .foregroundStyle(.secondary)
                        Text(slice.value.formatted())
                            .fontWeight(.medium)
                            .monospacedDigit()
                            .contentTransition(.numericText())
                    }
                    .font(.caption)
                }
            }
        }
    }

    @ViewBuilder
    private var reindexRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("重建索引").font(.subheadline.weight(.semibold))
                    Text("重新计算全部条目的向量索引，期间检索仍可用。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 12)
                Button(model.reindexPending ? "提交中…" : "重建") { Task { await model.reindex() } }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .controlSize(.small)
                    .disabled(model.reindexPending || model.reindexJob?.status.isActive == true)
            }

            if let job = model.reindexJob {
                HStack(spacing: 8) {
                    StatusBadge(job.status)
                    if let progress = job.progress, let current = progress.current, let total = progress.total, total > 0 {
                        ProgressView(value: Double(current), total: Double(total))
                            .frame(maxWidth: 200)
                    }
                }
                if job.status == .succeeded, let result = model.reindexResult {
                    Text("重建完成，共 \(result.items) 条知识、\(result.papers) 篇文献")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
                if let error = job.error {
                    Label(JobErrorMessage.text(for: error.code), systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
        }
    }

    // MARK: - 检索

    @ViewBuilder
    private var resultList: some View {
        switch model.results {
        case .idle:
            EmptyView()
        case .loading:
            ProgressView("正在检索知识库…")
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

enum KbLabels {
    /// 知识库条目类型文案（含事实 kind）。未知类型返回 nil——后端原始标识不面向用户。
    static func kindLabel(_ key: String) -> String? {
        switch key {
        case "fact": "事实"
        case "paragraph": "段落"
        case "finding": "发现"
        case "method": "方法"
        case "limitation": "局限"
        case "background": "背景"
        default: nil
        }
    }

    /// 构成条与图例的色标。占比最大的「段落」用品牌强调色，其余取彼此可辨的冷色；
    /// 刻意不用橙/红——那两色在本 App 里表示告警状态。
    static func kindTone(_ key: String) -> Color {
        switch key {
        case "paragraph": .accentColor
        case "fact": .indigo
        case "finding": .green
        case "method": .cyan
        case "limitation": .pink
        case "background": .purple
        default: .secondary
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
                Pill(text: KbLabels.kindLabel(hit.factKind ?? hit.kind.rawValue) ?? "条目", tone: .accentColor)
                if let verified = hit.verified { VerifiedPill(verified: verified) }
                Spacer()
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
                    .quoteBar()
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
                    Button { onOpenSource(route) } label: {
                        Label("查看原文", systemImage: "chevron.right")
                    }
                    .font(.caption.weight(.medium))
                    .buttonStyle(.plain)
                    .foregroundStyle(Color.accentColor)
                }
            }
        }
        .card()
    }

    private var locationText: String {
        var parts: [String] = []
        if let sec = hit.sec, !sec.isEmpty { parts.append(sec) }
        if let page = hit.page { parts.append("第 \(page) 页") }
        return parts.joined(separator: " · ")
    }
}
