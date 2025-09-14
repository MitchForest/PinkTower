import Foundation
import SwiftData

protocol OrgServiceProtocol {
    func create(name: String, context: ModelContext) throws -> Organization
    func rename(_ org: Organization, to name: String, context: ModelContext) throws
    func list(context: ModelContext) throws -> [Organization]
}

struct OrgService: OrgServiceProtocol {
    func create(name: String, context: ModelContext) throws -> Organization {
        let org = Organization(name: name)
        context.insert(org)
        try context.save()
        return org
    }

    func rename(_ org: Organization, to name: String, context: ModelContext) throws {
        org.name = name
        try context.save()
    }

    func list(context: ModelContext) throws -> [Organization] {
        try context.fetch(FetchDescriptor<Organization>())
    }
}


