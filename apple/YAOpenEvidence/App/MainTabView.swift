import SwiftUI
import YAOEKit

/// 壳层导航：compact 是底部 5 个 Tab；regular 由 `.sidebarAdaptable` 变成侧栏，并追加最近问答与管理分组。
struct MainTabView: View {
    @Environment(SessionStore.self) private var session
    @Environment(AppModel.self) private var app
    @Environment(ErrorPresenter.self) private var errors
    #if os(iOS)
        @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    @State private var recent: [AnswerSummary] = []

    private var isRegular: Bool {
        #if os(iOS)
            horizontalSizeClass == .regular
        #else
            true
        #endif
    }

    var body: some View {
        @Bindable var app = app
        TabView(selection: $app.selection) {
            Tab("提问", systemImage: "text.bubble", value: Destination.ask) {
                NavigationStack(path: $app.askPath) {
                    AskHomeView()
                        .navigationDestination(for: AskRoute.self) { route in
                            if case .answer(let id) = route { AnswerScreen(answerID: id) }
                        }
                }
            }
            Tab("历史", systemImage: "clock", value: Destination.history) {
                NavigationStack(path: $app.historyPath) {
                    HistoryView()
                        .navigationDestination(for: AskRoute.self) { route in
                            if case .answer(let id) = route { AnswerScreen(answerID: id) }
                        }
                }
            }
            Tab("文献库", systemImage: "books.vertical", value: Destination.library) {
                NavigationStack(path: $app.libraryPath) {
                    LibraryView()
                        .navigationDestination(for: PaperRoute.self) { route in
                            PaperDetailView(route: route)
                        }
                }
            }
            Tab("知识库", systemImage: "brain", value: Destination.kb) {
                NavigationStack(path: $app.kbPath) {
                    KbSearchView()
                        .navigationDestination(for: PaperRoute.self) { route in
                            PaperDetailView(route: route)
                        }
                }
            }
            // 刻意不用 role: .search：iOS 26 会把 Tab 栏本身变成搜索入口，
            // 页面导航栏就不再显示 `LiteratureSearchView` 的 `.searchable` 搜索框。
            Tab("查文献", systemImage: "magnifyingglass", value: Destination.literature) {
                NavigationStack { LiteratureSearchView() }
            }

            if isRegular, !recent.isEmpty {
                TabSection("最近问答") {
                    ForEach(recent) { item in
                        Tab(value: Destination.answer(item.id)) {
                            NavigationStack { AnswerScreen(answerID: item.id) }
                        } label: {
                            Label(item.question, systemImage: StatusBadge.symbol(for: item.status))
                        }
                    }
                }
            }

            if isRegular, session.isAdmin {
                TabSection("管理") {
                    Tab("用户", systemImage: "person.2", value: Destination.users) {
                        NavigationStack { UsersView() }
                    }
                }
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        // 滚动时收起底部 Tab 栏，把屏幕交还给内容（iOS 26）。
        #if os(iOS)
            .tabBarMinimizeBehavior(.onScrollDown)
        #endif
        // 侧栏（iPad regular 与 Mac）顶部的品牌标识；compact 的底部 Tab 栏没有这块区域，
        // 手机上的品牌标识由提问首页承载。
        .tabViewSidebarHeader {
            HStack(spacing: 8) {
                BrandLogo(size: 22)
                Text("YAOpenEvidence")
                    .font(.system(.headline, design: .serif, weight: .semibold))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .task(id: app.answersVersion) { await loadRecent() }
    }

    private func loadRecent() async {
        guard let client = session.client else { return }
        do {
            recent = try await client.answers(limit: 5).items
        } catch {
            // 侧栏的「最近问答」是附属信息，加载失败时静默保持原样。
            if error.status == 401 { recent = [] }
        }
    }
}
