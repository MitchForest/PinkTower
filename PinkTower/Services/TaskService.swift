import Foundation
import SwiftData

protocol TaskServiceProtocol {
    func create(studentId: UUID, title: String, details: String?, scheduledFor: Date?, guideId: UUID, context: ModelContext) throws -> TaskItem
    func list(for studentId: UUID, context: ModelContext) throws -> [TaskItem]
    func setCompleted(_ task: TaskItem, completed: Bool, guideId: UUID, context: ModelContext) throws
}

struct TaskService: TaskServiceProtocol {
    func create(studentId: UUID, title: String, details: String?, scheduledFor: Date?, guideId: UUID, context: ModelContext) throws -> TaskItem {
        let task = TaskItem(studentId: studentId, title: title, details: details, createdByGuideId: guideId, scheduledFor: scheduledFor)
        context.insert(task)
        try context.save()
        return task
    }

    func list(for studentId: UUID, context: ModelContext) throws -> [TaskItem] {
        var descriptor = FetchDescriptor<TaskItem>(predicate: #Predicate { $0.studentId == studentId })
        descriptor.sortBy = [SortDescriptor(\TaskItem.createdAt, order: .reverse)]
        return try context.fetch(descriptor)
    }

    func setCompleted(_ task: TaskItem, completed: Bool, guideId: UUID, context: ModelContext) throws {
        if completed {
            task.completedAt = Date()
            task.completedByGuideId = guideId
        } else {
            task.completedAt = nil
            task.completedByGuideId = nil
        }
        try context.save()
    }
}


