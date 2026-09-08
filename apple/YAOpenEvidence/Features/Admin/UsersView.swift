import SwiftUI
import YAOEKit

@MainActor
@Observable
final class UsersModel {
    static let pageSize = 20

    var page: Loadable<Page<UserRead>> = .idle
    /// 首段之后追加的分段结果；`load()` 会清空。
    private(set) var more: [UserRead] = []
    private(set) var loadingMore = false
    /// 正在切换启用状态的用户 id。
    var updating: Set<String> = []

    private var session: SessionStore?
    private var errors: ErrorPresenter?
    private var requestSeq = 0

    var items: [UserRead] { (page.value?.items ?? []) + more }
    var total: Int { page.value?.total ?? 0 }
    var canLoadMore: Bool { page.value != nil && !loadingMore && items.count < total }

    func configure(session: SessionStore, errors: ErrorPresenter) {
        self.session = session
        self.errors = errors
    }

    func load() async {
        guard let client = session?.client else { return }
        requestSeq += 1
        let seq = requestSeq
        if page.value == nil { page = .loading }
        do {
            let result = try await client.users(limit: Self.pageSize, offset: 0)
            guard seq == requestSeq else { return }
            page = .loaded(result)
            more = []
        } catch {
            guard seq == requestSeq else { return }
            page = .failed(error.userMessage)
        }
    }

    /// 滚到底部时追加下一段。沿用 `requestSeq`：重新加载期间返回的追加结果会被丢弃，
    /// 避免旧分段接到新列表后面。
    func loadMore() async {
        guard canLoadMore, let client = session?.client, let first = page.value else { return }
        loadingMore = true
        defer { loadingMore = false }
        let seq = requestSeq
        do {
            let result = try await client.users(limit: Self.pageSize, offset: items.count)
            guard seq == requestSeq else { return }
            more += result.items
            // total 可能已被上游改动，用最新值重建首段，否则 canLoadMore 会停在旧判据上。
            page = .loaded(
                Page(items: first.items, total: result.total, limit: first.limit, offset: first.offset)
            )
        } catch {
            guard seq == requestSeq else { return }
            errors?.present(error)
        }
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
            // 失败时回滚：重新拉取列表，避免开关停在错误状态。
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
        if var current = page.value, let index = current.items.firstIndex(where: { $0.id == user.id }) {
            current.items[index] = user
            page = .loaded(current)
            return
        }
        // 追加段里的行同样要就地更新，否则开关会弹回旧状态。
        if let index = more.firstIndex(where: { $0.id == user.id }) {
            more[index] = user
        }
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
                    onToggle: { isActive in Task { await model.setActive(user, isActive: isActive) } }
                )
                .onAppear {
                    if user.id == model.items.last?.id { Task { await model.loadMore() } }
                }
                .swipeActions(edge: .trailing) {
                    Button("重置密码", systemImage: "key") { resetTarget = user }
                        .tint(.orange)
                }
                // macOS 没有滑动手势，右键菜单是那里唯一的入口。
                .contextMenu {
                    Button("重置密码", systemImage: "key") { resetTarget = user }
                }
            }

            if model.loadingMore {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .overlay {
            switch model.page {
            case .idle, .loading:
                ProgressView()
            case .failed(let message):
                ErrorPanel(message: message, retry: { Task { await model.load() } })
            case .loaded(let page):
                if page.items.isEmpty {
                    ContentUnavailableView("暂无用户", systemImage: "person.2")
                }
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
