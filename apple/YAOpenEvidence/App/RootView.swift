import SwiftUI

struct RootView: View {
    @Environment(SessionStore.self) private var session
    @Environment(ErrorPresenter.self) private var errors
    @AppStorage("yaoe.theme") private var theme = AppTheme.system

    var body: some View {
        @Bindable var errors = errors
        Group {
            switch session.phase {
            case .checking:
                ProgressView("正在验证会话")
                    .controlSize(.large)
            case .signedOut:
                LoginView()
            case .signedIn:
                MainTabView()
            }
        }
        .animation(.default, value: session.phase)
        .task { await session.bootstrap() }
        .alert(item: $errors.pending) { message in
            Alert(title: Text(message.title), message: Text(message.body), dismissButton: .default(Text("好")))
        }
        .preferredColorScheme(theme.colorScheme)
        // 界面文案是简体中文，日期与数字格式跟着一起走，避免出现「1 second ago」这类混排。
        .environment(\.locale, Locale(identifier: "zh-Hans"))
    }
}
