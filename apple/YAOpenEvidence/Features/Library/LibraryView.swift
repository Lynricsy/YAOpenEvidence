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
    var offset = 0

    private var session: SessionStore?
    private var searchTask: Task<Void, Never>?

    var items: [PaperMeta] { page.value?.items ?? [] }
    var total: Int { page.value?.total ?? 0 }
    var hasQuery: Bool { !query.trimmingCharacters(in: .whitespaces).isEmpty }
    var canPrevious: Bool { offset > 0 }
    var canNext: Bool { offset + Self.pageSize < total }

    var rangeLabel: String {
        guard total > 0 else { return "共 0 条" }
        return "第 \(offset + 1)–\(min(offset + items.count, total)) 条，共 \(total) 条"
    }

    func configure(session: SessionStore) {
        self.session = session
    }

    func teardown() {
        searchTask?.cancel()
        searchTask = nil
    }

    func load() async {
        guard let client = session?.client else { return }
        if page.value == nil { page = .loading }
        do {
            page = .loaded(try await client.papers(
                q: query.trimmingCharacters(in: .whitespaces),
                limit: Self.pageSize,
                offset: offset
            ))
        } catch {
            page = .failed(error.userMessage)
        }
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

    private func debounceSearch() {
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled, let self else { return }
            offset = 0
            await load()
        }
    }
}

struct LibraryView: View {
    @Environment(SessionStore.self) private var session
    @Environment(AppModel.self) private var app

    @State private var model = LibraryModel()

    var body: some View {
        @Bindable var model = model
        List {
            ForEach(model.items) { paper in
                Button {
                    app.libraryPath.append(PaperRoute(key: paper.key, pid: nil))
                } label: {
                    PaperRow(paper: paper)
                }
                .buttonStyle(.plain)
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
            if model.items.isEmpty, !model.page.isLoading {
                ContentUnavailableView(
                    model.hasQuery ? "未找到文献" : "文献库为空",
                    systemImage: "books.vertical"
                )
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
            Text(paper.title.isEmpty ? paper.key : paper.title)
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

            ViewThatFits(in: .horizontal) {
                badges
                VStack(alignment: .leading, spacing: 6) { badges }
            }

            HStack(spacing: 8) {
                Text("\(paper.nParagraphs) 段 / \(paper.nFacts) 条事实")
                if let indexedAt = paper.indexedAt {
                    Text("入库于 \(indexedAt.formatted(.dateTime.year().month().day().hour().minute()))")
                }
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
        .contentShape(.rect)
    }

    @ViewBuilder
    private var badges: some View {
        HStack(spacing: 6) {
            RankBadge(quartile: paper.quartile)
            ForEach(paper.types.prefix(3), id: \.self) { type in
                Pill(text: type)
            }
        }
    }
}
