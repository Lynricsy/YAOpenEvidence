import SwiftUI
import PicoSeekKit

/// 上游检索的筛选条件（年份部分与提问筛选共用取值规则）。
struct LiteratureFilters: Hashable {
    var yearMode: AskFilters.YearMode = .recent
    var years = 3
    var yearFrom: Int?
    var yearTo: Int?
    var quartiles: [Int] = []
    var publicationTypes: [String] = []
    var journals: [String] = []
    var openAccessOnly = false

    static let publicationTypeOptions: [(label: String, value: String)] = [
        ("综述", "Review"),
        ("系统综述", "Systematic Review"),
        ("荟萃分析", "Meta-Analysis"),
        ("随机对照试验", "Randomized Controlled Trial"),
        ("临床试验", "Clinical Trial"),
        ("观察性研究", "Observational Study"),
    ]

    /// 复用 `AskFilters` 的年份校验。
    var yearProbe: AskFilters {
        AskFilters(yearMode: yearMode, years: years, yearFrom: yearFrom, yearTo: yearTo)
    }
}

@MainActor
@Observable
final class LiteratureModel {
    var query = ""
    var source: LiteratureSource = .auto
    var limit = 10
    var filters = LiteratureFilters()
    var result: Loadable<LiteratureSearchResult> = .idle

    private var session: SessionStore?
    private var requestSeq = 0

    static let limitOptions = [10, 20, 30]

    func configure(session: SessionStore) {
        self.session = session
    }

    func search() async {
        guard let client = session?.client else { return }
        let text = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, filters.yearProbe.isYearRangeValid() else { return }
        requestSeq += 1
        let seq = requestSeq
        let snapshot = request(text)
        if result.value == nil { result = .loading }
        do {
            let response = try await client.literatureSearch(snapshot)
            guard seq == requestSeq else { return }
            result = .loaded(response)
        } catch {
            guard seq == requestSeq else { return }
            result = .failed(error.userMessage)
        }
    }

    private func request(_ text: String) -> LiteratureQuery {
        LiteratureQuery(
            q: text,
            source: source,
            limit: limit,
            years: filters.yearMode == .recent ? filters.years : nil,
            yearFrom: filters.yearMode == .range ? filters.yearFrom : nil,
            yearTo: filters.yearMode == .range ? filters.yearTo : nil,
            publicationTypes: filters.publicationTypes,
            quartiles: filters.quartiles,
            journals: filters.journals,
            openAccessOnly: source == .s2 && filters.openAccessOnly
        )
    }
}

struct LiteratureSearchView: View {
    @Environment(SessionStore.self) private var session

    @State private var model = LiteratureModel()
    @State private var showFilters = false
    @State private var fulltextRecord: LiteratureRecord?

    var body: some View {
        @Bindable var model = model
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                filterBar
                if !model.filters.yearProbe.isYearRangeValid() {
                    Text("请填写有效起始年，结束年不得早于起始年。")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                results
            }
            .frame(maxWidth: Metrics.contentMaxWidth)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Metrics.pageInset)
            .padding(.vertical, 16)
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("查文献")
        .pageSearchable(text: $model.query, prompt: "搜索文献")
        .onSubmit(of: .search) { Task { await model.search() } }
        .accountToolbar()
        .task { model.configure(session: session) }
        .sheet(isPresented: $showFilters) {
            LiteratureFilterSheet(filters: $model.filters, source: $model.source, limit: $model.limit)
        }
        .sheet(item: $fulltextRecord) { record in
            NavigationStack {
                FulltextSheet(record: record)
            }
        }
    }

    /// 检索条件收进一个胶囊入口：常用检索只需要搜索框，参数留给筛选表单。
    private var filterBar: some View {
        HStack {
            Button {
                showFilters = true
            } label: {
                Label(filterSummary, systemImage: "line.3.horizontal.decrease")
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
            .controlSize(.small)
            Spacer()
        }
    }

    /// 当前筛选的一句话摘要，只用面向用户的措辞。
    private var filterSummary: String {
        var parts = ["\(model.source.label) · \(model.limit) 条"]
        switch model.filters.yearMode {
        case .recent:
            parts.append("近\(model.filters.years)年")
        case .range:
            if let from = model.filters.yearFrom {
                parts.append("\(from)–\(model.filters.yearTo.map(String.init) ?? "今")")
            }
        case .any:
            break
        }
        if !model.filters.quartiles.isEmpty {
            parts.append(model.filters.quartiles.sorted().map { "Q\($0)" }.joined(separator: "/"))
        }
        return parts.joined(separator: " · ")
    }

    @ViewBuilder
    private var results: some View {
        switch model.result {
        case .idle:
            ContentUnavailableView("输入关键词开始检索", systemImage: "magnifyingglass")
                .padding(.top, 40)
        case .loading:
            ProgressView().frame(maxWidth: .infinity).padding(.vertical, 40)
        case .failed(let message):
            ErrorPanel(message: message, retry: { Task { await model.search() } })
        case .loaded(let result):
            VStack(alignment: .leading, spacing: 12) {
                if result.fallbackReason?.isEmpty == false {
                    Label("Semantic Scholar 暂不可用，已改用 PubMed", systemImage: "exclamationmark.triangle")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
                Text("找到 \(result.total) 条")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if result.items.isEmpty {
                    ContentUnavailableView("没有检索到文献", systemImage: "doc.questionmark")
                } else {
                    ForEach(result.items) { record in
                        LiteratureCard(record: record) { fulltextRecord = record }
                    }
                }
            }
        }
    }
}

struct LiteratureCard: View {
    let record: LiteratureRecord
    let onFulltext: () -> Void

    @State private var showAbstract = false

    private var authorLine: String {
        let names = record.authors.prefix(3).joined(separator: ", ")
        return record.authors.count > 3 ? names + " et al." : names
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(record.title.isEmpty ? "（无标题）" : record.title)
                .font(.subheadline.weight(.medium))

            if !authorLine.isEmpty {
                Text(authorLine)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            if let journal = record.journal, !journal.isEmpty {
                Text("\(journal)\(record.year.map { " (\($0))" } ?? "")")
                    .font(.caption)
                    .italic()
                    .foregroundStyle(.secondary)
            }

            badges

            if record.abstract?.isEmpty == false || record.tldr?.isEmpty == false {
                DisclosureGroup("摘要", isExpanded: $showAbstract) {
                    VStack(alignment: .leading, spacing: 6) {
                        if let tldr = record.tldr, !tldr.isEmpty {
                            Text(tldr)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        if let abstract = record.abstract, !abstract.isEmpty {
                            Text(abstract)
                                .font(.caption)
                                .textSelection(.enabled)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 6)
                }
                .font(.caption)
            }

            HStack(spacing: 12) {
                if let pmid = record.pmid, !pmid.isEmpty, let url = URL(string: "https://pubmed.ncbi.nlm.nih.gov/\(pmid)/") {
                    Link("PubMed", destination: url)
                }
                if let doi = record.doi, !doi.isEmpty, let url = URL(string: "https://doi.org/\(doi)") {
                    Link("DOI", destination: url)
                }
                if let pdf = record.openAccessPdf, let url = URL(string: pdf) {
                    Link("开放获取 PDF", destination: url)
                }
                Spacer()
                if record.fulltextIdent != nil {
                    Button(action: onFulltext) {
                        Label("全文", systemImage: "doc.text")
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .controlSize(.small)
                }
            }
            .font(.caption)
        }
        .card()
    }

    @ViewBuilder
    private var badges: some View {
        FlowLayout {
            if let rank = record.rank {
                RankBadge(quartile: rank.quartile)
                if rank.top { Pill(text: "Top", tone: .accentColor) }
            }
            ForEach(record.types, id: \.self) { type in
                Pill(text: LiteratureFilters.publicationTypeOptions.first { $0.value == type }?.label ?? type)
            }
            if let cited = record.citedBy {
                Pill(text: "被引 \(cited)")
            }
        }
    }
}

/// 高级筛选：年份、分区、文献类型、期刊、开放获取。
struct LiteratureFilterSheet: View {
    @Binding var filters: LiteratureFilters
    @Binding var source: LiteratureSource
    @Binding var limit: Int

    @Environment(\.dismiss) private var dismiss
    @State private var journalDraft = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("来源") {
                    Picker("来源", selection: $source) {
                        ForEach(LiteratureSource.allCases, id: \.self) { item in
                            Text(item.label).tag(item)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("条数") {
                    Picker("条数", selection: $limit) {
                        ForEach(LiteratureModel.limitOptions, id: \.self) { value in
                            Text("\(value) 条").tag(value)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("年份") {
                    Picker("范围", selection: $filters.yearMode) {
                        Text("不限").tag(AskFilters.YearMode.any)
                        Text("近 N 年").tag(AskFilters.YearMode.recent)
                        Text("自定义").tag(AskFilters.YearMode.range)
                    }
                    .pickerStyle(.segmented)

                    switch filters.yearMode {
                    case .recent:
                        Stepper("近 \(filters.years) 年", value: $filters.years, in: 1 ... 50)
                    case .range:
                        HStack {
                            TextField("从", text: yearText(\.yearFrom))
                            Text("–")
                            TextField("至今", text: yearText(\.yearTo))
                        }
                        if !filters.yearProbe.isYearRangeValid() {
                            Text("请填写有效起始年，结束年不得早于起始年。")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    case .any:
                        EmptyView()
                    }
                }

                Section("期刊分区") {
                    FlowLayout {
                        ForEach(1 ... 4, id: \.self) { zone in
                            ChoiceChip(title: "Q\(zone)", selected: filters.quartiles.contains(zone)) {
                                if filters.quartiles.contains(zone) {
                                    filters.quartiles.removeAll { $0 == zone }
                                } else {
                                    filters.quartiles = (filters.quartiles + [zone]).sorted()
                                }
                            }
                        }
                    }
                }

                Section("文献类型") {
                    FlowLayout {
                        ForEach(LiteratureFilters.publicationTypeOptions, id: \.value) { option in
                            ChoiceChip(title: option.label, selected: filters.publicationTypes.contains(option.value)) {
                                if filters.publicationTypes.contains(option.value) {
                                    filters.publicationTypes.removeAll { $0 == option.value }
                                } else {
                                    filters.publicationTypes.append(option.value)
                                }
                            }
                        }
                    }
                }

                Section("期刊") {
                    HStack {
                        TextField("期刊关键词", text: $journalDraft)
                            .onSubmit(addJournal)
                        Button("添加", action: addJournal)
                            .disabled(journalDraft.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    ForEach(filters.journals, id: \.self) { journal in
                        Button {
                            filters.journals.removeAll { $0 == journal }
                        } label: {
                            Label(journal, systemImage: "xmark.circle.fill")
                        }
                    }
                }

                Section {
                    Toggle("仅开放获取", isOn: $filters.openAccessOnly)
                        .disabled(source != .s2)
                } footer: {
                    Text("仅 Semantic Scholar 支持")
                }

                Section {
                    Button("恢复默认") { filters = LiteratureFilters() }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("高级筛选")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }

    private func yearText(_ keyPath: WritableKeyPath<LiteratureFilters, Int?>) -> Binding<String> {
        Binding {
            filters[keyPath: keyPath].map(String.init) ?? ""
        } set: { text in
            let digits = text.filter(\.isNumber)
            filters[keyPath: keyPath] = digits.isEmpty ? nil : Int(digits)
        }
    }

    private func addJournal() {
        let value = journalDraft.trimmingCharacters(in: .whitespaces).lowercased()
        guard !value.isEmpty, value.count <= 100, !filters.journals.contains(value) else {
            journalDraft = ""
            return
        }
        filters.journals.append(value)
        journalDraft = ""
    }
}
