import Foundation

public enum UserRole: String, Codable, Sendable, Hashable, CaseIterable {
    case user
    case admin

    /// 界面文案。
    public var label: String {
        switch self {
        case .user: "普通用户"
        case .admin: "管理员"
        }
    }
}

public struct UserRead: Codable, Sendable, Hashable, Identifiable {
    public var id: String
    public var username: String
    public var role: UserRole
    public var isActive: Bool
    public var createdAt: Date

    public init(id: String, username: String, role: UserRole, isActive: Bool, createdAt: Date) {
        self.id = id
        self.username = username
        self.role = role
        self.isActive = isActive
        self.createdAt = createdAt
    }
}

public struct LoginRequest: Codable, Sendable, Hashable {
    public var username: String
    public var password: String

    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}

public struct LoginResponse: Codable, Sendable, Hashable {
    public var accessToken: String
    public var tokenType: String
    public var expiresAt: Date
    public var user: UserRead
}

public struct PasswordChangeRequest: Codable, Sendable, Hashable {
    public var currentPassword: String
    public var newPassword: String

    public init(currentPassword: String, newPassword: String) {
        self.currentPassword = currentPassword
        self.newPassword = newPassword
    }
}

public struct PasswordResetRequest: Codable, Sendable, Hashable {
    public var newPassword: String

    public init(newPassword: String) {
        self.newPassword = newPassword
    }
}

public struct CreateUserRequest: Codable, Sendable, Hashable {
    public var username: String
    public var password: String
    public var role: UserRole

    public init(username: String, password: String, role: UserRole) {
        self.username = username
        self.password = password
        self.role = role
    }
}

public struct UserPatch: Codable, Sendable, Hashable {
    public var isActive: Bool

    public init(isActive: Bool) {
        self.isActive = isActive
    }
}
