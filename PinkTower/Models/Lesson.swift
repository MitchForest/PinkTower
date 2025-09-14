import Foundation
import SwiftData

@Model
final class Lesson {
    var id: UUID
    var studentId: UUID
    var title: String
    var details: String?
    var createdAt: Date
    var createdByGuideId: UUID
    var scheduledFor: Date?
    var completedAt: Date?
    var completedByGuideId: UUID?

    init(
        id: UUID = UUID(),
        studentId: UUID,
        title: String,
        details: String? = nil,
        createdAt: Date = Date(),
        createdByGuideId: UUID,
        scheduledFor: Date? = nil,
        completedAt: Date? = nil,
        completedByGuideId: UUID? = nil
    ) {
        self.id = id
        self.studentId = studentId
        self.title = title
        self.details = details
        self.createdAt = createdAt
        self.createdByGuideId = createdByGuideId
        self.scheduledFor = scheduledFor
        self.completedAt = completedAt
        self.completedByGuideId = completedByGuideId
    }
}


