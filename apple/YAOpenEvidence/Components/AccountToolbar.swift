import SwiftUI

/// iOS 上各根页右上角的账号入口；macOS 用 `Settings` 场景（⌘,）承载同一视图。
struct AccountToolbar: ViewModifier {
    @State private var showAccount = false

    func body(content: Content) -> some View {
        #if os(iOS)
            content
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showAccount = true
                        } label: {
                            Image(systemName: "person.crop.circle")
                        }
                        .accessibilityLabel("账号")
                    }
                }
                .sheet(isPresented: $showAccount) {
                    NavigationStack { AccountView() }
                }
        #else
            content
        #endif
    }
}

extension View {
    func accountToolbar() -> some View {
        modifier(AccountToolbar())
    }
}
