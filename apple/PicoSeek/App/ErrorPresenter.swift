import Foundation
import PicoSeekKit

/// 全局错误/提示弹窗。成功反馈用界面状态变化表达，这里只处理需要打断的消息。
@MainActor
@Observable
final class ErrorPresenter {
    struct Message: Identifiable {
        let id = UUID()
        var title: String
        var body: String
    }

    var pending: Message?

    func present(_ error: any Error) {
        let text = (error as? APIError)?.userMessage ?? "网络连接失败，请稍后重试"
        pending = Message(title: "操作失败", body: text)
    }

    func present(message: String) {
        pending = Message(title: "操作失败", body: message)
    }

    func presentInfo(_ message: String) {
        pending = Message(title: "提示", body: message)
    }
}
