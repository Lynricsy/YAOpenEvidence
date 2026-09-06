import Foundation
import YAOEKit

/// 任务事件流的连接与重连管理。退避 1s 起 ×2，上限 10s，不因成功连接而重置。
@MainActor
@Observable
final class JobLiveMonitor {
    enum Connection: Equatable {
        case idle
        case connecting
        case open
        case reconnecting
        case closed

        var label: String {
            switch self {
            case .idle, .closed: "同步任务状态"
            case .open: "实时更新中"
            case .connecting: "正在连接…"
            case .reconnecting: "连接中断，正在重连…"
            }
        }
    }

    private(set) var live = JobLive.empty
    private(set) var connection: Connection = .idle

    private let jobID: String
    private let client: APIClient
    private let session: SessionStore
    private let onEvent: (JobLive, SSEEvent) -> Void
    private var task: Task<Void, Never>?

    init(
        jobID: String,
        client: APIClient,
        session: SessionStore,
        onEvent: @escaping (JobLive, SSEEvent) -> Void
    ) {
        self.jobID = jobID
        self.client = client
        self.session = session
        self.onEvent = onEvent
    }

    func start() {
        guard task == nil else { return }
        task = Task { await run() }
    }

    func stop() {
        task?.cancel()
        task = nil
        connection = .closed
    }

    private func run() async {
        var lastEventID = "0-0"
        var delay = Duration.seconds(1)
        var first = true

        while !Task.isCancelled {
            connection = first ? .connecting : .reconnecting
            do {
                for try await event in await client.events(jobID: jobID, lastEventID: lastEventID) {
                    if let id = event.id { lastEventID = id }
                    connection = .open
                    live = live.applying(event)
                    onEvent(live, event)
                }
            } catch {
                if Task.isCancelled { return }
                // 鉴权/参数类错误重连也不会好转。
                if let status = (error as? APIError)?.status, [401, 403, 404, 422].contains(status) {
                    connection = .closed
                    return
                }
            }

            if live.terminal != nil {
                connection = .closed
                return
            }
            if Task.isCancelled { return }

            first = false
            connection = .reconnecting
            // 重连前探活：令牌已失效就直接登出，不再空转重试。
            do {
                _ = try await client.me()
            } catch {
                if error.status == 401 {
                    session.expire()
                    connection = .closed
                    return
                }
            }

            try? await Task.sleep(for: delay)
            delay = min(delay * 2, .seconds(10))
        }
    }
}
