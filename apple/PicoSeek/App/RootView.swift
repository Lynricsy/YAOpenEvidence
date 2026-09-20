import SwiftUI

struct RootView: View {
    @Environment(SessionStore.self) private var session
    @Environment(AppModel.self) private var app
    @Environment(ErrorPresenter.self) private var errors
    @AppStorage("picoseek.theme") private var theme = AppTheme.system

    var body: some View {
        @Bindable var errors = errors
        Group {
            switch session.phase {
            case .checking:
                // 会话恢复期与启动屏视觉衔接：同一枚标识 + 同一系统背景色。
                VStack(spacing: 16) {
                    BrandLogo(size: 64, label: "PicoSeek")
                    ProgressView("正在验证会话")
                        .controlSize(.large)
                }
            case .signedOut:
                LoginView()
            case .signedIn:
                MainTabView()
            }
        }
        // 窗口最小尺寸跟着内容走：再小登录按钮和侧栏就没地方放了。
        #if os(macOS)
            .frame(minWidth: 860, minHeight: 640)
        #endif
        .animation(.default, value: session.phase)
        .task {
            // 会话结束时清掉上一个账号的草稿与导航栈。
            session.onSessionEnded = { app.resetForNewSession() }
            await session.bootstrap()
        }
        .alert(item: $errors.pending) { message in
            Alert(title: Text(message.title), message: Text(message.body), dismissButton: .default(Text("好")))
        }
        .preferredColorScheme(theme.colorScheme)
        // 界面文案是简体中文，日期与数字格式跟着一起走，避免出现「1 second ago」这类混排。
        .environment(\.locale, Locale(identifier: "zh-Hans"))
    }
}
