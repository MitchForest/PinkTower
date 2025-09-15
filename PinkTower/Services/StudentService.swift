import Foundation
import SwiftData

protocol StudentServiceProtocol {
    func create(firstName: String, lastName: String, imageURL: String?, context: ModelContext) throws -> Student
    func update(_ student: Student, firstName: String?, lastName: String?, imageURL: String?, notes: String?, context: ModelContext) throws
    func delete(_ student: Student, context: ModelContext) throws
}

struct StudentService: StudentServiceProtocol {
    func create(firstName: String, lastName: String, imageURL: String?, context: ModelContext) throws -> Student {
        let student = Student(firstName: firstName, lastName: lastName, imageURL: imageURL)
        context.insert(student)
        try context.save()
        // Seed default habits (can be removed later by the guide)
        seedDefaultHabits(for: student, context: context)
        return student
    }

    func update(_ student: Student, firstName: String?, lastName: String?, imageURL: String?, notes: String?, context: ModelContext) throws {
        if let firstName = firstName { student.firstName = firstName }
        if let lastName = lastName { student.lastName = lastName }
        if let imageURL = imageURL { student.imageURL = imageURL }
        if let notes = notes { student.notes = notes }
        student.displayName = "\(student.firstName) \(student.lastName)"
        try context.save()
    }

    func delete(_ student: Student, context: ModelContext) throws {
        context.delete(student)
        try context.save()
    }
}

// MARK: - Defaults
private extension StudentService {
    func seedDefaultHabits(for student: Student, context: ModelContext) {
        // Avoid duplicates if rerun
        let sid = student.id
        let existing = (try? context.fetch(FetchDescriptor<Habit>(predicate: #Predicate { $0.studentId == sid }))) ?? []
        let namesToEnsure: [String] = ["Attended class"]
        let existingNames = Set(existing.map { $0.name.lowercased() })
        for name in namesToEnsure where !existingNames.contains(name.lowercased()) {
            // createdByGuideId: unknown here; use student.org to look up any guide in org if available
            let creatorId = (try? context.fetch(FetchDescriptor<Guide>()).first?.id) ?? UUID()
            let habit = Habit(studentId: student.id, name: name, cadence: .daily, createdByGuideId: creatorId)
            context.insert(habit)
        }
        try? context.save()
    }
}


