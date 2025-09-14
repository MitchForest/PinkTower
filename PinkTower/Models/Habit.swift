import Foundation
import SwiftData

enum HabitCadence: String, Codable, CaseIterable, Identifiable {
    case daily
    case weekly
    case monthly
    var id: String { rawValue }
}

@Model
final class Habit {
    var id: UUID
    var studentId: UUID
    var name: String
    var cadenceRaw: String
    var createdAt: Date
    var createdByGuideId: UUID

    init(
        id: UUID = UUID(),
        studentId: UUID,
        name: String,
        cadence: HabitCadence,
        createdAt: Date = Date(),
        createdByGuideId: UUID
    ) {
        self.id = id
        self.studentId = studentId
        self.name = name
        self.cadenceRaw = cadence.rawValue
        self.createdAt = createdAt
        self.createdByGuideId = createdByGuideId
    }

    var cadence: HabitCadence {
        get { HabitCadence(rawValue: cadenceRaw) ?? .daily }
        set { cadenceRaw = newValue.rawValue }
    }
}


