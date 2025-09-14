import Foundation
import SwiftUI
import SwiftData

enum QuickCaptureKind: String, CaseIterable, Identifiable {
    case observation
    case lesson
    case task
    var id: String { rawValue }
}

@MainActor
final class StudentPageViewModel: ObservableObject {
    @Published var quickKind: QuickCaptureKind = .observation
    @Published var quickText: String = ""

    @Published var habits: [Habit] = []
    @Published var observations: [StudentObservation] = []
    @Published var lessons: [Lesson] = []
    @Published var tasks: [TaskItem] = []

    @Published var observationSearch: String = ""
    @Published var observationSortNewestFirst: Bool = true
    @Published var filterSubjectTag: String = ""
    @Published var filterMaterialTag: String = ""
    @Published var filterAppTag: String = ""
    @Published var filterStartDate: Date? = nil
    @Published var filterEndDate: Date? = nil

    @Published var isSavingQuickCapture = false
    @Published var errorMessage: String?

    let student: Student

    private let observationService: ObservationServiceProtocol
    private let habitService: HabitServiceProtocol
    private let lessonService: LessonServiceProtocol
    private let taskService: TaskServiceProtocol
    private let configService: ConfigServiceProtocol = ConfigService()
    private let aiService: AIServiceProtocol = AIService()
    private let recorder: AudioRecorderServiceProtocol = AudioRecorderService()

    init(
        student: Student,
        observationService: ObservationServiceProtocol = ObservationService(),
        habitService: HabitServiceProtocol = HabitService(),
        lessonService: LessonServiceProtocol = LessonService(),
        taskService: TaskServiceProtocol = TaskService()
    ) {
        self.student = student
        self.observationService = observationService
        self.habitService = habitService
        self.lessonService = lessonService
        self.taskService = taskService
    }

    func load(context: ModelContext) {
        do {
            habits = try habitService.list(for: student.id, context: context)
            observations = try observationService.list(ObservationQuery(studentId: student.id), context: context)
            lessons = try lessonService.list(for: student.id, context: context)
            tasks = try taskService.list(for: student.id, context: context)
        } catch {
            errorMessage = "Failed to load data"
        }
    }

    func refreshObservations(context: ModelContext) {
        do {
            var q = ObservationQuery(studentId: student.id)
            q.search = observationSearch.isEmpty ? nil : observationSearch
            q.sortNewestFirst = observationSortNewestFirst
            if !filterSubjectTag.isEmpty { q.subjectTag = filterSubjectTag }
            if !filterMaterialTag.isEmpty { q.materialTag = filterMaterialTag }
            if !filterAppTag.isEmpty { q.appTag = filterAppTag }
            if let start = filterStartDate, let end = filterEndDate, start <= end {
                q.dateRange = start...end
            } else if let start = filterStartDate {
                q.dateRange = start...Date()
            }
            observations = try observationService.list(q, context: context)
        } catch {
            errorMessage = "Failed to refresh observations"
        }
    }

    func saveQuickCapture(guide: Guide?, context: ModelContext) {
        guard !quickText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard let guide = guide else { return }
        isSavingQuickCapture = true
        defer { isSavingQuickCapture = false }
        do {
            switch quickKind {
            case .observation:
                _ = try observationService.create(primaryStudentId: student.id, content: quickText, taggedStudentIds: [], subjectTag: nil, materialTag: nil, appTag: nil, createdByGuideId: guide.id, context: context)
                refreshObservations(context: context)
            case .lesson:
                _ = try lessonService.create(studentId: student.id, title: quickText, details: nil, scheduledFor: nil, guideId: guide.id, context: context)
                lessons = try lessonService.list(for: student.id, context: context)
            case .task:
                _ = try taskService.create(studentId: student.id, title: quickText, details: nil, scheduledFor: nil, guideId: guide.id, context: context)
                tasks = try taskService.list(for: student.id, context: context)
            }
            quickText = ""
        } catch {
            errorMessage = "Failed to save"
        }
    }

    func toggleRecording() {
        if recorder.isRecording {
            _ = recorder.stop()
        } else {
            try? recorder.start()
        }
    }

    func transcribeLatestRecording() async {
        guard let url = (recorder as? AudioRecorderService)?.stop() else { return }
        do {
            let text = try await aiService.transcribeAudio(url: url, apiKey: configService.openAIAPIKey())
            await MainActor.run { self.quickText += (self.quickText.isEmpty ? "" : "\n") + text }
        } catch {
            await MainActor.run { self.errorMessage = "Transcription failed" }
        }
    }

    func generateSummary(periodLabel: String, contextText: String) async -> String? {
        do {
            return try await aiService.generateSummary(for: student.id, periodLabel: periodLabel, contextText: contextText, apiKey: configService.openAIAPIKey())
        } catch { return nil }
    }

    func generateInsights(periodLabel: String, contextText: String) async -> [String] {
        do {
            return try await aiService.generateInsights(for: student.id, periodLabel: periodLabel, contextText: contextText, apiKey: configService.openAIAPIKey())
        } catch { return [] }
    }

    func toggleHabitToday(_ habit: Habit, guide: Guide?, context: ModelContext) {
        guard let guide = guide else { return }
        _ = try? habitService.toggleToday(habit: habit, guideId: guide.id, context: context)
    }

    func setLesson(_ lesson: Lesson, completed: Bool, guide: Guide?, context: ModelContext) {
        guard let guide = guide else { return }
        try? lessonService.setCompleted(lesson, completed: completed, guideId: guide.id, context: context)
        lessons = (try? lessonService.list(for: student.id, context: context)) ?? lessons
    }

    func setTask(_ task: TaskItem, completed: Bool, guide: Guide?, context: ModelContext) {
        guard let guide = guide else { return }
        try? taskService.setCompleted(task, completed: completed, guideId: guide.id, context: context)
        tasks = (try? taskService.list(for: student.id, context: context)) ?? tasks
    }
}


