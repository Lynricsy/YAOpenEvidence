import Foundation
import Synchronization
import YAOEKit

/// 令牌盒：`APIClient` 会在任意隔离域上同步读取令牌，因此不能放在主线程状态里。
final class TokenBox: Sendable {
    private let storage = Mutex<String?>(nil)

    var token: String? { storage.withLock { $0 } }

    func set(_ value: String?) {
        storage.withLock { $0 = value }
    }
}

/// 登录状态与 API 客户端的持有者。会话固定 7 天且无刷新令牌，过期即回登录页。
@MainActor
@Observable
final class SessionStore {
    enum Phase: Equatable {
        case checking
        case signedOut
        case signedIn
    }

    enum Keys {
        static let serverURL = "yaoe.serverURL"
        static let expiresAt = "yaoe.tokenExpiresAt"
        static let user = "yaoe.user"
    }

    private(set) var phase: Phase = .checking
    private(set) var user: UserRead?
    private(set) var serverURL: URL?
    private(set) var client: APIClient?

    private let tokens = TokenBox()
    private let keychain = KeychainStore.sessionToken
    private let defaults = UserDefaults.standard
    /// 会话代次：每建一个客户端 +1，用来丢弃旧会话迟到的 401。
    private var generation = 0

    /// 会话结束（登出 / 失效 / 换服务器）时的回调，供上层清空会话级界面状态。
    var onSessionEnded: (@MainActor () -> Void)?

    var isAdmin: Bool { user?.role == .admin }

    /// 上次使用的服务器地址，供登录页预填。
    var lastServerText: String {
        defaults.string(forKey: Keys.serverURL) ?? "http://localhost:8765"
    }

    // MARK: - 生命周期

    /// 启动时恢复会话：令牌未过期且 `/auth/me` 通过才算已登录。
    func bootstrap() async {
        guard let token = keychain.read(),
              let urlText = defaults.string(forKey: Keys.serverURL),
              let url = URL(string: urlText)
        else {
            clear()
            return
        }
        let expiresAt = defaults.object(forKey: Keys.expiresAt) as? Date
        guard let expiresAt, expiresAt > .now else {
            clear()
            return
        }

        tokens.set(token)
        serverURL = url
        let client = makeClient(baseURL: url)
        self.client = client
        do {
            user = try await client.me()
            cacheUser(user)
            phase = .signedIn
        } catch {
            // 只有后端明确否认这枚令牌才算会话失效。网络抖动、超时、5xx 都不能销毁
            // 一枚本地尚未过期的令牌——否则一次断网重启就要用户重新输密码。
            // 令牌真的坏了也不会卡住：下一个受保护请求的 401 会走 `expire` 回登录页。
            switch error.status {
            case 401, 403:
                clear()
            default:
                user = cachedUser()
                phase = .signedIn
            }
        }
    }

    func login(server: URL, username: String, password: String) async throws(APIError) {
        let client = makeClient(baseURL: server)
        tokens.set(nil)
        let response = try await client.login(username: username, password: password)

        tokens.set(response.accessToken)
        keychain.write(response.accessToken)
        defaults.set(server.absoluteString, forKey: Keys.serverURL)
        defaults.set(response.expiresAt, forKey: Keys.expiresAt)
        serverURL = server
        self.client = client
        user = response.user
        cacheUser(response.user)
        phase = .signedIn
    }

    /// 主动退出：通知后端注销，本地无论成功与否都清空。
    func logout() async {
        if let client { try? await client.logout() }
        clear()
    }

    /// 令牌失效（受保护端点返回 401）。只有当 401 来自当前这次会话时才清空：
    /// 旧会话的在途请求可能在重新登录之后才返回，不能把新令牌一起踹掉。
    func expire(generation: Int? = nil) {
        if let generation, generation != self.generation { return }
        guard phase != .signedOut else { return }
        clear()
    }

    // MARK: - 私有

    private func makeClient(baseURL: URL) -> APIClient {
        generation += 1
        let generation = generation
        let tokens = tokens
        return APIClient(
            baseURL: baseURL,
            tokenProvider: { tokens.token },
            onUnauthorized: { [weak self] in
                Task { @MainActor in self?.expire(generation: generation) }
            }
        )
    }

    private func cacheUser(_ user: UserRead?) {
        guard let user, let data = try? JSONCoding.encoder.encode(user) else { return }
        defaults.set(data, forKey: Keys.user)
    }

    /// 上一次成功拿到的账号信息：`/auth/me` 暂时打不通时用它撑住界面。
    private func cachedUser() -> UserRead? {
        guard let data = defaults.data(forKey: Keys.user) else { return nil }
        return try? JSONCoding.decoder.decode(UserRead.self, from: data)
    }

    private func clear() {
        let wasSignedIn = phase == .signedIn
        tokens.set(nil)
        keychain.delete()
        defaults.removeObject(forKey: Keys.expiresAt)
        defaults.removeObject(forKey: Keys.user)
        // 让旧会话迟到的 401 无法再命中当前代次。
        generation += 1
        client = nil
        user = nil
        phase = .signedOut
        if wasSignedIn { onSessionEnded?() }
    }
}
