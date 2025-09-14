import Foundation
import SwiftData

@Model
final class Classroom {
    var id: UUID
    var name: String
    var imageURL: String?
    var guideIds: [UUID]
    var studentIds: [UUID]
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        imageURL: String? = nil,
        guideIds: [UUID] = [],
        studentIds: [UUID] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.guideIds = guideIds
        self.studentIds = studentIds
        self.createdAt = createdAt
    }
}


