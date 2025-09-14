import Foundation
import SwiftData

protocol LessonServiceProtocol {
    func create(studentId: UUID, title: String, details: String?, scheduledFor: Date?, guideId: UUID, context: ModelContext) throws -> Lesson
    func list(for studentId: UUID, context: ModelContext) throws -> [Lesson]
    func setCompleted(_ lesson: Lesson, completed: Bool, guideId: UUID, context: ModelContext) throws
}

struct LessonService: LessonServiceProtocol {
    func create(studentId: UUID, title: String, details: String?, scheduledFor: Date?, guideId: UUID, context: ModelContext) throws -> Lesson {
        let lesson = Lesson(studentId: studentId, title: title, details: details, createdByGuideId: guideId, scheduledFor: scheduledFor)
        context.insert(lesson)
        try context.save()
        return lesson
    }

    func list(for studentId: UUID, context: ModelContext) throws -> [Lesson] {
        var descriptor = FetchDescriptor<Lesson>(predicate: #Predicate { $0.studentId == studentId })
        descriptor.sortBy = [SortDescriptor(\Lesson.createdAt, order: .reverse)]
        return try context.fetch(descriptor)
    }

    func setCompleted(_ lesson: Lesson, completed: Bool, guideId: UUID, context: ModelContext) throws {
        if completed {
            lesson.completedAt = Date()
            lesson.completedByGuideId = guideId
        } else {
            lesson.completedAt = nil
            lesson.completedByGuideId = nil
        }
        try context.save()
    }
}


