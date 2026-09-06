import SwiftUI
import YAOEKit

@MainActor
@Observable
final class UsersModel {
    static let pageSize = 20

    var page: Loadable<Page<UserRead>> = .idle
    var offset = 0
    /// 正在切换启用状态的用户 id。
    var updating: Set<String> = []

    private var session: SessionStore?
    private var errors: ErrorPresenter?

    var items: [UserRead] { page.value?.items ?? [] }
    var total: Int { page.value?.total ?? 0 }
    var canPrevious: Bool { offset > 0 }
    var canNext: Bool { offset + Self.pageSize < total }

    var rangeLabel: String {
        guard total > 0 else { return "共 0 条" }
        return "第 \(offset + 1)–\(min(offset + items.count, total)) 条，共 \(total) 条"
    }

    func configure(session: SessionStore, errors: ErrorPresenter) {
        self.session = session
        self.errors = errors
    }

    func load() async {
        guard let client = session?.client else { return }
        if page.value == nil { page = .loading }
        do {
            page = .loaded(try await client.users(limit: Self.pageSize, offset: offset))
        } catch {
            page = .failed(error.userMessage)
        }
    }

    func previousPage() {
        guard canPrevious else { return }
        offset = max(0, offset - Self.pageSize)
        Task { await load() }
    }

    func nextPage() {
        guard canNext else { return }
        offset += Self.pageSize
        Task { await load() }
    }

    func setActive(_ user: UserRead, isActive: Bool) async {
        guard let client = session?.client else { return }
        updating.insert(user.id)
        defer { updating.remove(user.id) }
        do {
            let updated = try await client.updateUser(id: user.id, isActive: isActive)
            replace(updated)
        } catch {
            errors?.present(error)
            // 失败时回滚：重新拉取当前页，避免开关停在错误状态。
            await load()
        }
    }

    func createUser(username: String, password: String, role: UserRole) async -> Bool {
        guard let client = session?.client else { return false }
        do {
            _ = try await client.createUser(username: username, password: password, role: role)
            await load()
            return true
        } catch {
            errors?.present(error)
            return false
        }
    }

    func resetPassword(_ user: UserRead, newPassword: String) async -> Bool {
        guard let client = session?.client else { return false }
        do {
            try await client.resetPassword(id: user.id, newPassword: newPassword)
            return true
        } catch {
            errors?.present(error)
            return false
        }
    }

    private func replace(_ user: UserRead) {
        guard var current = page.value else { return }
        guard let index = current.items.firstIndex(where: { $0.id == user.id }) else { return }
        current.items[index] = user
        page = .loaded(current)
    }
}

struct UsersView: View {
    @Environment(SessionStore.self) private var session
    @Environment(ErrorPresenter.self) private var errors

    @State private var model = UsersModel()
    @State private var showCreate = false
    @State private var resetTarget: UserRead?

    var body: some View {
        List {
            ForEach(model.items) { user in
                UserRow(
                    user: user,
                    isSelf: user.id == session.user?.id,
                    updating: model.updating.contains(user.id),
                    onToggle: { isActive in Task { await model.setActive(user, isActive: isActive) } },
                    onReset: { resetTarget = user }
                )
            }

            if model.total > 0 {
                HStack {
                    Button("上一页") { model.previousPage() }
                        .disabled(!model.canPrevious)
                    Spacer()
                    Text(model.rangeLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("下一页") { model.nextPage() }
                        .disabled(!model.canNext)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .overlay {
            if model.items.isEmpty, !model.page.isLoading {
                ContentUnavailableView("暂无用户", systemImage: "person.2")
            }
        }
        .navigationTitle("用户")
        .toolbar {
            ToolbarItem {
                Button("新建用户", systemImage: "person.badge.plus") { showCreate = true }
            }
        }
        .refreshable { await model.load() }
        .task {
            model.configure(session: session, errors: errors)
            await model.load()
        }
        .sheet(isPresented: $showCreate) {
            CreateUserSheet { username, password, role in
                await model.createUser(username: username, password: password, role: role)
            }
        }
        .sheet(item: $resetTarget) { user in
            ResetPasswordSheet(user: user) { password in
                await model.resetPassword(user, newPassword: password)
            }
        }
    }
}

struct UserRow: View {
    let user: UserRead
    let isSelf: Bool
    let updating: Bool
    let onToggle: (Bool) -> Void
    let onReset: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(String(user.username.prefix(1)).uppercased())
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(Color.accentColor, in: .circle)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(user.username).font(.subheadline.weight(.medium))
                    if isSelf { Pill(text: "我", tone: .accentColor) }
                    Pill(text: user.role.label, tone: user.role == .admin ? .purple : .secondary)
                }
                Text(user.createdAt.formatted(.dateTime.year().month().day().hour().minute()))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Toggle(
                    updating ? "更新中…" : (user.isActive ? "已启用" : "已禁用"),
                    isOn: Binding(get: { user.isActive }, set: { onToggle($0) })
                )
                .toggleStyle(.switch)
                .labelsHidden()
                .disabled(updating)
                Text(updating ? "更新中…" : (user.isActive ? "已启用" : "已禁用"))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Button("重置密码", action: onReset)
                    .buttonStyle(.bordered)
                    .controlSize(.small)
            }
        }
        .padding(.vertical, 4)
    }
}

struct CreateUserSheet: View {
    let onCreate: (String, String, UserRole) async -> Bool

    @Environment(\.dismiss) private var dismiss
    @State private var username = ""
    @State private var password = ""
    @State private var role: UserRole = .user
    @State private var pending = false

    private var usernameValid: Bool {
        username.range(of: #"^[A-Za-z0-9][A-Za-z0-9_.-]{2,63}$"#, options: .regularExpression) != nil
    }

    private var passwordValid: Bool { (12 ... 128).contains(password.count) }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("用户名", text: $username)
                        .autocorrectionDisabled()
                        #if os(iOS)
                            .textInputAutocapitalization(.never)
                        #endif
                    SecureField("密码", text: $password)
                    Picker("角色", selection: $role) {
                        ForEach(UserRole.allCases, id: \.self) { role in
                            Text(role.label).tag(role)
                        }
                    }
                } footer: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("3–64 个字符，以字母或数字开头，仅含字母、数字、下划线、点或连字符")
                        Text("密码须为 12–128 个字符")
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("新建用户")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(pending ? "创建中…" : "创建") { submit() }
                        .disabled(pending || !usernameValid || !passwordValid)
                }
            }
        }
    }

    private func submit() {
        pending = true
        Task {
            defer { pending = false }
            if await onCreate(username.lowercased(), password, role) { dismiss() }
        }
    }
}

struct ResetPasswordSheet: View {
    let user: UserRead
    let onReset: (String) async -> Bool

    @Environment(\.dismiss) private var dismiss
    @State private var password = ""
    @State private var confirm = ""
    @State private var pending = false

    private var valid: Bool { (12 ... 128).contains(password.count) && password == confirm }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField("新密码", text: $password)
                    SecureField("确认新密码", text: $confirm)
                } header: {
                    Text("用户：\(user.username)。重置后，该用户所有会话将失效。")
                } footer: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("密码须为 12–128 个字符")
                        if !password.isEmpty, !confirm.isEmpty, password != confirm {
                            Text("两次输入的新密码不一致").foregroundStyle(.red)
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("重置密码")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(pending ? "重置中…" : "重置") { submit() }
                        .disabled(pending || !valid)
                }
            }
        }
    }

    private func submit() {
        pending = true
        Task {
            defer { pending = false }
            if await onReset(password) { dismiss() }
        }
    }
}
