import Foundation
import SwiftData

@Model
final class Guide {
    var id: UUID
    var appleUserId: String
    var fullName: String
    var email: String?
    var roleRaw: String
    var defaultClassroomId: UUID?
    var avatarURL: String?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        appleUserId: String,
        fullName: String,
        email: String? = nil,
        role: GuideRole = .guide,
        defaultClassroomId: UUID? = nil,
        avatarURL: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.appleUserId = appleUserId
        self.fullName = fullName
        self.email = email
        self.roleRaw = role.rawValue
        self.defaultClassroomId = defaultClassroomId
        self.avatarURL = avatarURL
        self.createdAt = createdAt
    }

    var role: GuideRole {
        get { GuideRole(rawValue: roleRaw) ?? .guide }
        set { roleRaw = newValue.rawValue }
    }
}


