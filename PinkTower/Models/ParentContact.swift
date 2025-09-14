import Foundation
import SwiftData

@Model
final class ParentContact {
    var id: UUID
    var studentId: UUID
    var fullName: String
    var email: String?
    var phone: String?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        studentId: UUID,
        fullName: String,
        email: String? = nil,
        phone: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.studentId = studentId
        self.fullName = fullName
        self.email = email
        self.phone = phone
        self.createdAt = createdAt
    }
}


