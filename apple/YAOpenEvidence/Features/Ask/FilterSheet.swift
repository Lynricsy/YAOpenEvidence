import SwiftUI
import YAOEKit

/// 检索筛选表单。关闭即生效（`app.filters` 的 didSet 会持久化）。
struct FilterSheet: View {
    @Environment(AppModel.self) private var app
    @Environment(\.dismiss) private var dismiss

    @State private var journalDraft = ""

    private enum YearChoice: Hashable {
        case any
        case recent(Int)
        case custom
    }

    var body: some View {
        @Bindable var app = app
        NavigationStack {
            Form {
                yearSection(app: app)
                quartileSection(app: app)
                journalSection(app: app)

                Section("阅读篇数") {
                    Slider(
                        value: Binding(get: { Double(app.filters.papers) }, set: { app.filters.papers = Int($0) }),
                        in: 1 ... 30,
                        step: 1
                    ) {
                        Text("阅读篇数")
                    }
                    LabeledContent("阅读篇数", value: "\(app.filters.papers) 篇")
                }

                Section("知识库") {
                    Toggle("写入并使用知识库", isOn: $app.filters.useKb)
                    Slider(
                        value: Binding(get: { Double(app.filters.kbHits) }, set: { app.filters.kbHits = Int($0) }),
                        in: 0 ... 20,
                        step: 1
                    ) {
                        Text("附加知识库条目")
                    }
                    .disabled(!app.filters.useKb)
                    LabeledContent("附加知识库条目", value: "\(app.filters.kbHits) 条")
                        .foregroundStyle(app.filters.useKb ? .primary : .secondary)
                }

                Section {
                    Picker("单篇字符预算", selection: $app.filters.maxChars) {
                        ForEach(AskFilters.maxCharsOptions, id: \.self) { value in
                            Text("约 \(value.formatted()) 字").tag(value)
                        }
                    }
                } header: {
                    Text("单篇字符预算")
                } footer: {
                    Text("每篇文献送入阅读的最大长度，越大越完整但越慢。")
                }

                Section {
                    Button("恢复默认") { app.filters = .default }
                }
            }
            .formStyle(.grouped)
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("检索筛选")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - 年份

    @ViewBuilder
    private func yearSection(app: AppModel) -> some View {
        @Bindable var app = app
        Section("年份") {
            Picker("年份范围", selection: yearChoice(app: app)) {
                Text("不限").tag(YearChoice.any)
                Text("近3年").tag(YearChoice.recent(3))
                Text("近5年").tag(YearChoice.recent(5))
                Text("近10年").tag(YearChoice.recent(10))
                Text("自定义").tag(YearChoice.custom)
            }
            .pickerStyle(.segmented)

            if app.filters.yearMode == .range {
                HStack {
                    TextField("从", text: yearText(\.yearFrom, app: app))
                        #if os(iOS)
                            .keyboardType(.numberPad)
                        #endif
                    Text("–")
                    TextField("至今", text: yearText(\.yearTo, app: app))
                        #if os(iOS)
                            .keyboardType(.numberPad)
                        #endif
                }
                if !app.filters.isYearRangeValid() {
                    Text("请填写有效起始年，结束年不得早于起始年。")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
        }
    }

    private func yearChoice(app: AppModel) -> Binding<YearChoice> {
        Binding {
            switch app.filters.yearMode {
            case .any: .any
            case .recent: [3, 5, 10].contains(app.filters.years) ? .recent(app.filters.years) : .custom
            case .range: .custom
            }
        } set: { choice in
            switch choice {
            case .any:
                app.filters.yearMode = .any
            case .recent(let years):
                app.filters.yearMode = .recent
                app.filters.years = years
            case .custom:
                app.filters.yearMode = .range
            }
        }
    }

    private func yearText(_ keyPath: WritableKeyPath<AskFilters, Int?>, app: AppModel) -> Binding<String> {
        Binding {
            app.filters[keyPath: keyPath].map(String.init) ?? ""
        } set: { text in
            let digits = text.filter(\.isNumber)
            app.filters[keyPath: keyPath] = digits.isEmpty ? nil : Int(digits)
        }
    }

    // MARK: - 分区

    @ViewBuilder
    private func quartileSection(app: AppModel) -> some View {
        @Bindable var app = app
        Section("期刊分区") {
            FlowLayout {
                ForEach(1 ... 4, id: \.self) { zone in
                    let selected = app.filters.quartiles.contains(zone)
                    ChoiceChip(title: "Q\(zone)", selected: selected) {
                        if selected {
                            app.filters.quartiles.removeAll { $0 == zone }
                        } else {
                            app.filters.quartiles = (app.filters.quartiles + [zone]).sorted()
                        }
                        if app.filters.quartiles.isEmpty { app.filters.keepUnranked = false }
                    }
                }
            }
            Toggle("含未收录期刊", isOn: $app.filters.keepUnranked)
                .disabled(app.filters.quartiles.isEmpty)
        }
    }

    // MARK: - 期刊

    @ViewBuilder
    private func journalSection(app: AppModel) -> some View {
        Section("期刊") {
            FlowLayout {
                ForEach(AskFilters.journalPresets, id: \.value) { preset in
                    ChoiceChip(title: preset.label, selected: app.filters.journals.contains(preset.value)) {
                        toggleJournal(preset.value, app: app)
                    }
                }
            }

            HStack {
                TextField("自定义期刊关键词", text: $journalDraft)
                    .autocorrectionDisabled()
                    .onSubmit { addJournal(app: app) }
                Button("添加") { addJournal(app: app) }
                    .disabled(journalDraft.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            if !app.filters.journals.isEmpty {
                // 已选期刊一律是选中态，点一下即移除。
                FlowLayout {
                    ForEach(app.filters.journals, id: \.self) { journal in
                        ChoiceChip(title: journal, selected: true) {
                            toggleJournal(journal, app: app)
                        }
                    }
                }
            }
        }
    }

    /// 只处理期刊列表本身：整表 `normalized()` 会把用户正在编辑、尚未通过校验的年份悄悄改掉。
    private func toggleJournal(_ value: String, app: AppModel) {
        let journal = value.trimmingCharacters(in: .whitespaces).lowercased()
        guard !journal.isEmpty, journal.count <= 100 else { return }
        if app.filters.journals.contains(journal) {
            app.filters.journals.removeAll { $0 == journal }
        } else {
            app.filters.journals.append(journal)
        }
    }

    private func addJournal(app: AppModel) {
        toggleJournalIfAbsent(journalDraft, app: app)
        journalDraft = ""
    }

    private func toggleJournalIfAbsent(_ value: String, app: AppModel) {
        let journal = value.trimmingCharacters(in: .whitespaces).lowercased()
        guard !journal.isEmpty, journal.count <= 100, !app.filters.journals.contains(journal) else { return }
        app.filters.journals.append(journal)
    }
}
