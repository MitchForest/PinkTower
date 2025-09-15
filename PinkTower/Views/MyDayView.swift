import SwiftUI
import SwiftData
import Foundation

enum MyDayPeriod: String, CaseIterable, Identifiable { case day, week; var id: String { rawValue } }

struct StudentStatus: Identifiable {
    let student: Student
    let hasObservation: Bool
    let summarySent: Bool
    let habitPercent: Double
    var id: UUID { student.id }
}

final class MyDayViewModel: ObservableObject {
    @Published var period: MyDayPeriod = .day
    @Published var range: ClosedRange<Date> = {
        let start = Calendar.current.startOfDay(for: Date())
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!.addingTimeInterval(-1)
        return start...end
    }()
    @Published var tasks: [TaskItem] = []
    @Published var lessons: [Lesson] = []
    @Published var studentStatuses: [StudentStatus] = []

    func setPeriod(_ p: MyDayPeriod) {
        period = p
        range = Self.periodRange(p)
    }

    // MARK: - Quick actions
    func completeTask(_ task: TaskItem, guide: Guide, context: ModelContext) {
        do {
            try TaskService().setCompleted(task, completed: true, guideId: guide.id, context: context)
            Haptics.success()
            load(context: context, guide: guide)
        } catch { }
    }

    func completeLesson(_ lesson: Lesson, guide: Guide, context: ModelContext) {
        do {
            try LessonService().setCompleted(lesson, completed: true, guideId: guide.id, context: context)
            Haptics.success()
            load(context: context, guide: guide)
        } catch { }
    }

    func markSummarySent(for student: Student, guide: Guide, context: ModelContext) {
        do {
            let periodKind: ParentSummaryPeriod = (period == .day) ? .day : .week
            _ = try SharingService().logParentSummary(studentId: student.id, period: periodKind, guideId: guide.id, context: context)
            Haptics.success()
            load(context: context, guide: guide)
        } catch { }
    }

    func completeDailyHabits(for student: Student, guide: Guide, context: ModelContext) {
        do {
            let sid = student.id
            let habits = (try? context.fetch(FetchDescriptor<Habit>(predicate: #Predicate { $0.studentId == sid }))) ?? []
            let daily = habits.filter { $0.cadence == .daily }
            let today = Calendar.current.startOfDay(for: Date())
            for habit in daily {
                let hid = habit.id
                let logs = (try? context.fetch(FetchDescriptor<HabitLog>(predicate: #Predicate { $0.habitId == hid }))) ?? []
                let alreadyDone = logs.contains { Calendar.current.isDate($0.date, inSameDayAs: today) && $0.isDone }
                if !alreadyDone {
                    _ = try? HabitService().toggleToday(habit: habit, guideId: guide.id, context: context)
                }
            }
            Haptics.success()
            load(context: context, guide: guide)
        }
    }

    func load(context: ModelContext, guide: Guide?) {
        guard let guide = guide else { return }
        let rooms = (try? context.fetch(FetchDescriptor<Classroom>())) ?? []
        let assigned = rooms.filter { $0.guideIds.contains(guide.id) }
        let studentIds = Array(Set(assigned.flatMap { $0.studentIds }))
        let students: [Student] = studentIds.compactMap { sid in
            (try? context.fetch(FetchDescriptor<Student>(predicate: #Predicate { $0.id == sid })))?.first
        }

        var collectedTasks: [TaskItem] = []
        var collectedLessons: [Lesson] = []
        var statuses: [StudentStatus] = []

        for s in students {
            let sid = s.id
            let sTasks = (try? context.fetch(FetchDescriptor<TaskItem>(predicate: #Predicate { $0.studentId == sid }))) ?? []
            collectedTasks.append(contentsOf: sTasks.filter { task in
                guard task.completedAt == nil else { return false }
                guard let due = task.scheduledFor else { return true }
                return range.contains(due)
            })

            let sLessons = (try? context.fetch(FetchDescriptor<Lesson>(predicate: #Predicate { $0.studentId == sid }))) ?? []
            collectedLessons.append(contentsOf: sLessons.filter { lesson in
                guard lesson.completedAt == nil else { return false }
                guard let due = lesson.scheduledFor else { return true }
                return range.contains(due)
            })

            let observations = (try? context.fetch(FetchDescriptor<StudentObservation>(predicate: #Predicate { $0.primaryStudentId == sid }))) ?? []
            let hasObs = observations.contains { range.contains($0.createdAt) }

            let periodKind: ParentSummaryPeriod = (period == .day) ? .day : .week
            let summarySent = ((try? SharingService().hasLoggedParentSummary(studentId: sid, period: periodKind, on: Date(), context: context)) ?? false)

            let habits = (try? context.fetch(FetchDescriptor<Habit>(predicate: #Predicate { $0.studentId == sid }))) ?? []
            let daily = habits.filter { $0.cadence == .daily }
            var percent: Double = 0
            if !daily.isEmpty {
                switch period {
                case .day:
                    var doneCount = 0
                    for habit in daily {
                        let hid = habit.id
                        let hLogs = (try? context.fetch(FetchDescriptor<HabitLog>(predicate: #Predicate { $0.habitId == hid && $0.isDone }))) ?? []
                        let todays = hLogs.filter { Calendar.current.isDate($0.date, inSameDayAs: range.lowerBound) }
                        if !todays.isEmpty { doneCount += 1 }
                    }
                    percent = Double(doneCount) / Double(daily.count)
                case .week:
                    let cal = Calendar.current
                    let start = range.lowerBound
                    let end = min(range.upperBound, Date())
                    let days = cal.dateComponents([.day], from: cal.startOfDay(for: start), to: cal.startOfDay(for: end)).day ?? 0
                    let denom = Double(max(1, days + 1) * daily.count)
                    var totalDone = 0
                    let startDay = cal.startOfDay(for: start)
                    let endDay = cal.startOfDay(for: end)
                    for habit in daily {
                        let hid = habit.id
                        let hLogs = (try? context.fetch(FetchDescriptor<HabitLog>(predicate: #Predicate { $0.habitId == hid && $0.isDone }))) ?? []
                        let inWeek = hLogs.filter { $0.date >= startDay && $0.date <= endDay }
                        totalDone += inWeek.count
                    }
                    percent = denom > 0 ? Double(totalDone) / denom : 0
                }
            }

            statuses.append(StudentStatus(student: s, hasObservation: hasObs, summarySent: summarySent, habitPercent: percent))
        }

        collectedTasks.sort { ($0.scheduledFor ?? $0.createdAt) < ($1.scheduledFor ?? $1.createdAt) }
        collectedLessons.sort { ($0.scheduledFor ?? $0.createdAt) < ($1.scheduledFor ?? $1.createdAt) }
        statuses.sort { $0.habitPercent < $1.habitPercent }

        DispatchQueue.main.async {
            self.tasks = collectedTasks
            self.lessons = collectedLessons
            self.studentStatuses = statuses
        }
    }

    private static func periodRange(_ p: MyDayPeriod) -> ClosedRange<Date> {
        let cal = Calendar.current
        switch p {
        case .day:
            let start = cal.startOfDay(for: Date())
            let end = cal.date(byAdding: .day, value: 1, to: start)!.addingTimeInterval(-1)
            return start...end
        case .week:
            let now = Date()
            let start = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) ?? cal.startOfDay(for: now)
            let end = cal.date(byAdding: .day, value: 7, to: start)!.addingTimeInterval(-1)
            return start...end
        }
    }
}

struct MyDayView: View {
    @EnvironmentObject private var appVM: AppViewModel
    @Environment(\.modelContext) private var modelContext
    @StateObject private var vm = MyDayViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PTSpacing.l.rawValue) {
                Picker("Period", selection: $vm.period) {
                    Text("Today").tag(MyDayPeriod.day)
                    Text("This Week").tag(MyDayPeriod.week)
                }
                .pickerStyle(.segmented)
                .onChange(of: vm.period) { _, new in
                    vm.setPeriod(new)
                    vm.load(context: modelContext, guide: appVM.currentGuide)
                }

                if !vm.tasks.isEmpty {
                    sectionHeader(vm.period == .day ? "Tasks for Today" : "Tasks This Week")
                    ForEach(vm.tasks.prefix(8)) { task in
                        HStack {
                            Image(systemName: "checklist")
                            Text(task.title).foregroundStyle(PTColors.textPrimary)
                            Spacer()
                            if let due = task.scheduledFor { Text(shortDate(due)).foregroundStyle(PTColors.textSecondary) }
                            if let guide = appVM.currentGuide {
                                Button(action: { vm.completeTask(task, guide: guide, context: modelContext) }) {
                                    Image(systemName: "checkmark.circle")
                                        .foregroundStyle(PTColors.accent)
                                }
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                                .buttonStyle(.plain)
                            }
                        }
                        .font(PTTypography.body)
                    }
                }

                if !vm.lessons.isEmpty {
                    sectionHeader(vm.period == .day ? "Lessons for Today" : "Lessons This Week")
                    ForEach(vm.lessons.prefix(8)) { lesson in
                        HStack {
                            Image(systemName: "book")
                            Text(lesson.title).foregroundStyle(PTColors.textPrimary)
                            Spacer()
                            if let due = lesson.scheduledFor { Text(shortDate(due)).foregroundStyle(PTColors.textSecondary) }
                            if let guide = appVM.currentGuide {
                                Button(action: { vm.completeLesson(lesson, guide: guide, context: modelContext) }) {
                                    Image(systemName: "checkmark.circle")
                                        .foregroundStyle(PTColors.accent)
                                }
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                                .buttonStyle(.plain)
                            }
                        }
                        .font(PTTypography.body)
                    }
                }

                if !vm.studentStatuses.isEmpty {
                    sectionHeader(vm.period == .day ? "Students — Today" : "Students — This Week")
                    ForEach(vm.studentStatuses.prefix(20)) { status in
                        HStack(spacing: PTSpacing.m.rawValue) {
                            PTAvatar(image: nil, preset: .xs, initials: initials(for: status.student.displayName))
                            Text(status.student.displayName).foregroundStyle(PTColors.textPrimary)
                            Spacer()
                            Image(systemName: status.hasObservation ? "doc.text.fill" : "doc.text")
                                .foregroundStyle(status.hasObservation ? PTColors.accent : PTColors.textSecondary)
                            Image(systemName: status.summarySent ? "envelope.fill" : "envelope")
                                .foregroundStyle(status.summarySent ? PTColors.accent : PTColors.textSecondary)
                            Text("\(Int((status.habitPercent * 100).rounded()))%")
                                .foregroundStyle(PTColors.textSecondary)
                            if let guide = appVM.currentGuide {
                                Button(action: { vm.markSummarySent(for: status.student, guide: guide, context: modelContext) }) {
                                    Image(systemName: "paperplane")
                                }
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                                .buttonStyle(.plain)
                                Button(action: { vm.completeDailyHabits(for: status.student, guide: guide, context: modelContext) }) {
                                    Image(systemName: "checkmark.circle")
                                }
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                                .buttonStyle(.plain)
                            }
                        }
                        .font(PTTypography.body)
                    }
                }
            }
            .padding(PTSpacing.l.rawValue)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PTColors.surface)
        .onAppear {
            vm.setPeriod(.day)
            vm.load(context: modelContext, guide: appVM.currentGuide)
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(PTTypography.title)
            .foregroundStyle(PTColors.textPrimary)
    }

    private func shortDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .none
        f.timeStyle = .short
        return f.string(from: date)
    }

    private func initials(for fullName: String) -> String {
        let parts = fullName.split(separator: " ")
        let first = parts.first?.prefix(1) ?? ""
        let last = parts.dropFirst().first?.prefix(1) ?? ""
        return String(first + last)
    }
}

