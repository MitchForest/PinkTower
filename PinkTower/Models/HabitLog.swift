import Foundation
import SwiftData

@Model
final class HabitLog {
    var id: UUID
    var habitId: UUID
    var date: Date // Day granularity
    var isDone: Bool
    var createdByGuideId: UUID
    var createdAt: Date

    init(
        id: UUID = UUID(),
        habitId: UUID,
        date: Date,
        isDone: Bool = true,
        createdByGuideId: UUID,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.habitId = habitId
        self.date = Calendar.current.startOfDay(for: date)
        self.isDone = isDone
        self.createdByGuideId = createdByGuideId
        self.createdAt = createdAt
    }
}


