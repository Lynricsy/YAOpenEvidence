import SwiftUI

// 阶段 3 实现。
struct UsersView: View {
    var body: some View {
        ContentUnavailableView("用户管理", systemImage: "person.2")
            .navigationTitle("用户")
    }
}
