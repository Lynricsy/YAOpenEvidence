import SwiftUI

/// 页面级加载状态。失败保留可读文案，交由 `LoadableView` 统一呈现。
enum Loadable<Value> {
    case idle
    case loading
    case loaded(Value)
    case failed(String)

    var value: Value? {
        if case .loaded(let value) = self { return value }
        return nil
    }

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
}

extension Loadable: Equatable where Value: Equatable {}
extension Loadable: Sendable where Value: Sendable {}

/// 统一的「加载中 / 失败重试 / 内容」三态容器。
struct LoadableView<Value, Content: View>: View {
    let state: Loadable<Value>
    var retry: (() -> Void)?
    @ViewBuilder let content: (Value) -> Content

    var body: some View {
        Group {
            switch state {
            case .idle, .loading:
                ProgressView()
                    .controlSize(.large)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .failed(let message):
                ErrorPanel(message: message, retry: retry)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .loaded(let value):
                content(value)
                    .transition(.opacity)
            }
        }
        .animation(.default, value: state.isLoading)
    }
}

struct ErrorPanel: View {
    let message: String
    var detail: String?
    var retry: (() -> Void)?
    var retryLabel = "重试"

    var body: some View {
        ContentUnavailableView {
            Label(message, systemImage: "exclamationmark.triangle")
        } description: {
            if let detail, !detail.isEmpty { Text(detail) }
        } actions: {
            if let retry {
                Button(retryLabel, action: retry)
                    .buttonStyle(.borderedProminent)
            }
        }
    }
}
