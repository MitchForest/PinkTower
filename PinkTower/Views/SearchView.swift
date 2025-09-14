import SwiftUI
import SwiftData

struct SearchView: View {
    @State private var query: String = ""
    @Query private var students: [Student]

    init() {
        _students = Query()
    }

    var body: some View {
        NavigationStack {
            List(filtered()) { student in
                HStack(spacing: PTSpacing.m.rawValue) {
                    PTAvatar(initials: initials(for: student.displayName), size: 32)
                    Text(student.displayName)
                }
            }
            .searchable(text: $query)
            .navigationTitle("Search")
        }
    }

    private func filtered() -> [Student] {
        guard !query.isEmpty else { return students }
        return students.filter { $0.displayName.localizedCaseInsensitiveContains(query) }
    }

    private func initials(for name: String) -> String {
        let parts = name.split(separator: " ")
        let initials = parts.prefix(2).compactMap { $0.first }.map { String($0) }.joined()
        return initials.isEmpty ? "S" : initials
    }
}


