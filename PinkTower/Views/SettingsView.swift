import SwiftUI
import SwiftData

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section(header: PTSectionHeader(title: "Manage")) {
                    NavigationLink("Classrooms") { SettingsClassroomsView() }
                    NavigationLink("Students") { SettingsStudentsView() }
                    NavigationLink("Guides") { SettingsGuidesView() }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsClassroomsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appVM: AppViewModel
    @Query private var classrooms: [Classroom]
    @State private var showCreate = false
    private let classroomService: ClassroomServiceProtocol = ClassroomService()
    private let permission: PermissionServiceProtocol = PermissionService()

    var body: some View {
        List {
            ForEach(classrooms) { room in
                NavigationLink(destination: ClassroomDetailView(classroom: room)) {
                    HStack {
                        PTAvatar(initials: initials(for: room.name), size: 28)
                        Text(room.name)
                    }
                }
            }
            .onDelete { idx in
                guard let guide = appVM.currentGuide, permission.canManageClassrooms(guide) else { return }
                for i in idx { try? classroomService.delete(classrooms[i], context: modelContext) }
            }
        }
        .navigationTitle("Classrooms")
        .toolbar { toolbarContent }
        .sheet(isPresented: $showCreate) { CreateClassroomView() }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            if let guide = appVM.currentGuide, permission.canManageClassrooms(guide) {
                Button { showCreate = true } label: { Image(systemName: "plus") }
            }
        }
    }

    private func initials(for name: String) -> String { String(name.prefix(2)).uppercased() }
}

struct ClassroomDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appVM: AppViewModel
    let classroom: Classroom
    @State private var name: String = ""
    private let classroomService: ClassroomServiceProtocol = ClassroomService()
    private let permission: PermissionServiceProtocol = PermissionService()

    var body: some View {
        Form {
            Section(header: PTSectionHeader(title: "Details")) {
                TextField("Name", text: $name)
            }
        }
        .onAppear { name = classroom.name }
        .navigationTitle("Classroom")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if let guide = appVM.currentGuide, permission.canManageClassrooms(guide) {
                    Button("Save") { try? classroomService.update(classroom, name: name, imageURL: nil, context: modelContext) }
                }
            }
        }
    }
}

struct SettingsStudentsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appVM: AppViewModel
    @Query private var students: [Student]
    @State private var showCreate = false
    private let studentService: StudentServiceProtocol = StudentService()
    private let permission: PermissionServiceProtocol = PermissionService()

    var body: some View {
        List {
            ForEach(students) { student in
                NavigationLink(destination: StudentDetailView(student: student)) {
                    HStack(spacing: PTSpacing.m.rawValue) {
                        PTAvatar(initials: initials(for: student.displayName), size: 28)
                        Text(student.displayName)
                    }
                }
            }
            .onDelete { idx in
                guard let guide = appVM.currentGuide, permission.canManageStudents(guide) else { return }
                for i in idx { try? studentService.delete(students[i], context: modelContext) }
            }
        }
        .navigationTitle("Students")
        .toolbar { toolbarContent }
        .sheet(isPresented: $showCreate) { CreateStudentSheet(onCreated: { _ in }) }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            if let guide = appVM.currentGuide, permission.canManageStudents(guide) {
                Button { showCreate = true } label: { Image(systemName: "plus") }
            }
        }
    }

    private func initials(for name: String) -> String { String(name.split(separator: " ").compactMap { $0.first }.map(String.init).joined().prefix(2)).uppercased() }
}

struct CreateStudentSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    let onCreated: (Student) -> Void
    private let studentService: StudentServiceProtocol = StudentService()

    var body: some View {
        NavigationStack {
            Form {
                Section(header: PTSectionHeader(title: "Details")) {
                    TextField("First name", text: $firstName)
                    TextField("Last name", text: $lastName)
                }
            }
            .navigationTitle("New Student")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { create() }.disabled(firstName.isEmpty || lastName.isEmpty)
                }
            }
        }
    }

    private func create() {
        if let student = try? studentService.create(firstName: firstName, lastName: lastName, imageURL: nil, context: modelContext) {
            onCreated(student)
        }
        dismiss()
    }
}

struct StudentDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appVM: AppViewModel
    let student: Student
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var notes: String = ""
    private let studentService: StudentServiceProtocol = StudentService()
    private let permission: PermissionServiceProtocol = PermissionService()

    var body: some View {
        Form {
            Section(header: PTSectionHeader(title: "Details")) {
                TextField("First name", text: $firstName)
                TextField("Last name", text: $lastName)
                TextField("Notes", text: $notes, axis: .vertical)
            }
        }
        .onAppear {
            firstName = student.firstName
            lastName = student.lastName
            notes = student.notes ?? ""
        }
        .navigationTitle("Student")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if let guide = appVM.currentGuide, permission.canManageStudents(guide) {
                    Button("Save") { try? studentService.update(student, firstName: firstName, lastName: lastName, imageURL: nil, notes: notes, context: modelContext) }
                }
            }
        }
    }
}

struct SettingsGuidesView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appVM: AppViewModel
    @Query private var guides: [Guide]
    private let guideService: GuideServiceProtocol = GuideService()
    private let permission: PermissionServiceProtocol = PermissionService()

    var body: some View {
        List {
            ForEach(guides) { guide in
                NavigationLink(destination: GuideDetailView(guide: guide)) {
                    HStack(spacing: PTSpacing.m.rawValue) {
                        PTAvatar(initials: initials(for: guide.fullName), size: 28)
                        Text(guide.fullName)
                        Spacer()
                        Text(guide.role.rawValue)
                            .font(PTTypography.caption)
                            .foregroundStyle(PTColors.textSecondary)
                    }
                }
            }
            .onDelete { idx in
                guard let current = appVM.currentGuide, permission.canManageGuides(current) else { return }
                for i in idx { try? guideService.delete(guides[i], context: modelContext) }
            }
        }
        .navigationTitle("Guides")
    }

    private func initials(for name: String) -> String { String(name.split(separator: " ").compactMap { $0.first }.map(String.init).joined().prefix(2)).uppercased() }
}

struct GuideDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appVM: AppViewModel
    let guide: Guide
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var role: GuideRole = .guide
    private let guideService: GuideServiceProtocol = GuideService()
    private let permission: PermissionServiceProtocol = PermissionService()

    var body: some View {
        Form {
            Section(header: PTSectionHeader(title: "Profile")) {
                TextField("Full name", text: $fullName)
                TextField("Email", text: $email)
            }
            Section(header: PTSectionHeader(title: "Role")) {
                Picker("Role", selection: $role) {
                    ForEach(GuideRole.allCases) { r in
                        Text(r.rawValue).tag(r)
                    }
                }
            }
        }
        .onAppear {
            fullName = guide.fullName
            email = guide.email ?? ""
            role = guide.role
        }
        .navigationTitle("Guide")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if let current = appVM.currentGuide, permission.canManageGuides(current) {
                    Button("Save") { try? guideService.update(guide, fullName: fullName, email: email.isEmpty ? nil : email, role: role, defaultClassroomId: guide.defaultClassroomId, context: modelContext) }
                }
            }
        }
    }
}


