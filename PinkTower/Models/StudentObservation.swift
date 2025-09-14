import Foundation
import SwiftData

@Model
final class StudentObservation {
    var id: UUID
    var primaryStudentId: UUID
    var taggedStudentIds: [UUID]
    var content: String
    var createdAt: Date
    var createdByGuideId: UUID
    var subjectTag: String?
    var materialTag: String?
    var appTag: String?
    var attachments: [String]?

    init(
        id: UUID = UUID(),
        primaryStudentId: UUID,
        taggedStudentIds: [UUID] = [],
        content: String,
        createdAt: Date = Date(),
        createdByGuideId: UUID,
        subjectTag: String? = nil,
        materialTag: String? = nil,
        appTag: String? = nil,
        attachments: [String]? = nil
    ) {
        self.id = id
        self.primaryStudentId = primaryStudentId
        self.taggedStudentIds = taggedStudentIds
        self.content = content
        self.createdAt = createdAt
        self.createdByGuideId = createdByGuideId
        self.subjectTag = subjectTag
        self.materialTag = materialTag
        self.appTag = appTag
        self.attachments = attachments
    }
}


