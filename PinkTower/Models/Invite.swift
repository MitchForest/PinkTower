import Foundation
import SwiftData

@Model
final class Invite {
    var id: UUID
    var orgId: UUID
    var code: String
    var roleRaw: String
    var createdByGuideId: UUID
    var createdAt: Date
    var expiresAt: Date?
    var redeemedAt: Date?

    init(
        id: UUID = UUID(),
        orgId: UUID,
        code: String = UUID().uuidString,
        role: OrgRole,
        createdByGuideId: UUID,
        createdAt: Date = Date(),
        expiresAt: Date? = nil,
        redeemedAt: Date? = nil
    ) {
        self.id = id
        self.orgId = orgId
        self.code = code
        self.roleRaw = role.rawValue
        self.createdByGuideId = createdByGuideId
        self.createdAt = createdAt
        self.expiresAt = expiresAt
        self.redeemedAt = redeemedAt
    }

    var role: OrgRole {
        get { OrgRole(rawValue: roleRaw) ?? .guide }
        set { roleRaw = newValue.rawValue }
    }
}


