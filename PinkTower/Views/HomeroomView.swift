import SwiftUI
import SwiftData

struct HomeroomView: View {
    @EnvironmentObject private var appVM: AppViewModel
    @Environment(\.modelContext) private var modelContext
    @Query private var students: [Student]

    init() {
        // Query will be adjusted at runtime via filter when we have a classroom id
        _students = Query()
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: PTSpacing.l.rawValue)], spacing: PTSpacing.l.rawValue) {
                ForEach(filteredStudents()) { student in
                    VStack(spacing: PTSpacing.s.rawValue) {
                        PTAvatar(initials: initials(for: student.displayName), size: 64)
                        Text(student.displayName)
                            .font(PTTypography.body)
                            .foregroundStyle(PTColors.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(PTSpacing.l.rawValue)
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


