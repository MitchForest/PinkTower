import SwiftUI
import SwiftData

struct ClassroomsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appVM: AppViewModel
    @Query private var classrooms: [Classroom]
    @State private var showCreate = false
    private let classroomService: ClassroomServiceProtocol = ClassroomService()

    var body: some View {
        PTScreen {
        FloatingActionButtonContainer(content: {
            if classrooms.isEmpty {
                PTEmptyState(
                    title: "Create your first classroom",
                    message: "A classroom organizes students and their records.",
                    primaryTitle: "Create classroom",
                    primaryAction: { showCreate = true }
                )
            } else {
                List(classrooms) { room in
                    Button(action: { select(room) }) {
                        HStack {
                            PTAvatar(image: nil, size: 32, initials: initials(for: room.name))
                            Text(room.name)
                            Spacer()
                            Text("\(room.studentIds.count)")
                                .font(PTTypography.caption)
                                .foregroundStyle(PTColors.textSecondary)
                        }
                    }
                    .contextMenu {
                        Button("Rename") { /* open edit */ }
                        Button("Delete", role: .destructive) { try? classroomService.delete(room, context: modelContext) }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }, button: PTFloatingActionButton(systemImage: "plus", action: { showCreate = true }))
        }
        .sheet(isPresented: $showCreate) { CreateClassroomView(onCreated: { id in
            appVM.selectedClassroomId = id
        })}
    }

    private func select(_ room: Classroom) {
        appVM.selectedClassroomId = room.id
    }

    private func initials(for name: String) -> String { String(name.prefix(2)).uppercased() }
}


