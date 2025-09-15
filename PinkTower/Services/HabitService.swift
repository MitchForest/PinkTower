import Foundation
import SwiftData

protocol HabitServiceProtocol {
    func create(studentId: UUID, name: String, cadence: HabitCadence, createdByGuideId: UUID, context: ModelContext) throws -> Habit
    func list(for studentId: UUID, context: ModelContext) throws -> [Habit]
    func toggleToday(habit: Habit, guideId: UUID, context: ModelContext) throws -> HabitLog
    // New APIs for a week grid UX
    func toggle(_ habit: Habit, on date: Date, guideId: UUID, context: ModelContext) throws -> HabitLog
    func logs(for habitIds: [UUID], in range: ClosedRange<Date>, context: ModelContext) throws -> [HabitLog]
    func popularHabitNames(context: ModelContext) throws -> [String]
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

    // MARK: - New

    func toggle(_ habit: Habit, on date: Date, guideId: UUID, context: ModelContext) throws -> HabitLog {
        let day = Calendar.current.startOfDay(for: date)
        let habitId = habit.id
        let descriptor = FetchDescriptor<HabitLog>(predicate: #Predicate { $0.habitId == habitId })
        let logs = try context.fetch(descriptor)
        if let existing = logs.first(where: { Calendar.current.isDate($0.date, inSameDayAs: day) }) {
            context.delete(existing)
            try context.save()
            return HabitLog(habitId: habit.id, date: day, isDone: false, createdByGuideId: guideId)
        } else {
            let log = HabitLog(habitId: habit.id, date: day, isDone: true, createdByGuideId: guideId)
            context.insert(log)
            try context.save()
            return log
        }
    }

    func logs(for habitIds: [UUID], in range: ClosedRange<Date>, context: ModelContext) throws -> [HabitLog] {
        guard !habitIds.isEmpty else { return [] }
        // Fetch logs for all provided habits and then filter by range
        let descriptor = FetchDescriptor<HabitLog>(predicate: #Predicate { habitIds.contains($0.habitId) })
        let all = try context.fetch(descriptor)
        let start = Calendar.current.startOfDay(for: range.lowerBound)
        let end = Calendar.current.startOfDay(for: range.upperBound)
        return all.filter { $0.date >= start && $0.date <= end }
    }

    func popularHabitNames(context: ModelContext) throws -> [String] {
        let descriptor = FetchDescriptor<Habit>()
        let all = try context.fetch(descriptor)
        let counts = Dictionary(grouping: all.map { $0.name.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }) { $0 }
            .mapValues { $0.count }
        return counts.sorted { lhs, rhs in
            if lhs.value == rhs.value { return lhs.key.localizedCaseInsensitiveCompare(rhs.key) == .orderedAscending }
            return lhs.value > rhs.value
        }.map { $0.key }
    }
}


