import Foundation
import SwiftData

enum OrgRole: String, Codable, CaseIterable, Identifiable {
    case superAdmin
    case admin
    case guide
    var id: String { rawValue }
}

@Model
final class Membership {
    var id: UUID
    var orgId: UUID
    var guideId: UUID
    var roleRaw: String
    var createdAt: Date

    init(id: UUID = UUID(), orgId: UUID, guideId: UUID, role: OrgRole, createdAt: Date = Date()) {
        self.id = id
        self.orgId = orgId
        self.guideId = guideId
        self.roleRaw = role.rawValue
        self.createdAt = createdAt
    }

    var role: OrgRole {
        get { OrgRole(rawValue: roleRaw) ?? .guide }
        set { roleRaw = newValue.rawValue }
    }
}


