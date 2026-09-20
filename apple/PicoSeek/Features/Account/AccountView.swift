import SwiftUI
import PicoSeekKit

struct AccountView: View {
    @Environment(SessionStore.self) private var session
    @Environment(ErrorPresenter.self) private var errors
    @Environment(\.dismiss) private var dismiss
    @AppStorage("picoseek.theme") private var theme = AppTheme.system

    @State private var loggingOut = false

    var body: some View {
        #if os(macOS)
            NavigationStack { content }
        #else
            content
        #endif
    }

    private var content: some View {
        Form {
            Section("账号") {
                LabeledContent("用户名", value: session.user?.username ?? "—")
                LabeledContent("角色") {
                    Pill(
                        text: session.user?.role.label ?? "—",
                        tone: session.isAdmin ? .accentColor : .secondary
                    )
                }
            }

            Section("服务器") {
                // 只显示主机与端口：scheme 与路径对用户没有意义。
                LabeledContent("地址", value: serverLabel)
                Button("切换服务器") { logout() }
            }

            Section("外观") {
                Picker("主题", selection: $theme) {
                    ForEach(AppTheme.allCases) { option in
                        Text(option.label).tag(option)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("安全") {
                NavigationLink("修改密码") { ChangePasswordView() }
            }

            if session.isAdmin {
                Section("管理") {
                    NavigationLink("用户管理") { UsersView() }
                }
            }

            Section {
                Button(role: .destructive) {
                    logout()
                } label: {
                    HStack {
                        if loggingOut { ProgressView().controlSize(.small) }
                        Text(loggingOut ? "正在退出…" : "退出登录")
                    }
                }
                .disabled(loggingOut)
            } footer: {
                Text("仅供科研与教学参考，不构成医疗建议")
            }
        }
        .formStyle(.grouped)
        .navigationTitle("账号")
        #if os(iOS)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        #endif
    }

    private var serverLabel: String {
        session.serverURL.map { ($0.host() ?? "") + ($0.port.map { ":\($0)" } ?? "") } ?? "—"
    }

    private func logout() {
        guard !loggingOut else { return }
        loggingOut = true
        Task {
            await session.logout()
            loggingOut = false
            dismiss()
        }
    }
}

struct ChangePasswordView: View {
    @Environment(SessionStore.self) private var session
    @Environment(ErrorPresenter.self) private var errors

    @State private var current = ""
    @State private var next = ""
    @State private var confirm = ""
    @State private var pending = false
    @State private var message: String?

    private var lengthValid: Bool { (12 ... 128).contains(next.count) }
    private var matches: Bool { next == confirm }
    private var canSubmit: Bool { !pending && !current.isEmpty && lengthValid && matches }

    var body: some View {
        Form {
            Section {
                SecureField("当前密码", text: $current)
                SecureField("新密码", text: $next)
                SecureField("确认新密码", text: $confirm)
            } footer: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("密码须为 12–128 个字符")
                    if !next.isEmpty, !confirm.isEmpty, !matches {
                        Text("两次输入的新密码不一致").foregroundStyle(.red)
                    }
                    if let message {
                        Text(message).foregroundStyle(.red)
                    }
                }
            }

            Section {
                Button {
                    submit()
                } label: {
                    HStack {
                        if pending { ProgressView().controlSize(.small) }
                        Text("修改密码")
                    }
                }
                .disabled(!canSubmit)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("修改密码")
    }

    private func submit() {
        guard canSubmit, let client = session.client else { return }
        pending = true
        message = nil
        Task {
            defer { pending = false }
            do {
                try await client.changePassword(current: current, new: next)
                // 后端会注销全部会话，本地必须同步登出，并立刻清掉已输入的密码。
                current = ""
                next = ""
                confirm = ""
                await session.logout()
                errors.presentInfo("密码已修改，请重新登录")
            } catch {
                message = (error as? APIError)?.userMessage ?? "网络连接失败，请稍后重试"
            }
        }
    }
}

/// macOS 的「设置」是独立窗口，不受 `RootView` 的登录分支控制：
/// 会话结束后必须自己回到未登录状态，不能继续展示上一个账号的表单。
struct AccountSettingsScene: View {
    @Environment(SessionStore.self) private var session

    var body: some View {
        Group {
            if session.phase == .signedIn {
                AccountView()
            } else {
                ContentUnavailableView("未登录", systemImage: "person.crop.circle.badge.xmark")
                    .padding(24)
            }
        }
        .id(session.user?.id ?? "signed-out")
    }
}
