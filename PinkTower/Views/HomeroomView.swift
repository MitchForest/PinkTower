import SwiftUI
import SwiftData

struct HomeroomView: View {
    @EnvironmentObject private var appVM: AppViewModel
    @Environment(\.modelContext) private var modelContext
    @Query private var students: [Student]
    @State private var showCreateStudent = false
    @State private var showStudentSheet = false
    @State private var selectedStudent: Student?
    @State private var navigateToStudent: Student?
    @State private var actionStudent: Student?

    init() {
        // Query will be adjusted at runtime via filter when we have a classroom id
        _students = Query()
    }

    var body: some View {
        NavigationStack {
        PTScreen {
        FloatingActionButtonContainer(content: {
            if filteredStudents().isEmpty {
                PTEmptyState(
                    title: "Add your first student",
                    message: "Students appear here for quick access.",
                    primaryTitle: "Add student",
                    primaryAction: { showCreateStudent = true }
                )
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: PTSpacing.l.rawValue)], spacing: PTSpacing.l.rawValue) {
                        let list = filteredStudents()
                        let tileSize = gridTileSize(for: list.count)
                        ForEach(list) { student in
                            Button(action: {
                                selectedStudent = student
                                // Delay toggling to next runloop to ensure content is ready (avoids blank first render on iPad)
                                DispatchQueue.main.async { showStudentSheet = true }
                            }) {
                                PTGridTile(
                                    title: student.displayName,
                                    initials: initials(for: student.displayName),
                                    image: nil,
                                    size: tileSize
                                )
                            }
                            .simultaneousGesture(LongPressGesture(minimumDuration: 0.4).onEnded { _ in actionStudent = student })
                        }
                    }
                    .padding(.horizontal, PTSpacing.l.rawValue)
                    // Top spacing handled by PTScreen inset
                    .padding(.bottom, PTSpacing.l.rawValue)
                }
            }
        }, button: PTFloatingActionButton(systemImage: "plus", action: { showCreateStudent = true }))
        }
        .ptModal(item: $actionStudent) { student in
            VStack(alignment: .leading, spacing: PTSpacing.m.rawValue) {
                Text(student.displayName)
                    .font(PTTypography.title)
                    .foregroundStyle(PTColors.textPrimary)
                Button("Edit") {
                    actionStudent = nil
                    navigateToStudent = student
                }
                .ptSecondary()
                Button("Delete", role: .destructive) {
                    // Hook to deletion flow (role gated)
                    actionStudent = nil
                }
                .ptPrimary()
            }
            .frame(maxWidth: 420)
        }
        .ptModal(item: $selectedStudent) { student in
            VStack(spacing: PTSpacing.m.rawValue) {
                HStack(spacing: PTSpacing.m.rawValue) {
                    PTAvatar(image: nil, preset: .xl, initials: initials(for: student.displayName))
                    VStack(alignment: .leading, spacing: 6) {
                        Text(student.displayName).font(PTTypography.title).foregroundStyle(PTColors.textPrimary)
                        if let cname = currentClassroomName() {
                            Text(cname).font(PTTypography.body).foregroundStyle(PTColors.textSecondary)
                        }
                    }
                    Spacer()
                    Button("Open full profile") {
                        selectedStudent = nil
                        navigateToStudent = student
                    }.ptSecondary()
                }
                .padding(.bottom, PTSpacing.m.rawValue)
                Divider()
                StudentPageView(student: student, compact: true, onOpenFullProfile: {
                    selectedStudent = nil
                    navigateToStudent = student
                })
                .background(PTColors.surface)
            }
        }
        .sheet(isPresented: $showCreateStudent) {
            CreateStudentSheet(onCreated: { _ in Haptics.success() })
                .accessibilityElement(children: .contain)
        }
        .navigationDestination(item: $navigateToStudent) { s in
            StudentPageView(student: s)
        }
        .onReceive(NotificationCenter.default.publisher(for: .init("PopStudentDetail"))) { _ in
            navigateToStudent = nil
        }
        }
    }

    private func filteredStudents() -> [Student] {
        guard let classroomId = appVM.selectedClassroomId else { return [] }
        var descriptor = FetchDescriptor<Classroom>(predicate: #Predicate { $0.id == classroomId })
        descriptor.fetchLimit = 1
        if let classroom = try? modelContext.fetch(descriptor).first {
            let ids = Set(classroom.studentIds)
            return students.filter { ids.contains($0.id) }
        }
        return []
    }

    private func initials(for name: String) -> String {
        let parts = name.split(separator: " ")
        let initials = parts.prefix(2).compactMap { $0.first }.map { String($0) }.joined()
        return initials.isEmpty ? "S" : initials
    }

    private func gridTileSize(for count: Int) -> PTGridTileSize {
        if count <= 8 { return .large }
        if count <= 24 { return .medium }
        return .compact
    }

    private func currentClassroomName() -> String? {
        guard let id = appVM.selectedClassroomId else { return nil }
        var descriptor = FetchDescriptor<Classroom>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try? modelContext.fetch(descriptor).first?.name
    }
}


