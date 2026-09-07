import SwiftUI
import YAOEKit

struct LoginView: View {
    @Environment(SessionStore.self) private var session

    @State private var server = ""
    @State private var username = ""
    @State private var password = ""
    @State private var revealPassword = false
    @State private var pending = false
    @State private var message: String?
    @State private var retryAfter = 0
    @State private var didPrefill = false

    private var trimmedServer: String { server.trimmingCharacters(in: .whitespaces) }

    private var serverURL: URL? {
        guard let url = URL(string: trimmedServer), let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https", let host = url.host(), !host.isEmpty
        else { return nil }
        return url
    }

    /// 明文 HTTP 只允许本地网络（与 Info.plist 的 ATS 配置一致）。
    private var serverError: String? {
        guard !trimmedServer.isEmpty else { return nil }
        guard let url = serverURL, let host = url.host() else { return "请输入 http:// 或 https:// 开头的服务器地址" }
        if url.scheme?.lowercased() == "http", !Self.isLocalHost(host) {
            return "非本地网络地址需使用 https://"
        }
        return nil
    }

    private var canSubmit: Bool {
        !pending && retryAfter == 0 && serverURL != nil && serverError == nil
            && !username.trimmingCharacters(in: .whitespaces).isEmpty && !password.isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                brand
                form
            }
            .frame(maxWidth: 480)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.vertical, 40)
        }
        .background(.background)
        .task {
            guard !didPrefill else { return }
            didPrefill = true
            server = session.lastServerText
        }
    }

    private var brand: some View {
        VStack(spacing: 12) {
            BrandLogo(size: 72)
            Text("YAOpenEvidence")
                .font(.system(.largeTitle, design: .serif, weight: .semibold))
            Text("让每一条结论，都能回到原文。")
                .font(.headline)
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 8) {
                Label("逐篇核实每一条引文", systemImage: "checkmark.seal")
                Label("段落级溯源，点击即达原文", systemImage: "text.quote")
                Label("证据沉淀为本地知识库", systemImage: "archivebox")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var form: some View {
        VStack(alignment: .leading, spacing: 16) {
            field(title: "服务器地址") {
                TextField("http://localhost:8765", text: $server)
                    .textContentType(.URL)
                    .autocorrectionDisabled()
                    #if os(iOS)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                    #endif
            }
            if let serverError {
                Text(serverError)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            field(title: "用户名") {
                TextField("用户名", text: $username)
                    .textContentType(.username)
                    .autocorrectionDisabled()
                    #if os(iOS)
                        .textInputAutocapitalization(.never)
                    #endif
            }

            field(title: "密码") {
                HStack {
                    Group {
                        if revealPassword {
                            TextField("密码", text: $password)
                        } else {
                            SecureField("密码", text: $password)
                        }
                    }
                    .textContentType(.password)
                    .onSubmit { submit() }

                    Button {
                        revealPassword.toggle()
                    } label: {
                        Image(systemName: revealPassword ? "eye.slash" : "eye")
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(revealPassword ? "隐藏密码" : "显示密码")
                }
            }

            if let message {
                Text(message)
                    .font(.callout)
                    .foregroundStyle(.red)
            }

            Button {
                submit()
            } label: {
                HStack {
                    if pending { ProgressView().controlSize(.small) }
                    Text(retryAfter > 0 ? "\(retryAfter) 秒后重试" : "登录")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!canSubmit)

            Text("仅供科研与教学参考，不构成医疗建议")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    @ViewBuilder
    private func field(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            content()
                .textFieldStyle(.roundedBorder)
        }
    }

    private func submit() {
        guard canSubmit, let url = serverURL else { return }
        pending = true
        message = nil
        Task {
            defer { pending = false }
            do {
                try await session.login(
                    server: url,
                    username: username.trimmingCharacters(in: .whitespaces).lowercased(),
                    password: password
                )
                password = ""
            } catch {
                let apiError = error as? APIError
                message = apiError.map(loginMessage(for:)) ?? "网络连接失败，请稍后重试"
                if apiError?.code == "login_rate_limited" { await countDown(apiError?.retryAfter ?? 60) }
            }
        }
    }

    private func loginMessage(for error: APIError) -> String {
        if error.status == 401 { return "用户名或密码错误" }
        return error.userMessage
    }

    private func countDown(_ seconds: Int) async {
        retryAfter = seconds
        while retryAfter > 0 {
            try? await Task.sleep(for: .seconds(1))
            retryAfter -= 1
        }
    }

    /// 本地网络主机：localhost、私有网段、链路本地与 .local 域名。
    static func isLocalHost(_ host: String) -> Bool {
        let host = host.lowercased()
        if host == "localhost" || host.hasSuffix(".local") || host.hasSuffix(".localhost") { return true }
        if host == "::1" { return true }
        let parts = host.split(separator: ".").compactMap { Int($0) }
        guard parts.count == 4 else { return false }
        switch (parts[0], parts[1]) {
        case (127, _), (10, _), (192, 168), (169, 254): return true
        case (172, let second) where (16 ... 31).contains(second): return true
        default: return false
        }
    }
}
