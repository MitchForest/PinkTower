import Foundation
import SwiftData

protocol MembershipServiceProtocol {
    func members(of orgId: UUID, context: ModelContext) throws -> [Membership]
    func role(of guideId: UUID, in orgId: UUID, context: ModelContext) throws -> OrgRole?
    func add(guideId: UUID, role: OrgRole, to orgId: UUID, context: ModelContext) throws -> Membership
    func remove(guideId: UUID, from orgId: UUID, context: ModelContext) throws
    func updateRole(guideId: UUID, in orgId: UUID, to role: OrgRole, context: ModelContext) throws
}

struct MembershipService: MembershipServiceProtocol {
    func members(of orgId: UUID, context: ModelContext) throws -> [Membership] {
        let descriptor = FetchDescriptor<Membership>(predicate: #Predicate { $0.orgId == orgId })
        return try context.fetch(descriptor)
    }

    func role(of guideId: UUID, in orgId: UUID, context: ModelContext) throws -> OrgRole? {
        var descriptor = FetchDescriptor<Membership>(predicate: #Predicate { $0.orgId == orgId && $0.guideId == guideId })
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first?.role
    }

    func add(guideId: UUID, role: OrgRole, to orgId: UUID, context: ModelContext) throws -> Membership {
        let m = Membership(orgId: orgId, guideId: guideId, role: role)
        context.insert(m)
        try context.save()
        return m
    }

    func remove(guideId: UUID, from orgId: UUID, context: ModelContext) throws {
        let descriptor = FetchDescriptor<Membership>(predicate: #Predicate { $0.orgId == orgId && $0.guideId == guideId })
        for m in try context.fetch(descriptor) { context.delete(m) }
        try context.save()
    }

    func updateRole(guideId: UUID, in orgId: UUID, to role: OrgRole, context: ModelContext) throws {
        let descriptor = FetchDescriptor<Membership>(predicate: #Predicate { $0.orgId == orgId && $0.guideId == guideId })
        for m in try context.fetch(descriptor) { m.role = role }
        try context.save()
    }
}


