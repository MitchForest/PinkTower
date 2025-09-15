import SwiftUI
import SwiftData

struct GlobalSearchSheet: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appVM: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var query: String = ""
    @State private var scope: Scope = .students

    @State private var matchedStudents: [Student] = []
    @State private var matchedClassrooms: [Classroom] = []
    @State private var matchedGuides: [Guide] = []

    enum Scope: String, CaseIterable, Identifiable { case students, classrooms, guides; var id: String { rawValue } }

    var body: some View {
        VStack(spacing: PTSpacing.m.rawValue) {
            HStack(spacing: PTSpacing.m.rawValue) {
                Picker("Scope", selection: $scope) {
                    ForEach(Scope.allCases) { s in Text(s.rawValue.capitalized).tag(s) }
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal, PTSpacing.l.rawValue)

            TextField("Search \(scope.rawValue)…", text: $query)
                .textFieldStyle(PTTextFieldStyle())
                .padding(.horizontal, PTSpacing.l.rawValue)

            ScrollView {
                VStack(alignment: .leading, spacing: PTSpacing.l.rawValue) {
                    if scope == .students {
                        ForEach(matchedStudents) { s in
                            Button(action: { openStudent(s) }) { row(title: s.displayName, subtitle: "Student") }
                        }
                    } else if scope == .classrooms {
                        ForEach(matchedClassrooms) { c in
                            Button(action: { openClassroom(c) }) { row(title: c.name, subtitle: "Classroom") }
                        }
                    } else {
                        ForEach(matchedGuides) { g in
                            Button(action: { /* future: guide profile */ }) { row(title: g.fullName, subtitle: g.role.rawValue.capitalized) }
                        }
                    }
                }
                .padding(.horizontal, PTSpacing.l.rawValue)
            }
            .background(PTColors.surface)
        }
        .padding(.vertical, PTSpacing.m.rawValue)
        .background(PTColors.surface)
        .onChange(of: query) { _, _ in performSearch() }
        .onChange(of: scope) { _, _ in performSearch() }
        .onAppear { performSearch() }
        .navigationTitle("Search")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } }
        }
    }

    private func row(title: String, subtitle: String) -> some View {
        HStack(spacing: PTSpacing.m.rawValue) {
            Circle().fill(PTColors.surfaceSecondary).frame(width: 36, height: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(PTTypography.body).foregroundStyle(PTColors.textPrimary)
                Text(subtitle).font(PTTypography.caption).foregroundStyle(PTColors.textSecondary)
            }
            Spacer()
        }
        .padding(.vertical, PTSpacing.s.rawValue)
    }

    private func performSearch() {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        switch scope {
        case .students:
            let all = (try? modelContext.fetch(FetchDescriptor<Student>())) ?? []
            matchedStudents = q.isEmpty ? Array(all.prefix(20)) : all.filter { $0.displayName.localizedCaseInsensitiveContains(q) }
        case .classrooms:
            let all = (try? modelContext.fetch(FetchDescriptor<Classroom>())) ?? []
            matchedClassrooms = q.isEmpty ? Array(all.prefix(20)) : all.filter { $0.name.localizedCaseInsensitiveContains(q) }
        case .guides:
            let all = (try? modelContext.fetch(FetchDescriptor<Guide>())) ?? []
            matchedGuides = q.isEmpty ? Array(all.prefix(20)) : all.filter { $0.fullName.localizedCaseInsensitiveContains(q) }
        }
    }

    private func openStudent(_ s: Student) {
        appVM.selectedClassroomId = appVM.selectedClassroomId // keep current
        dismiss()
        NotificationCenter.default.post(name: .init("OpenStudentFromSearch"), object: s)
    }

    private func openClassroom(_ c: Classroom) {
        appVM.selectedClassroomId = c.id
        dismiss()
    }
}


