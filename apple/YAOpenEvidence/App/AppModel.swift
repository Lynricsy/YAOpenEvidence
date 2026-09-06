import Foundation
import YAOEKit

/// 壳层选中项。`answer` 用于 regular 宽度侧栏的「最近问答」。
enum Destination: Hashable {
    case ask
    case history
    case library
    case kb
    case literature
    case users
    case answer(String)
}

/// 导航栈里的一步。
enum AskRoute: Hashable {
    case answer(String)
}

/// 文献详情路由：`pid` 非空时打开后定位到该段落。
struct PaperRoute: Hashable {
    var key: String
    var pid: Int?
}

/// 跨页面共享的界面状态（选中项、导航栈、筛选草稿、刷新信号）。
@MainActor
@Observable
final class AppModel {
    var selection: Destination = .ask
    var askPath: [AskRoute] = []
    var historyPath: [AskRoute] = []
    var libraryPath: [PaperRoute] = []
    var kbPath: [PaperRoute] = []
    var askDraft = ""

    /// answers 集合发生变化的计数器，驱动历史与「最近问答」重新加载。
    private(set) var answersVersion = 0
    /// 「新建问答」请求计数器，驱动输入框聚焦。
    private(set) var newQuestionToken = 0

    var filters: AskFilters {
        didSet { saveFilters() }
    }

    private static let filtersKey = "yaoe.filters"

    init() {
        let data = UserDefaults.standard.data(forKey: Self.filtersKey)
        let decoded = data.flatMap { try? JSONCoding.decoder.decode(AskFilters.self, from: $0) }
        filters = (decoded ?? .default).normalized()
    }

    func noteAnswersChanged() {
        answersVersion += 1
    }

    func requestNewQuestion() {
        selection = .ask
        askPath = []
        newQuestionToken += 1
    }

    /// 「沿用此次筛选重新提问」：恢复筛选并把问题填回草稿。
    func reask(question: String, options: JSONValue) {
        filters = AskFilters(options: options).normalized()
        askDraft = question
        requestNewQuestion()
    }

    func openAnswer(_ id: String) {
        switch selection {
        case .history: historyPath.append(.answer(id))
        default:
            selection = .ask
            askPath = [.answer(id)]
        }
    }

    private func saveFilters() {
        guard let data = try? JSONCoding.encoder.encode(filters) else { return }
        UserDefaults.standard.set(data, forKey: Self.filtersKey)
    }
}
