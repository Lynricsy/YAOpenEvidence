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
            clear()
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

    /// 令牌失效（任何受保护端点返回 401）。
    func expire() {
        guard phase != .signedOut else { return }
        clear()
    }

    // MARK: - 私有

    private func makeClient(baseURL: URL) -> APIClient {
        let tokens = tokens
        return APIClient(
            baseURL: baseURL,
            tokenProvider: { tokens.token },
            onUnauthorized: { [weak self] in
                Task { @MainActor in self?.expire() }
            }
        )
    }

    private func cacheUser(_ user: UserRead?) {
        guard let user, let data = try? JSONCoding.encoder.encode(user) else { return }
        defaults.set(data, forKey: Keys.user)
    }

    private func clear() {
        tokens.set(nil)
        keychain.delete()
        defaults.removeObject(forKey: Keys.expiresAt)
        defaults.removeObject(forKey: Keys.user)
        client = nil
        user = nil
        phase = .signedOut
    }
}
