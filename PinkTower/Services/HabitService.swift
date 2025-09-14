import Foundation
import SwiftData

protocol HabitServiceProtocol {
    func create(studentId: UUID, name: String, cadence: HabitCadence, createdByGuideId: UUID, context: ModelContext) throws -> Habit
    func list(for studentId: UUID, context: ModelContext) throws -> [Habit]
    func toggleToday(habit: Habit, guideId: UUID, context: ModelContext) throws -> HabitLog
}

struct HabitService: HabitServiceProtocol {
    func create(studentId: UUID, name: String, cadence: HabitCadence, createdByGuideId: UUID, context: ModelContext) throws -> Habit {
        let habit = Habit(studentId: studentId, name: name, cadence: cadence, createdByGuideId: createdByGuideId)
        context.insert(habit)
        try context.save()
        return habit
    }

    func list(for studentId: UUID, context: ModelContext) throws -> [Habit] {
        let descriptor = FetchDescriptor<Habit>(predicate: #Predicate { $0.studentId == studentId })
        return try context.fetch(descriptor)
    }

    func toggleToday(habit: Habit, guideId: UUID, context: ModelContext) throws -> HabitLog {
        let today = Calendar.current.startOfDay(for: Date())
        let habitId = habit.id
        let descriptor = FetchDescriptor<HabitLog>(predicate: #Predicate { $0.habitId == habitId })
        let logs = try context.fetch(descriptor)
        if let existing = logs.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            context.delete(existing)
            try context.save()
            // Return a log representing undone (isDone=false) for convenience
            return HabitLog(habitId: habit.id, date: today, isDone: false, createdByGuideId: guideId)
        } else {
            let log = HabitLog(habitId: habit.id, date: today, isDone: true, createdByGuideId: guideId)
            context.insert(log)
            try context.save()
            return log
        }
    }
}


