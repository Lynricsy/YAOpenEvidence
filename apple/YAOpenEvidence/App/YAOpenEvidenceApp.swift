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
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("新建问答") { app.requestNewQuestion() }
                    .keyboardShortcut("n")
            }
        }
        #if os(macOS)
        Settings {
            AccountView()
                .environment(session)
                .environment(app)
                .environment(errors)
                .frame(width: 480)
        }
        #endif
    }
}
