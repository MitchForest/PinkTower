import Foundation
import SwiftData

protocol SessionServiceProtocol {
    func determineInitialRoute(context: ModelContext) throws -> AppRoute
    func getOrCreateGuide(forAppleUserId userId: String, context: ModelContext) throws -> Guide
    func activeOrgId(for guide: Guide, context: ModelContext) throws -> UUID?
    func ensureOrgBootstrap(for guide: Guide, context: ModelContext) throws -> UUID
}

final class SessionService: SessionServiceProtocol {
    func determineInitialRoute(context: ModelContext) throws -> AppRoute {
        guard let userId = Keychain.shared.string(forKey: "appleUserId") else {
            return .signIn
        }
        let guide = try getOrCreateGuide(forAppleUserId: userId, context: context)
        if try activeOrgId(for: guide, context: context) == nil {
            return .promptCreateOrganization
        }
        // If no default classroom, go to create classroom prompt. Otherwise main.
        return guide.defaultClassroomId == nil ? .promptCreateClassroom : .main
    }

    func getOrCreateGuide(forAppleUserId userId: String, context: ModelContext) throws -> Guide {
        var descriptor = FetchDescriptor<Guide>(predicate: #Predicate { $0.appleUserId == userId })
        descriptor.fetchLimit = 1
        if let found = try context.fetch(descriptor).first {
            return found
        }
        let guide = Guide(appleUserId: userId, fullName: "Guide")
        context.insert(guide)
        try context.save()
        return guide
    }

    func activeOrgId(for guide: Guide, context: ModelContext) throws -> UUID? {
        // For now, derive from memberships. Later persist a per-device active org.
        let gid = guide.id
        var descriptor = FetchDescriptor<Membership>(predicate: #Predicate { $0.guideId == gid })
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first?.orgId
    }

    func ensureOrgBootstrap(for guide: Guide, context: ModelContext) throws -> UUID {
        if let orgId = try activeOrgId(for: guide, context: context) { return orgId }
        // Create default org and make this guide superAdmin
        let org = Organization(name: "My School")
        context.insert(org)
        let m = Membership(orgId: org.id, guideId: guide.id, role: .superAdmin)
        context.insert(m)
        try context.save()
        return org.id
    }
}


