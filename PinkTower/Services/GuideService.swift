import Foundation
import SwiftData

protocol GuideServiceProtocol {
    func create(appleUserId: String, fullName: String, email: String?, role: GuideRole, context: ModelContext) throws -> Guide
    func update(_ guide: Guide, fullName: String?, email: String?, role: GuideRole?, defaultClassroomId: UUID?, context: ModelContext) throws
    func delete(_ guide: Guide, context: ModelContext) throws
}

struct GuideService: GuideServiceProtocol {
    func create(appleUserId: String, fullName: String, email: String?, role: GuideRole, context: ModelContext) throws -> Guide {
        let guide = Guide(appleUserId: appleUserId, fullName: fullName, email: email, role: role)
        context.insert(guide)
        try context.save()
        return guide
    }

    func update(_ guide: Guide, fullName: String?, email: String?, role: GuideRole?, defaultClassroomId: UUID?, context: ModelContext) throws {
        if let fullName = fullName { guide.fullName = fullName }
        if let email = email { guide.email = email }
        if let role = role { guide.role = role }
        if let id = defaultClassroomId { guide.defaultClassroomId = id }
        try context.save()
    }

    func delete(_ guide: Guide, context: ModelContext) throws {
        context.delete(guide)
        try context.save()
    }
}


