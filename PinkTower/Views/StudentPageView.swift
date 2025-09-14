import SwiftUI
import SwiftData

struct StudentPageView: View {
    @EnvironmentObject private var appVM: AppViewModel
    @Environment(\.modelContext) private var modelContext
    let student: Student
    @StateObject private var vm: StudentPageViewModel
    @State private var showFilters: Bool = false
    @State private var aiPeriod: String = "Today"
    private let permission: PermissionServiceProtocol = PermissionService()

    init(student: Student) {
        self.student = student
        _vm = StateObject(wrappedValue: StudentPageViewModel(student: student))
    }

    var body: some View {
        ZStack(alignment: .center) {
            ScrollView {
                VStack(alignment: .leading, spacing: PTSpacing.l.rawValue) {
                    header
                    quickCapture
                    habits
                    observations
                    lessons
                    tasks
                    aiSkeleton
                }
                .padding(PTSpacing.l.rawValue)
            }
            .background(PTColors.surface)
            if vm.isSavingQuickCapture { ProgressView() }
        }
        .navigationTitle(student.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { vm.load(context: modelContext) }
        .sheet(isPresented: $showFilters) { filtersSheet }
    }

    private var header: some View {
        HStack(spacing: PTSpacing.m.rawValue) {
            PTAvatar(image: nil, size: 48, initials: initials(for: student.displayName))
            VStack(alignment: .leading, spacing: 4) {
                Text(student.displayName)
                    .font(PTTypography.subtitle)
                    .foregroundStyle(PTColors.textPrimary)
                Text("Student workspace")
                    .font(PTTypography.caption)
                    .foregroundStyle(PTColors.textSecondary)
            }
            Spacer()
        }
    }

    private var quickCapture: some View {
        Section {
            VStack(alignment: .leading, spacing: PTSpacing.m.rawValue) {
                Text("Quick Capture")
                    .font(PTTypography.body)
                    .foregroundStyle(PTColors.textPrimary)
                Picker("Type", selection: $vm.quickKind) {
                    ForEach(QuickCaptureKind.allCases) { kind in
                        Text(kind.rawValue.capitalized).tag(kind)
                    }
                }
                .pickerStyle(.segmented)
                TextField("What would you like to capture?", text: $vm.quickText, axis: .vertical)
                HStack(spacing: PTSpacing.m.rawValue) {
                    Button(vm.isSavingQuickCapture ? "Saving…" : "Save") {
                        vm.saveQuickCapture(guide: appVM.currentGuide, context: modelContext)
                    }
                    .buttonStyle(PTButtonStyle())
                    .disabled(!canCreate || vm.quickText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    Button(action: { vm.toggleRecording() }) {
                        Image(systemName: "mic")
                    }
                    Button("Transcribe") { Task { await vm.transcribeLatestRecording() } }
                        .disabled(!canCreate)
                }
            }
        }
    }

    private var habits: some View {
        Section {
            VStack(alignment: .leading, spacing: PTSpacing.s.rawValue) {
                Text("Habits")
                    .font(PTTypography.body)
                    .foregroundStyle(PTColors.textPrimary)
                ForEach(vm.habits) { habit in
                    HStack {
                        Text(habit.name)
                        Spacer()
                        Button {
                            vm.toggleHabitToday(habit, guide: appVM.currentGuide, context: modelContext)
                            Haptics.lightTap()
                        } label: {
                            Image(systemName: "checkmark.circle")
                        }
                        .disabled(!canCreate)
                    }
                }
            }
        }
    }

    private var observations: some View {
        Section {
            VStack(alignment: .leading, spacing: PTSpacing.s.rawValue) {
                Text("Observations")
                    .font(PTTypography.body)
                    .foregroundStyle(PTColors.textPrimary)
                HStack {
                    Button("Filters") { showFilters = true }
                    Spacer()
                    Button(action: { vm.observationSortNewestFirst.toggle(); vm.refreshObservations(context: modelContext) }) {
                        Image(systemName: vm.observationSortNewestFirst ? "arrow.down.circle" : "arrow.up.circle")
                    }
                }
                TextField("Search observations", text: $vm.observationSearch)
                    .onChange(of: vm.observationSearch) { _, _ in vm.refreshObservations(context: modelContext) }
                Toggle("Newest first", isOn: $vm.observationSortNewestFirst)
                    .onChange(of: vm.observationSortNewestFirst) { _, _ in vm.refreshObservations(context: modelContext) }
                ForEach(vm.observations) { obs in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(obs.content)
                            .foregroundStyle(PTColors.textPrimary)
                        Text(obs.createdAt.formatted(date: .abbreviated, time: .shortened))
                            .font(PTTypography.caption)
                            .foregroundStyle(PTColors.textSecondary)
                    }
                    .padding(.vertical, PTSpacing.s.rawValue)
                }
            }
        }
    }

    private var lessons: some View {
        Section {
            VStack(alignment: .leading, spacing: PTSpacing.s.rawValue) {
                Text("Lessons")
                    .font(PTTypography.body)
                    .foregroundStyle(PTColors.textPrimary)
                ForEach(vm.lessons) { lesson in
                    HStack {
                        Button(action: { vm.setLesson(lesson, completed: lesson.completedAt == nil, guide: appVM.currentGuide, context: modelContext) }) {
                            Image(systemName: lesson.completedAt == nil ? "circle" : "checkmark.circle.fill")
                        }
                        .disabled(!canCreate)
                        Text(lesson.title)
                        Spacer()
                        if let date = lesson.scheduledFor {
                            Text(date, style: .date)
                                .font(PTTypography.caption)
                                .foregroundStyle(PTColors.textSecondary)
                        }
                    }
                }
            }
        }
    }

    private var tasks: some View {
        Section {
            VStack(alignment: .leading, spacing: PTSpacing.s.rawValue) {
                Text("Tasks")
                    .font(PTTypography.body)
                    .foregroundStyle(PTColors.textPrimary)
                ForEach(vm.tasks) { task in
                    HStack {
                        Button(action: { vm.setTask(task, completed: task.completedAt == nil, guide: appVM.currentGuide, context: modelContext) }) {
                            Image(systemName: task.completedAt == nil ? "circle" : "checkmark.circle.fill")
                        }
                        .disabled(!canCreate)
                        Text(task.title)
                        Spacer()
                        if let date = task.scheduledFor {
                            Text(date, style: .date)
                                .font(PTTypography.caption)
                                .foregroundStyle(PTColors.textSecondary)
                        }
                    }
                }
            }
        }
    }

    private var aiSkeleton: some View {
        Section {
            VStack(alignment: .leading, spacing: PTSpacing.s.rawValue) {
                Text("AI")
                    .font(PTTypography.body)
                    .foregroundStyle(PTColors.textPrimary)
                Picker("Period", selection: $aiPeriod) {
                    Text("Today").tag("Today")
                    Text("This Week").tag("This Week")
                    Text("This Month").tag("This Month")
                }
                .pickerStyle(.segmented)
                HStack {
                    Button("Generate Insights") { /* hook to VM later */ }
                        .buttonStyle(PTButtonStyle())
                        .disabled(!canCreate)
                    Button("Generate Summary") { /* hook to VM later */ }
                        .buttonStyle(PTButtonStyle())
                        .disabled(!canCreate)
                }
            }
        }
    }

    private var canCreate: Bool {
        guard let guide = appVM.currentGuide else { return false }
        let gid = guide.id
        var descriptor = FetchDescriptor<Membership>(predicate: #Predicate { $0.guideId == gid })
        descriptor.fetchLimit = 1
        let role = (try? modelContext.fetch(descriptor).first?.role) ?? nil
        return permission.canCreateStudentContent(guide, orgRole: role)
    }

    private func initials(for name: String) -> String {
        let parts = name.split(separator: " ")
        let initials = parts.prefix(2).compactMap { $0.first }.map { String($0) }.joined()
        return initials.isEmpty ? "S" : initials
    }
}

#Preview {
    let student = Student(firstName: "Timmy", lastName: "Montessori")
    return NavigationStack { StudentPageView(student: student) }
}

private extension StudentPageView {
    var filtersSheet: some View {
        NavigationStack {
            Form {
                Section(header: PTSectionHeader(title: "Time Range")) {
                    DatePicker("Start", selection: Binding(get: { vm.filterStartDate ?? Date() }, set: { vm.filterStartDate = $0 }), displayedComponents: .date)
                    DatePicker("End", selection: Binding(get: { vm.filterEndDate ?? Date() }, set: { vm.filterEndDate = $0 }), displayedComponents: .date)
                }
                Section(header: PTSectionHeader(title: "Tags")) {
                    TextField("Subject", text: $vm.filterSubjectTag)
                    TextField("Material", text: $vm.filterMaterialTag)
                    TextField("App", text: $vm.filterAppTag)
                }
            }
            .navigationTitle("Filters")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { showFilters = false } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") { vm.refreshObservations(context: modelContext); showFilters = false }
                }
            }
        }
    }
}


