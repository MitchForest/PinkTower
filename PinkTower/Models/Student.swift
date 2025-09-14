import Foundation
import SwiftData

@Model
final class Student {
    var id: UUID
    var firstName: String
    var lastName: String
    var displayName: String
    var imageURL: String?
    var createdAt: Date
    var notes: String?

    init(
        id: UUID = UUID(),
        firstName: String,
        lastName: String,
        displayName: String? = nil,
        imageURL: String? = nil,
        createdAt: Date = Date(),
        notes: String? = nil
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.displayName = displayName ?? "\(firstName) \(lastName)"
        self.imageURL = imageURL
        self.createdAt = createdAt
        self.notes = notes
    }
}


