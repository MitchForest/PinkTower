import SwiftUI
import SwiftData

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section(header: PTSectionHeader(title: "Organization")) {
                    NavigationLink("Organization") { OrganizationSettingsView() }
                }
                Section(header: PTSectionHeader(title: "Manage")) {
                    NavigationLink("Classrooms") { SettingsClassroomsView() }
                    NavigationLink("Students") { SettingsStudentsView() }
                    NavigationLink("Guides") { SettingsGuidesView() }
                    NavigationLink("AI Settings") { AISettingsView() }
                }
                Section(header: PTSectionHeader(title: "Developer Tools")) {
                    NavigationLink("Developer Tools") { DeveloperToolsView() }
                }
            }
            .navigationTitle("Settings")
            .scrollContentBackground(.hidden)
            .background(PTColors.surface)
        }
    }
}
struct OrganizationSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appVM: AppViewModel
    private let orgs: OrgServiceProtocol = OrgService()
    private let invites: InviteServiceProtocol = InviteService()
    private let memberships: MembershipServiceProtocol = MembershipService()
    @State private var orgName: String = ""
    @State private var inviteRole: OrgRole = .guide
    @State private var lastInviteCode: String?
    @State private var redeemCode: String = ""

    var body: some View {
        Form {
            Section(header: PTSectionHeader(title: "Organization")) {
                TextField("Name", text: $orgName).textFieldStyle(PTTextFieldStyle())
                Button("Save name") { saveName() }.ptPrimary()
            }
            Section(header: PTSectionHeader(title: "Invite")) {
                Picker("Role", selection: $inviteRole) {
                    ForEach(OrgRole.allCases) { r in Text(r.rawValue).tag(r) }
                }
                Button("Create invite") { createInvite() }.ptPrimary()
                if let code = lastInviteCode { Text("Invite code: \(code)").font(PTTypography.caption).foregroundStyle(PTColors.textSecondary) }
            }
            Section(header: PTSectionHeader(title: "Join")) {
                TextField("Enter invite code", text: $redeemCode).textFieldStyle(PTTextFieldStyle())
                Button("Redeem") { redeem() }.ptSecondary()
            }
        }
        .scrollContentBackground(.hidden)
        .background(PTColors.surface)
        .navigationTitle("Organization")
        .onAppear { loadOrgName() }
    }

    private func loadOrgName() {
        guard let guide = appVM.currentGuide, let orgId = try? sessionOrgId(guide) else { return }
        if let org = try? modelContext.fetch(FetchDescriptor<Organization>(predicate: #Predicate { $0.id == orgId })).first {
            orgName = org.name
        }
    }

    private func saveName() {
        guard let guide = appVM.currentGuide, let orgId = try? sessionOrgId(guide) else { return }
        if let org = try? modelContext.fetch(FetchDescriptor<Organization>(predicate: #Predicate { $0.id == orgId })).first {
            try? orgs.rename(org, to: orgName, context: modelContext)
        }
    }

    private func createInvite() {
        guard let guide = appVM.currentGuide, let orgId = try? sessionOrgId(guide) else { return }
        if let inv = try? invites.create(orgId: orgId, role: inviteRole, createdBy: guide.id, context: modelContext) {
            lastInviteCode = inv.code
        }
    }

    private func redeem() {
        guard let guide = appVM.currentGuide else { return }
        _ = try? invites.redeem(code: redeemCode.trimmingCharacters(in: .whitespacesAndNewlines), by: guide.id, context: modelContext)
    }

    private func sessionOrgId(_ guide: Guide) throws -> UUID? {
        let gid = guide.id
        var descriptor = FetchDescriptor<Membership>(predicate: #Predicate { $0.guideId == gid })
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first?.orgId
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
                        PTAvatar(image: nil, size: 28, initials: initials(for: room.name))
                        Text(room.name)
                    }
                }
            }
            .onDelete { idx in
                guard let guide = appVM.currentGuide, permission.canManageClassrooms(guide, orgRole: currentOrgRole()) else { return }
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
            if let guide = appVM.currentGuide, permission.canManageClassrooms(guide, orgRole: currentOrgRole()) {
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
                TextField("Name", text: $name).textFieldStyle(PTTextFieldStyle())
            }
        }
        .scrollContentBackground(.hidden)
        .background(PTColors.surface)
        .onAppear { name = classroom.name }
        .navigationTitle("Classroom")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if let guide = appVM.currentGuide, permission.canManageClassrooms(guide, orgRole: currentOrgRole()) {
                    Button("Save") { try? classroomService.update(classroom, name: name, imageURL: nil, context: modelContext) }
                }
            }
        }
    }

    private func currentOrgRole() -> OrgRole? {
        guard let guide = appVM.currentGuide else { return nil }
        let gid = guide.id
        var descriptor = FetchDescriptor<Membership>(predicate: #Predicate { $0.guideId == gid })
        descriptor.fetchLimit = 1
        return try? modelContext.fetch(descriptor).first?.role
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
                        PTAvatar(image: nil, size: 28, initials: initials(for: student.displayName))
                        Text(student.displayName)
                    }
                }
            }
            .onDelete { idx in
                guard let guide = appVM.currentGuide, permission.canManageStudents(guide, orgRole: currentOrgRole()) else { return }
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
            if let guide = appVM.currentGuide, permission.canManageStudents(guide, orgRole: currentOrgRole()) {
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
            VStack(spacing: PTSpacing.m.rawValue) {
                Text("New Student").font(PTTypography.title).foregroundStyle(PTColors.textPrimary)
                HStack(spacing: PTSpacing.m.rawValue) {
                    PTInput(placeholder: "First name", text: $firstName)
                    PTInput(placeholder: "Last name", text: $lastName)
                    PTAvatarSelector(emoji: .constant(""), imageData: .constant(nil))
                }
                .frame(maxWidth: 640)
                Spacer(minLength: 0)
            }
            .scrollContentBackground(.hidden)
            .background(PTColors.surface)
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
                TextField("First name", text: $firstName).textFieldStyle(PTTextFieldStyle())
                TextField("Last name", text: $lastName).textFieldStyle(PTTextFieldStyle())
                TextField("Notes", text: $notes, axis: .vertical)
            }
        }
        .scrollContentBackground(.hidden)
        .background(PTColors.surface)
        .onAppear {
            firstName = student.firstName
            lastName = student.lastName
            notes = student.notes ?? ""
        }
        .navigationTitle("Student")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if let guide = appVM.currentGuide, permission.canManageStudents(guide, orgRole: currentOrgRole()) {
                    Button("Save") { try? studentService.update(student, firstName: firstName, lastName: lastName, imageURL: nil, notes: notes, context: modelContext) }
                }
            }
        }
    }

    private func currentOrgRole() -> OrgRole? {
        guard let guide = appVM.currentGuide else { return nil }
        let gid = guide.id
        var descriptor = FetchDescriptor<Membership>(predicate: #Predicate { $0.guideId == gid })
        descriptor.fetchLimit = 1
        return try? modelContext.fetch(descriptor).first?.role
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
                        PTAvatar(image: nil, size: 28, initials: initials(for: guide.fullName))
                        Text(guide.fullName)
                        Spacer()
                        Text(guide.role.rawValue)
                            .font(PTTypography.caption)
                            .foregroundStyle(PTColors.textSecondary)
                    }
                }
            }
            .onDelete { idx in
                guard let current = appVM.currentGuide, permission.canManageGuides(current, orgRole: currentOrgRole()) else { return }
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
                TextField("Full name", text: $fullName).textFieldStyle(PTTextFieldStyle())
                TextField("Email", text: $email).textFieldStyle(PTTextFieldStyle())
            }
            Section(header: PTSectionHeader(title: "Role")) {
                Picker("Role", selection: $role) {
                    ForEach(GuideRole.allCases) { r in
                        Text(r.rawValue).tag(r)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(PTColors.surface)
        .onAppear {
            fullName = guide.fullName
            email = guide.email ?? ""
            role = guide.role
        }
        .navigationTitle("Guide")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if let current = appVM.currentGuide, permission.canManageGuides(current, orgRole: currentOrgRole()) {
                    Button("Save") { try? guideService.update(guide, fullName: fullName, email: email.isEmpty ? nil : email, role: role, defaultClassroomId: guide.defaultClassroomId, context: modelContext) }
                }
            }
        }
    }

    private func currentOrgRole() -> OrgRole? {
        guard let guide = appVM.currentGuide else { return nil }
        let gid = guide.id
        var descriptor = FetchDescriptor<Membership>(predicate: #Predicate { $0.guideId == gid })
        descriptor.fetchLimit = 1
        return try? modelContext.fetch(descriptor).first?.role
    }
}

private extension SettingsClassroomsView {
    func currentOrgRole() -> OrgRole? {
        guard let guide = appVM.currentGuide else { return nil }
        let gid = guide.id
        var descriptor = FetchDescriptor<Membership>(predicate: #Predicate { $0.guideId == gid })
        descriptor.fetchLimit = 1
        return try? modelContext.fetch(descriptor).first?.role
    }
}

private extension SettingsStudentsView {
    func currentOrgRole() -> OrgRole? {
        guard let guide = appVM.currentGuide else { return nil }
        let gid = guide.id
        var descriptor = FetchDescriptor<Membership>(predicate: #Predicate { $0.guideId == gid })
        descriptor.fetchLimit = 1
        return try? modelContext.fetch(descriptor).first?.role
    }
}

private extension SettingsGuidesView {
    func currentOrgRole() -> OrgRole? {
        guard let guide = appVM.currentGuide else { return nil }
        let gid = guide.id
        var descriptor = FetchDescriptor<Membership>(predicate: #Predicate { $0.guideId == gid })
        descriptor.fetchLimit = 1
        return try? modelContext.fetch(descriptor).first?.role
    }
}

struct AISettingsView: View {
    @State private var apiKey: String = ""
    private let config: ConfigServiceProtocol = ConfigService()

    var body: some View {
        Form {
            Section(header: PTSectionHeader(title: "OpenAI")) {
                SecureField("API Key", text: $apiKey)
                Button("Save") { config.setOpenAIAPIKey(apiKey) }.ptPrimary()
            }
        }
        .onAppear { apiKey = config.openAIAPIKey() ?? "" }
        .navigationTitle("AI Settings")
    }
}

struct DeveloperToolsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appVM: AppViewModel
    private let config: ConfigServiceProtocol = ConfigService()

    var body: some View {
        Form {
            Section(header: PTSectionHeader(title: "Data")) {
                Button("Reset (clear data and return to Sign In)") {
                    // Full purge: clear stored Apple ID and delete all SwiftData entities
                    Keychain.shared.remove(forKey: "appleUserId")

                    // Delete content in dependency order
                    let deleteAll: [(any PersistentModel.Type)] = [
                        StudentObservation.self,
                        HabitLog.self,
                        Habit.self,
                        Lesson.self,
                        TaskItem.self,
                        ParentContact.self,
                        Membership.self,
                        Invite.self,
                        Classroom.self,
                        Student.self,
                        Organization.self,
                        Guide.self
                    ]

                    for model in deleteAll {
                        if model == StudentObservation.self {
                            if let all = try? modelContext.fetch(FetchDescriptor<StudentObservation>()) {
                                for obj in all { modelContext.delete(obj) }
                            }
                        } else if model == HabitLog.self {
                            if let all = try? modelContext.fetch(FetchDescriptor<HabitLog>()) {
                                for obj in all { modelContext.delete(obj) }
                            }
                        } else if model == Habit.self {
                            if let all = try? modelContext.fetch(FetchDescriptor<Habit>()) {
                                for obj in all { modelContext.delete(obj) }
                            }
                        } else if model == Lesson.self {
                            if let all = try? modelContext.fetch(FetchDescriptor<Lesson>()) {
                                for obj in all { modelContext.delete(obj) }
                            }
                        } else if model == TaskItem.self {
                            if let all = try? modelContext.fetch(FetchDescriptor<TaskItem>()) {
                                for obj in all { modelContext.delete(obj) }
                            }
                        } else if model == ParentContact.self {
                            if let all = try? modelContext.fetch(FetchDescriptor<ParentContact>()) {
                                for obj in all { modelContext.delete(obj) }
                            }
                        } else if model == Membership.self {
                            if let all = try? modelContext.fetch(FetchDescriptor<Membership>()) {
                                for obj in all { modelContext.delete(obj) }
                            }
                        } else if model == Invite.self {
                            if let all = try? modelContext.fetch(FetchDescriptor<Invite>()) {
                                for obj in all { modelContext.delete(obj) }
                            }
                        } else if model == Classroom.self {
                            if let all = try? modelContext.fetch(FetchDescriptor<Classroom>()) {
                                for obj in all { modelContext.delete(obj) }
                            }
                        } else if model == Student.self {
                            if let all = try? modelContext.fetch(FetchDescriptor<Student>()) {
                                for obj in all { modelContext.delete(obj) }
                            }
                        } else if model == Organization.self {
                            if let all = try? modelContext.fetch(FetchDescriptor<Organization>()) {
                                for obj in all { modelContext.delete(obj) }
                            }
                        } else if model == Guide.self {
                            if let all = try? modelContext.fetch(FetchDescriptor<Guide>()) {
                                for obj in all { modelContext.delete(obj) }
                            }
                        }
                    }
                    try? modelContext.save()

                    // Route to Sign In
                    appVM.signOut()
                }.ptSecondary()

                Button("Load Demo Data") {
                    if let guide = appVM.currentGuide {
                        // Minimal in-place seeding: create demo org, class, students, and sample items
                        let org = Organization(name: "Demo School")
                        modelContext.insert(org)
                        _ = Membership(orgId: org.id, guideId: guide.id, role: .superAdmin)
                        let classroom = Classroom(name: "Demo Classroom")
                        classroom.orgId = org.id
                        modelContext.insert(classroom)
                        guide.defaultClassroomId = classroom.id
                        try? modelContext.save()

                        let names = [("Ava","M"),("Leo","S"),("Maya","K"),("Owen","R")]
                        var students: [Student] = []
                        for (f,l) in names {
                            let s = Student(firstName: f, lastName: l)
                            s.orgId = org.id
                            modelContext.insert(s)
                            students.append(s)
                            classroom.studentIds.append(s.id)
                        }
                        try? modelContext.save()

                        let obs = ObservationService()
                        let lessons = LessonService()
                        let tasks = TaskService()
                        let habits = HabitService()
                        for s in students {
                            _ = try? obs.create(primaryStudentId: s.id, content: "Focused on math materials for 20 minutes.", taggedStudentIds: [], subjectTag: "Math", materialTag: "Beads", appTag: nil, createdByGuideId: guide.id, context: modelContext)
                            _ = try? lessons.create(studentId: s.id, title: "Intro to Movable Alphabet", details: nil, scheduledFor: Date().addingTimeInterval(86400), guideId: guide.id, context: modelContext)
                            _ = try? tasks.create(studentId: s.id, title: "Prepare work tray", details: nil, scheduledFor: nil, guideId: guide.id, context: modelContext)
                            _ = try? habits.create(studentId: s.id, name: "Attendance", cadence: .daily, createdByGuideId: guide.id, context: modelContext)
                        }
                        try? modelContext.save()
                    }
                }.ptPrimary()
            }
        }
        .navigationTitle("Developer Tools")
        .scrollContentBackground(.hidden)
        .background(PTColors.surface)
    }
}


