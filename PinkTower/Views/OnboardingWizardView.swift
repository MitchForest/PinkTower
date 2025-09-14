import SwiftUI
import SwiftData

enum OnboardingStep: Int { case org = 0, classroom = 1, student = 2 }

final class OnboardingWizardViewModel: ObservableObject {
    @Published var step: OnboardingStep = .org
    @Published var orgName: String = ""
    @Published var orgEmoji: String = ""
    @Published var orgImageData: Data? = nil
    @Published var classroomName: String = ""
    @Published var classroomEmoji: String = ""
    @Published var classroomImageData: Data? = nil
    @Published var studentFirst: String = ""
    @Published var studentLast: String = ""
    @Published var studentEmoji: String = ""
    @Published var studentImageData: Data? = nil
    @Published var isWorking: Bool = false
    @Published var studentsAdded: Int = 0
    @Published var studentDrafts: [StudentDraft] = []

    func computeStep(context: ModelContext, guide: Guide?) {
        guard let guide = guide else { step = .org; return }
        let gid = guide.id
        let memberships = (try? context.fetch(FetchDescriptor<Membership>(predicate: #Predicate { $0.guideId == gid }))) ?? []
        guard let orgId = memberships.first?.orgId else { step = .org; return }
        let oid = orgId
        let rooms = (try? context.fetch(FetchDescriptor<Classroom>(predicate: #Predicate { $0.orgId == oid }))) ?? []
        if rooms.isEmpty { step = .classroom; return }
        let targetRoom = guide.defaultClassroomId.flatMap { id in rooms.first(where: { $0.id == id }) } ?? rooms.first!
        let studentIds = Set(targetRoom.studentIds)
        let students = (try? context.fetch(FetchDescriptor<Student>())) ?? []
        let hasStudent = students.contains(where: { studentIds.contains($0.id) })
        studentsAdded = hasStudent ? 1 : 0
        step = .student
    }
}

struct StudentDraft: Identifiable, Hashable {
    let id = UUID()
    var firstName: String
    var lastName: String
    var emoji: String
    var imageData: Data?
}

struct OnboardingWizardView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appVM: AppViewModel
    @Environment(\.editMode) private var editMode
    @StateObject private var vm = OnboardingWizardViewModel()

    private let orgs: OrgServiceProtocol = OrgService()
    private let memberships: MembershipServiceProtocol = MembershipService()
    private let classrooms: ClassroomServiceProtocol = ClassroomService()
    private let students: StudentServiceProtocol = StudentService()

    var body: some View {
        ZStack {
            PTColors.surface
            VStack(spacing: PTSpacing.l.rawValue) {
                Spacer(minLength: PTSpacing.l.rawValue)
                Group {
                    switch vm.step {
                    case .org: orgStep
                    case .classroom: classroomStep
                    case .student: studentStep
                    }
                }
                .animation(PTMotion.easeInOutSoft, value: vm.step)
                if vm.step != .student { controls }
                if vm.step != .student { stepHeader }
                Spacer(minLength: PTSpacing.l.rawValue)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, PTSpacing.xl.rawValue)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { vm.computeStep(context: modelContext, guide: appVM.currentGuide); prefillIfExistingMembership() }
    }

    private var stepHeader: some View {
        HStack(spacing: PTSpacing.m.rawValue) {
            ForEach(0..<3) { i in
                Capsule()
                    .fill(i <= vm.step.rawValue ? PTColors.accent : PTColors.border)
                    .frame(width: 60, height: 4)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Step \(vm.step.rawValue + 1) of 3")
    }

    private var orgStep: some View {
        VStack(spacing: PTSpacing.l.rawValue) {
            Text("Create your school").font(PTTypography.display).foregroundStyle(PTColors.textPrimary)
            HStack(spacing: PTSpacing.m.rawValue) {
                PTInput(placeholder: "School name", text: $vm.orgName)
                PTAvatarSelector(emoji: $vm.orgEmoji, imageData: $vm.orgImageData)
            }
            .frame(maxWidth: 520)
        }
    }

    private var classroomStep: some View {
        VStack(spacing: PTSpacing.l.rawValue) {
            Text("Create your first classroom").font(PTTypography.display).foregroundStyle(PTColors.textPrimary)
            HStack(spacing: PTSpacing.m.rawValue) {
                PTInput(placeholder: "Classroom name", text: $vm.classroomName)
                PTAvatarSelector(emoji: $vm.classroomEmoji, imageData: $vm.classroomImageData)
            }
            .frame(maxWidth: 520)
        }
    }

    private var studentStep: some View {
        VStack(spacing: PTSpacing.l.rawValue) {
            GeometryReader { geo in
                ScrollView {
                    VStack(spacing: PTSpacing.l.rawValue) {
                        Text(vm.studentDrafts.isEmpty ? "Add your first student" : "Add students")
                            .font(PTTypography.display)
                            .foregroundStyle(PTColors.textPrimary)

                        ForEach($vm.studentDrafts) { $draft in
                            HStack(spacing: PTSpacing.m.rawValue) {
                                PTInput(placeholder: "First name", text: $draft.firstName)
                                PTInput(placeholder: "Last name", text: $draft.lastName)
                                PTAvatarSelector(emoji: $draft.emoji, imageData: $draft.imageData)
                            }
                        }

                        Button(action: { addStudentDraft() }) {
                            Text("Add student")
                                .underline()
                                .foregroundStyle(PTColors.accent)
                        }
                        .buttonStyle(.plain)

                        controls

                        stepHeader
                    }
                    .frame(maxWidth: 640)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, PTSpacing.xl.rawValue)
                    .padding(.bottom, PTSpacing.l.rawValue)
                    .frame(minHeight: geo.size.height, alignment: .center)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(PTColors.surface)
        }
        .onAppear {
            if vm.studentDrafts.isEmpty {
                vm.studentDrafts.append(StudentDraft(firstName: "", lastName: "", emoji: "", imageData: nil))
                vm.studentsAdded = vm.studentDrafts.count
            }
        }
    }

    // MARK: - Controls
    private var controls: some View {
        HStack(spacing: PTSpacing.m.rawValue) {
            Button("Back") { goBack() }
                .ptPrimary()
                .disabled(vm.step == .org || vm.isWorking)
            Button(primaryButtonTitle()) { primaryAction() }
                .ptPrimary()
                .disabled(primaryDisabled())
        }
    }

    private func primaryButtonTitle() -> String {
        switch vm.step {
        case .org: return vm.isWorking ? "Next…" : "Next"
        case .classroom: return vm.isWorking ? "Next…" : "Next"
        case .student: return vm.isWorking ? "Finishing…" : "Finish"
        }
    }

    private func primaryDisabled() -> Bool {
        switch vm.step {
        case .org:
            return vm.orgName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.isWorking
        case .classroom:
            return vm.classroomName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.isWorking
        case .student:
            // Validation rule: each child requires First name and at least Last initial
            let allValid = vm.studentDrafts.allSatisfy {
                let first = $0.firstName.trimmingCharacters(in: .whitespacesAndNewlines)
                let last = $0.lastName.trimmingCharacters(in: .whitespacesAndNewlines)
                return !first.isEmpty && !last.isEmpty
            }
            return vm.isWorking || vm.studentDrafts.isEmpty || !allValid
        }
    }

    private func goBack() {
        switch vm.step {
        case .org: break
        case .classroom: vm.step = .org
        case .student: vm.step = .classroom
        }
    }

    private func primaryAction() {
        switch vm.step {
        case .org:
            vm.step = .classroom
        case .classroom:
            vm.step = .student
        case .student:
            // Capture any in-progress student into drafts before finishing
            if !vm.studentFirst.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !vm.studentLast.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                vm.studentDrafts.append(StudentDraft(firstName: vm.studentFirst.trimmingCharacters(in: .whitespacesAndNewlines), lastName: vm.studentLast.trimmingCharacters(in: .whitespacesAndNewlines), emoji: vm.studentEmoji, imageData: vm.studentImageData))
                vm.studentFirst = ""; vm.studentLast = ""; vm.studentEmoji = ""; vm.studentImageData = nil
            }
            finishSetup()
        }
    }

    // MARK: - Persistence helpers

    private func addStudentDraft() {
        vm.studentDrafts.append(StudentDraft(firstName: "", lastName: "", emoji: "", imageData: nil))
        vm.studentsAdded = vm.studentDrafts.count
    }

    private func deleteStudents(at offsets: IndexSet) {
        vm.studentDrafts.remove(atOffsets: offsets)
        vm.studentsAdded = vm.studentDrafts.count
    }

    private func moveStudents(from source: IndexSet, to destination: Int) { }

    private func prefillIfExistingMembership() {
        guard let guide = appVM.currentGuide else { return }
        let gid = guide.id
        let memberships = (try? modelContext.fetch(FetchDescriptor<Membership>(predicate: #Predicate { $0.guideId == gid }))) ?? []
        if !memberships.isEmpty {
            // Prefill org name if exists
            if let orgId = memberships.first?.orgId,
               let org = try? modelContext.fetch(FetchDescriptor<Organization>(predicate: #Predicate { $0.id == orgId })).first {
                vm.orgName = org.name
            }
        }
    }

    private func finishSetup() {
        guard let guide = appVM.currentGuide else { return }
        let trimmedOrg = vm.orgName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedClass = vm.classroomName.trimmingCharacters(in: .whitespacesAndNewlines)

        // Require classroom and at least one student (typed or draft)
        guard !trimmedClass.isEmpty else { return }
        let hasAnyStudent = !vm.studentDrafts.isEmpty || (!vm.studentFirst.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !vm.studentLast.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        guard hasAnyStudent else { return }

        vm.isWorking = true
        defer { vm.isWorking = false }

        // Determine org: create if no memberships; otherwise use existing org
        let currentGuideId: UUID = guide.id
        let existingMemberships = (try? modelContext.fetch(FetchDescriptor<Membership>(predicate: #Predicate { $0.guideId == currentGuideId }))) ?? []
        var orgIdToUse: UUID?
        if let firstMembership = existingMemberships.first {
            orgIdToUse = firstMembership.orgId
        } else {
            guard !trimmedOrg.isEmpty else { return }
            if let created = try? orgs.create(name: trimmedOrg, context: modelContext) {
                _ = try? memberships.add(guideId: guide.id, role: .superAdmin, to: created.id, context: modelContext)
                orgIdToUse = created.id
            }
        }

        // Create classroom
        var classroom: Classroom?
        if let room = try? classrooms.create(name: trimmedClass, imageURL: nil, context: modelContext) {
            if let oid = orgIdToUse { room.orgId = oid; try? modelContext.save() }
            classroom = room
            appVM.selectedClassroomId = room.id
            guide.defaultClassroomId = room.id
            try? modelContext.save()
        }

        // Create students and assign (only valid rows)
        if let room = classroom {
            for draft in vm.studentDrafts where !draft.firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !draft.lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                if let student = try? students.create(firstName: draft.firstName, lastName: draft.lastName, imageURL: nil, context: modelContext) {
                    if let oid = orgIdToUse { student.orgId = oid }
                    try? modelContext.save()
                    try? classrooms.assign(student: student, to: room, context: modelContext)
                }
            }
        }

        Haptics.success()
        appVM.recalcRoute(context: modelContext)
    }
}


