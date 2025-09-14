import Foundation
import SwiftData

protocol SessionServiceProtocol {
    func determineInitialRoute(context: ModelContext) throws -> AppRoute
    func getOrCreateGuide(forAppleUserId userId: String, context: ModelContext) throws -> Guide
}

final class SessionService: SessionServiceProtocol {
    func determineInitialRoute(context: ModelContext) throws -> AppRoute {
        guard let userId = Keychain.shared.string(forKey: "appleUserId") else {
            return .signIn
        }
        let guide = try getOrCreateGuide(forAppleUserId: userId, context: context)
        if guide.defaultClassroomId == nil {
            return .promptCreateClassroom
        } else {
            return .main
        }
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
}


