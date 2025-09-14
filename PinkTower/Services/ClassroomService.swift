import Foundation
import SwiftData

protocol ClassroomServiceProtocol {
    func create(name: String, imageURL: String?, context: ModelContext) throws -> Classroom
    func update(_ classroom: Classroom, name: String?, imageURL: String?, context: ModelContext) throws
    func delete(_ classroom: Classroom, context: ModelContext) throws
    func assign(student: Student, to classroom: Classroom, context: ModelContext) throws
    func unassign(student: Student, from classroom: Classroom, context: ModelContext) throws
    func assign(guide: Guide, to classroom: Classroom, context: ModelContext) throws
    func unassign(guide: Guide, from classroom: Classroom, context: ModelContext) throws
}

struct ClassroomService: ClassroomServiceProtocol {
    func create(name: String, imageURL: String?, context: ModelContext) throws -> Classroom {
        let room = Classroom(name: name, imageURL: imageURL)
        context.insert(room)
        try context.save()
        return room
    }

    func update(_ classroom: Classroom, name: String?, imageURL: String?, context: ModelContext) throws {
        if let name = name { classroom.name = name }
        if let imageURL = imageURL { classroom.imageURL = imageURL }
        try context.save()
    }

    func delete(_ classroom: Classroom, context: ModelContext) throws {
        context.delete(classroom)
        try context.save()
    }

    func assign(student: Student, to classroom: Classroom, context: ModelContext) throws {
        if !classroom.studentIds.contains(student.id) { classroom.studentIds.append(student.id) }
        try context.save()
    }

    func unassign(student: Student, from classroom: Classroom, context: ModelContext) throws {
        classroom.studentIds.removeAll { $0 == student.id }
        try context.save()
    }

    func assign(guide: Guide, to classroom: Classroom, context: ModelContext) throws {
        if !classroom.guideIds.contains(guide.id) { classroom.guideIds.append(guide.id) }
        try context.save()
    }

    func unassign(guide: Guide, from classroom: Classroom, context: ModelContext) throws {
        classroom.guideIds.removeAll { $0 == guide.id }
        try context.save()
    }
}


