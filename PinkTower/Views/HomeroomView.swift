import SwiftUI
import SwiftData

struct HomeroomView: View {
    @EnvironmentObject private var appVM: AppViewModel
    @Environment(\.modelContext) private var modelContext
    @Query private var students: [Student]
    @State private var showCreateStudent = false
    @State private var showStudentSheet = false
    @State private var selectedStudent: Student?

    init() {
        // Query will be adjusted at runtime via filter when we have a classroom id
        _students = Query()
    }

    var body: some View {
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
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: PTSpacing.l.rawValue)], spacing: PTSpacing.l.rawValue) {
                        ForEach(filteredStudents()) { student in
                            Button(action: {
                                selectedStudent = student
                                showStudentSheet = true
                            }) {
                                VStack(spacing: PTSpacing.s.rawValue) {
                                    PTAvatar(image: nil, size: 64, initials: initials(for: student.displayName))
                                    Text(student.displayName)
                                        .font(PTTypography.body)
                                        .foregroundStyle(PTColors.textPrimary)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .contextMenu {
                                Button("Edit") { /* future edit */ }
                                Button("Delete", role: .destructive) { /* gated delete */ }
                            }
                        }
                    }
                    .padding(PTSpacing.l.rawValue)
                }
            }
        }, button: PTFloatingActionButton(systemImage: "plus", action: { showCreateStudent = true }))
        .ptBottomSheet(isPresented: $showStudentSheet) {
            if let selectedStudent = selectedStudent {
                StudentPageView(student: selectedStudent)
            }
        }
        .sheet(isPresented: $showCreateStudent) {
            CreateStudentSheet(onCreated: { _ in Haptics.success() })
                .accessibilityElement(children: .contain)
        }
        .background(PTColors.surface)
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
}


