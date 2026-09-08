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
    }

    private(set) var live = JobLive.empty
    private(set) var connection: Connection = .idle

    /// 是否已在订阅中：页面重新出现时用它避免重复 `start()`。
    var isRunning: Bool { task != nil }

    private let jobID: String
    private let client: APIClient
    private let onEvent: (JobLive, SSEEvent) -> Void
    private var task: Task<Void, Never>?
    /// 已消费到的 Redis Stream 位置：暂停后再续订从这里继续，避免重放造成日志重复。
    private var lastEventID = "0-0"
    /// 暂停后再续订算新一代：旧任务收尾时不得把新任务的 `task` 清空。
    private var generation = 0

    init(
        jobID: String,
        client: APIClient,
        onEvent: @escaping (JobLive, SSEEvent) -> Void
    ) {
        self.jobID = jobID
        self.client = client
        self.onEvent = onEvent
    }

    /// 订阅事件流。已终态或已在运行时是空操作，可在页面重新出现时安全重复调用。
    func start() {
        guard task == nil, live.terminal == nil else { return }
        generation += 1
        let generation = generation
        task = Task { [weak self] in
            await self?.run()
            guard let self, self.generation == generation else { return }
            task = nil
        }
    }

    /// 暂停订阅（离开页面）。保留 `live` 与 `lastEventID`，回到页面后 `start()` 可续订。
    func stop() {
        task?.cancel()
        task = nil
        connection = live.terminal == nil ? .idle : .closed
    }

    private func run() async {
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
            // 重连前探活：令牌已失效就停连，不再空转重试。会话由 `APIClient`
            // 的 onUnauthorized 统一清理（那里带会话代次，不会误杀新登录）。
            do {
                _ = try await client.me()
            } catch {
                if error.status == 401 {
                    connection = .closed
                    return
                }
            }

            try? await Task.sleep(for: delay)
            delay = min(delay * 2, .seconds(10))
        }
    }
}
