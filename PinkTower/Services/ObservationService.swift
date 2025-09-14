import Foundation
import SwiftData

struct ObservationQuery {
    var studentId: UUID
    var search: String? = nil
    var dateRange: ClosedRange<Date>? = nil
    var subjectTag: String? = nil
    var materialTag: String? = nil
    var appTag: String? = nil
    var taggedStudentId: UUID? = nil
    var sortNewestFirst: Bool = true
}

protocol ObservationServiceProtocol {
    func create(primaryStudentId: UUID, content: String, taggedStudentIds: [UUID], subjectTag: String?, materialTag: String?, appTag: String?, createdByGuideId: UUID, context: ModelContext) throws -> StudentObservation
    func list(_ query: ObservationQuery, context: ModelContext) throws -> [StudentObservation]
    func delete(_ observation: StudentObservation, context: ModelContext) throws
}

struct ObservationService: ObservationServiceProtocol {
    func create(primaryStudentId: UUID, content: String, taggedStudentIds: [UUID], subjectTag: String?, materialTag: String?, appTag: String?, createdByGuideId: UUID, context: ModelContext) throws -> StudentObservation {
        let obs = StudentObservation(primaryStudentId: primaryStudentId, taggedStudentIds: taggedStudentIds, content: content, createdByGuideId: createdByGuideId, subjectTag: subjectTag, materialTag: materialTag, appTag: appTag)
        context.insert(obs)
        try context.save()
        return obs
    }

    func list(_ query: ObservationQuery, context: ModelContext) throws -> [StudentObservation] {
        let sid = query.studentId
        let descriptor = FetchDescriptor<StudentObservation>(predicate: #Predicate { $0.primaryStudentId == sid })
        var results = try context.fetch(descriptor)

        if let tagId = query.taggedStudentId {
            results = results.filter { $0.taggedStudentIds.contains(tagId) }
        }
        if let subject = query.subjectTag, !subject.isEmpty {
            results = results.filter { ($0.subjectTag ?? "").localizedStandardContains(subject) }
        }
        if let material = query.materialTag, !material.isEmpty {
            results = results.filter { ($0.materialTag ?? "").localizedStandardContains(material) }
        }
        if let app = query.appTag, !app.isEmpty {
            results = results.filter { ($0.appTag ?? "").localizedStandardContains(app) }
        }
        if let range = query.dateRange {
            results = results.filter { range.contains($0.createdAt) }
        }
        if let search = query.search, !search.isEmpty {
            results = results.filter { $0.content.localizedStandardContains(search) }
        }

        results.sort { lhs, rhs in
            if query.sortNewestFirst {
                return lhs.createdAt > rhs.createdAt
            } else {
                return lhs.createdAt < rhs.createdAt
            }
        }
        return results
    }

    func delete(_ observation: StudentObservation, context: ModelContext) throws {
        context.delete(observation)
        try context.save()
    }
}


