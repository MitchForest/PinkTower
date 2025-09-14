import SwiftUI
import SwiftData

struct CreateClassroomView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appVM: AppViewModel
    @State private var name: String = ""
    var onCreated: (UUID) -> Void = { _ in }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: PTSectionHeader(title: "Details")) {
                    TextField("Classroom name", text: $name)
                }
            }
            .navigationTitle("Create classroom")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { create() }.disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func create() {
        let classroom = Classroom(name: name)
        modelContext.insert(classroom)
        if let guide = appVM.currentGuide {
            guide.defaultClassroomId = classroom.id
        }
        try? modelContext.save()
        onCreated(classroom.id)
        dismiss()
    }
}


