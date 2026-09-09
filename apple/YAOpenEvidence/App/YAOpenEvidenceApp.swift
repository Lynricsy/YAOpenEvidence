import SwiftUI

@main
struct YAOpenEvidenceApp: App {
    @State private var session = SessionStore()
    @State private var app = AppModel()
    @State private var errors = ErrorPresenter()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(session)
                .environment(app)
                .environment(errors)
        }
        // SwiftUI 的默认窗口是 900×450，登录表单的按钮会掉到窗口外，主界面更是挤成一团。
        #if os(macOS)
            .defaultSize(width: 1180, height: 820)
            .windowResizability(.contentMinSize)
        #endif
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("新建问答") { app.requestNewQuestion() }
                    .keyboardShortcut("n")
            }
        }
        #if os(macOS)
        Settings {
            AccountSettingsScene()
                .environment(session)
                .environment(app)
                .environment(errors)
                .environment(\.locale, Locale(identifier: "zh-Hans"))
                .frame(width: 480)
        }
        #endif
    }
}
