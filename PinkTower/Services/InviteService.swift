import Foundation
import SwiftData

protocol InviteServiceProtocol {
    func create(orgId: UUID, role: OrgRole, createdBy: UUID, context: ModelContext) throws -> Invite
    func revoke(_ invite: Invite, context: ModelContext) throws
    func list(orgId: UUID, context: ModelContext) throws -> [Invite]
    func redeem(code: String, by guideId: UUID, context: ModelContext) throws -> Membership
}

struct InviteService: InviteServiceProtocol {
    private let membership: MembershipServiceProtocol = MembershipService()

    func create(orgId: UUID, role: OrgRole, createdBy: UUID, context: ModelContext) throws -> Invite {
        let inv = Invite(orgId: orgId, role: role, createdByGuideId: createdBy)
        context.insert(inv)
        try context.save()
        return inv
    }

    func revoke(_ invite: Invite, context: ModelContext) throws {
        context.delete(invite)
        try context.save()
    }

    func list(orgId: UUID, context: ModelContext) throws -> [Invite] {
        let descriptor = FetchDescriptor<Invite>(predicate: #Predicate { $0.orgId == orgId && $0.redeemedAt == nil })
        return try context.fetch(descriptor)
    }

    func redeem(code: String, by guideId: UUID, context: ModelContext) throws -> Membership {
        var descriptor = FetchDescriptor<Invite>(predicate: #Predicate { $0.code == code && $0.redeemedAt == nil })
        descriptor.fetchLimit = 1
        guard let invite = try context.fetch(descriptor).first else {
            throw NSError(domain: "InviteService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Invite not found or already redeemed"])
        }
        invite.redeemedAt = Date()
        let m = try membership.add(guideId: guideId, role: invite.role, to: invite.orgId, context: context)
        try context.save()
        return m
    }
}


