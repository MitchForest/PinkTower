import SwiftUI
import SwiftData

private enum StudentTab: CaseIterable, Hashable {
    case overview, observations, tasks, lessons, analytics, summaries

    var title: String {
        switch self {
        case .overview: return "Overview"
        case .observations: return "Observations"
        case .tasks: return "Tasks"
        case .lessons: return "Lessons"
        case .analytics: return "Analytics"
        case .summaries: return "Summaries"
        }
    }
}

struct StudentPageView: View {
    @EnvironmentObject private var appVM: AppViewModel
    @Environment(\.modelContext) private var modelContext
    let student: Student
    let compact: Bool
    var onOpenFullProfile: (() -> Void)?
    @StateObject private var vm: StudentPageViewModel
    @State private var showFilters: Bool = false
    @State private var aiPeriod: String = "Today"
    @State private var selectedTab: StudentTab = .overview
    @State private var showAddHabitSheet: Bool = false
    @State private var newHabitName: String = ""
    private let permission: PermissionServiceProtocol = PermissionService()

    init(student: Student, compact: Bool = false, onOpenFullProfile: (() -> Void)? = nil) {
        self.student = student
        self.compact = compact
        self.onOpenFullProfile = onOpenFullProfile
        _vm = StateObject(wrappedValue: StudentPageViewModel(student: student))
    }

    var body: some View {
        ZStack(alignment: .center) {
            ScrollView {
                VStack(alignment: .leading, spacing: PTSpacing.l.rawValue) {
                    // Use same header in both compact (sheet) and full page for consistency
                    header
                    tabs
                    Group {
                        switch selectedTab {
                        case .overview:
                            overview
                        case .observations:
                            observations
                        case .tasks:
                            tasks
                        case .lessons:
                            lessons
                        case .analytics:
                            analytics
                        case .summaries:
                            summaries
                        }
                    }
                }
                .padding(PTSpacing.l.rawValue)
            }
            .background(PTColors.surface)
            if vm.isSavingQuickCapture { ProgressView() }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            vm.load(context: modelContext)
            NotificationCenter.default.post(name: .init("EnterDetail"), object: nil)
        }
        .onDisappear {
            NotificationCenter.default.post(name: .init("ExitDetail"), object: nil)
        }
        .sheet(isPresented: $showFilters) { filtersSheet }
        .sheet(isPresented: $showAddHabitSheet) { addHabitSheet }
    }

    private var header: some View {
        HStack(spacing: PTSpacing.m.rawValue) {
            PTAvatar(image: nil, preset: .xl, initials: initials(for: student.displayName))
            VStack(alignment: .leading, spacing: 4) {
                Text(student.displayName)
                    .font(PTTypography.title)
                    .foregroundStyle(PTColors.textPrimary)
                Text("Student workspace")
                    .font(PTTypography.caption)
                    .foregroundStyle(PTColors.textSecondary)
            }
            Spacer()
        }
    }

    private var tabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PTSpacing.s.rawValue) {
                ForEach(StudentTab.allCases, id: \.self) { tab in
                    Button(action: { selectedTab = tab }) {
                        Text(tab.title)
                            .font(PTTypography.caption)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 14)
                            .frame(minHeight: 36)
                            .background(selectedTab == tab ? PTColors.accent : PTColors.surfaceSecondary)
                            .foregroundStyle(selectedTab == tab ? Color.white : PTColors.textPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: PTRadius.m.rawValue, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: PTRadius.m.rawValue, style: .continuous)
                                    .stroke(PTColors.border, lineWidth: selectedTab == tab ? 0 : 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, PTSpacing.s.rawValue)
        }
    }

    private var quickCapture: some View {
        Section {
            VStack(alignment: .leading, spacing: PTSpacing.m.rawValue) {
                Text("Quick Input")
                    .font(PTTypography.body)
                    .foregroundStyle(PTColors.textPrimary)
                HStack(spacing: PTSpacing.s.rawValue) {
                    Button(action: { showFilters = true }) {
                        HStack(spacing: 8) {
                            Text(vm.quickKind.rawValue.capitalized)
                                .foregroundStyle(PTColors.textPrimary)
                            Image(systemName: "chevron.down")
                                .foregroundStyle(PTColors.textSecondary)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(PTColors.surfaceSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: PTRadius.m.rawValue, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: PTRadius.m.rawValue, style: .continuous).stroke(PTColors.border, lineWidth: 1))
                    }
                    .buttonStyle(.plain)

                    ZStack {
                        TextField("What would you like to capture?", text: $vm.quickText, axis: .vertical)
                            .textFieldStyle(PTTextFieldStyle())
                            .overlay(alignment: .trailing) {
                                HStack(spacing: 8) {
                                    Button(action: { vm.toggleRecording() }) {
                                        Image(systemName: "mic.fill")
                                            .foregroundStyle(.white)
                                            .padding(8)
                                            .background(PTColors.accent)
                                            .clipShape(Circle())
                                    }
                                    .buttonStyle(.plain)

                                    Button(action: { vm.saveQuickCapture(guide: appVM.currentGuide, context: modelContext) }) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.white)
                                            .padding(8)
                                            .background(PTColors.accent)
                                            .clipShape(Circle())
                                    }
                                    .buttonStyle(.plain)
                                    .disabled(!canCreate || vm.quickText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                                }
                                .padding(.trailing, 8)
                            }
                    }
                }
            }
        }
    }

    // MARK: - Overview composites
    private var overview: some View {
        VStack(alignment: .leading, spacing: PTSpacing.l.rawValue) {
            quickCapture
            habitTracker
            overviewRecent
        }
    }

    private var habitTracker: some View {
        Section {
            VStack(alignment: .leading, spacing: PTSpacing.m.rawValue) {
                HStack {
                    Text("Habits")
                        .font(PTTypography.body)
                        .foregroundStyle(PTColors.textPrimary)
                    Spacer()
                    Button("Add Habit") { showAddHabitSheet = true }.ptSecondary().disabled(!canCreate)
                }
                let days = vm.weekDays.filter { Calendar.current.component(.weekday, from: $0) >= 2 && Calendar.current.component(.weekday, from: $0) <= 6 }
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: PTSpacing.s.rawValue) {
                        HStack(spacing: PTSpacing.m.rawValue) {
                            Text("")
                                .frame(width: 120, alignment: .leading)
                            ForEach(days, id: \.self) { d in
                                Text(shortWeekday(d))
                                    .font(PTTypography.caption)
                                    .foregroundStyle(PTColors.textSecondary)
                                    .frame(width: 28)
                            }
                        }
                        ForEach(vm.habits) { habit in
                            HStack(spacing: PTSpacing.m.rawValue) {
                                Text(habit.name)
                                    .frame(width: 120, alignment: .leading)
                                    .foregroundStyle(PTColors.textPrimary)
                                ForEach(days, id: \.self) { d in
                                    let done = vm.habitLogs[habit.id]?[Calendar.current.startOfDay(for: d)] ?? false
                                    Button(action: { vm.toggleHabit(habit, on: d, guide: appVM.currentGuide, context: modelContext) }) {
                                        Circle()
                                            .fill(done ? PTColors.accent : PTColors.surfaceSecondary)
                                            .frame(width: 24, height: 24)
                                            .overlay(Circle().stroke(PTColors.border, lineWidth: done ? 0 : 1))
                                            .overlay(
                                                Image(systemName: done ? "checkmark" : "")
                                                    .font(.system(size: 12, weight: .bold))
                                                    .foregroundStyle(.white)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                    .disabled(!canCreate)
                                }
                            }
                            .padding(.vertical, 6)
                            .background(PTColors.surfaceSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: PTRadius.m.rawValue, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: PTRadius.m.rawValue, style: .continuous).stroke(PTColors.border, lineWidth: 1))
                        }
                    }
                }
            }
        }
    }

    private var overviewRecent: some View {
        VStack(alignment: .leading, spacing: PTSpacing.l.rawValue) {
            Section {
                VStack(alignment: .leading, spacing: PTSpacing.s.rawValue) {
                    HStack {
                        Text("Recent Observations")
                            .font(PTTypography.body)
                            .foregroundStyle(PTColors.textPrimary)
                        Spacer()
                        Button("See all") { selectedTab = .observations }.ptQuiet()
                    }
                    ForEach(Array(vm.observations.prefix(3))) { obs in
                        NavigationLink(destination: ObservationDetailView(observation: obs)) {
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
            Section {
                VStack(alignment: .leading, spacing: PTSpacing.s.rawValue) {
                    HStack {
                        Text("Recent Lessons")
                            .font(PTTypography.body)
                            .foregroundStyle(PTColors.textPrimary)
                        Spacer()
                        Button("See all") { selectedTab = .lessons }.ptQuiet()
                    }
                    ForEach(Array(vm.lessons.prefix(3))) { lesson in
                        HStack {
                            Image(systemName: lesson.completedAt == nil ? "circle" : "checkmark.circle.fill")
                            Text(lesson.title)
                            Spacer()
                        }
                        .padding(.vertical, PTSpacing.s.rawValue)
                    }
                }
            }
            Section {
                VStack(alignment: .leading, spacing: PTSpacing.s.rawValue) {
                    HStack {
                        Text("Recent Tasks")
                            .font(PTTypography.body)
                            .foregroundStyle(PTColors.textPrimary)
                        Spacer()
                        Button("See all") { selectedTab = .tasks }.ptQuiet()
                    }
                    ForEach(Array(vm.tasks.prefix(3))) { task in
                        HStack {
                            Image(systemName: task.completedAt == nil ? "circle" : "checkmark.circle.fill")
                            Text(task.title)
                            Spacer()
                        }
                        .padding(.vertical, PTSpacing.s.rawValue)
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
                    .textFieldStyle(PTTextFieldStyle())
                    .onChange(of: vm.observationSearch) { _, _ in vm.refreshObservations(context: modelContext) }
                Toggle("Newest first", isOn: $vm.observationSortNewestFirst)
                    .onChange(of: vm.observationSortNewestFirst) { _, _ in vm.refreshObservations(context: modelContext) }
                ForEach(compact ? Array(vm.observations.prefix(5)) : vm.observations) { obs in
                    NavigationLink(destination: ObservationDetailView(observation: obs)) {
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
                if compact && vm.observations.count > 5 {
                    Button("See all observations") { onOpenFullProfile?() }.ptQuiet()
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
                ForEach(compact ? Array(vm.lessons.prefix(5)) : vm.lessons) { lesson in
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
                if compact && vm.lessons.count > 5 {
                    Button("See all lessons") { onOpenFullProfile?() }.ptQuiet()
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
                ForEach(compact ? Array(vm.tasks.prefix(5)) : vm.tasks) { task in
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
                if compact && vm.tasks.count > 5 {
                    Button("See all tasks") { onOpenFullProfile?() }.ptQuiet()
                }
            }
        }
    }

    private var analytics: some View {
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
                        .ptPrimary()
                        .disabled(!canCreate)
                    Button("Generate Summary") { /* hook to VM later */ }
                        .ptSecondary()
                        .disabled(!canCreate)
                }
            }
        }
    }

    private var summaries: some View {
        Section {
            VStack(alignment: .leading, spacing: PTSpacing.s.rawValue) {
                Text("Summaries")
                    .font(PTTypography.body)
                    .foregroundStyle(PTColors.textPrimary)
                Text("Generate and view saved summaries here.")
                    .foregroundStyle(PTColors.textSecondary)
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

    var addHabitSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: PTSpacing.m.rawValue) {
                Text("Add Habit")
                    .font(PTTypography.subtitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("Habit name", text: $newHabitName)
                    .textFieldStyle(PTTextFieldStyle())
                if !vm.popularHabits(context: modelContext).isEmpty {
                    Text("Suggestions")
                        .font(PTTypography.caption)
                        .foregroundStyle(PTColors.textSecondary)
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(vm.popularHabits(context: modelContext), id: \.self) { name in
                                Button(action: { newHabitName = name }) {
                                    HStack {
                                        Text(name)
                                            .foregroundStyle(PTColors.textPrimary)
                                        Spacer()
                                    }
                                    .padding(10)
                                    .background(PTColors.surfaceSecondary)
                                    .clipShape(RoundedRectangle(cornerRadius: PTRadius.m.rawValue, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                Spacer()
            }
            .padding(PTSpacing.l.rawValue)
            .navigationTitle("New Habit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { showAddHabitSheet = false } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        vm.addHabit(name: newHabitName, guide: appVM.currentGuide, context: modelContext)
                        newHabitName = ""
                        showAddHabitSheet = false
                    }.disabled(newHabitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !canCreate)
                }
            }
        }
    }

    func shortWeekday(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "E"
        return fmt.string(from: date)
    }
}


