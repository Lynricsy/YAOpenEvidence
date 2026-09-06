import SwiftUI

// 阶段 2 / 阶段 3 页面在后续步骤实现，这里先占位以保证壳层可构建。

struct LibraryView: View {
    var body: some View {
        ContentUnavailableView("文献库", systemImage: "books.vertical")
            .navigationTitle("文献库")
    }
}

struct PaperDetailView: View {
    let route: PaperRoute

    var body: some View {
        ContentUnavailableView(route.key, systemImage: "doc.text")
    }
}

struct KbSearchView: View {
    var body: some View {
        ContentUnavailableView("知识库", systemImage: "brain")
            .navigationTitle("知识库")
    }
}

struct LiteratureSearchView: View {
    var body: some View {
        ContentUnavailableView("查文献", systemImage: "magnifyingglass")
            .navigationTitle("查文献")
    }
}

struct UsersView: View {
    var body: some View {
        ContentUnavailableView("用户管理", systemImage: "person.2")
            .navigationTitle("用户")
    }
}
