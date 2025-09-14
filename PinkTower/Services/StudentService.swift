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


