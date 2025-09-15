import SwiftUI
import SwiftData

struct MainTabView: View {
    @EnvironmentObject private var appVM: AppViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: Int = 0
    @State private var showCreateClassroom = false

    var body: some View {
        TabView(selection: $selectedTab) {
            ClassroomsView()
                .tabItem { Label("Classrooms", systemImage: "building.2") }
                .tag(0)
            HomeroomView()
                .tabItem { Label("Students", systemImage: "person.3") }
                .tag(1)
            MyDayView()
                .tabItem { Label("My Day", systemImage: "sun.max") }
                .tag(2)
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(3)
            GlobalSearchSheet()
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
                .tag(4)
        }
        .safeAreaInset(edge: .top, content: {
            PTNavBar(
                title: currentClassroomName() ?? "Pink Tower",
                onHamburger: {},
                onSearch: { selectedTab = 4 },
                onNotifications: {},
                onAvatar: {}
            ) {
                ClassroomSwitcherMenuContent(
                    selectedId: appVM.selectedClassroomId,
                    onSelect: { room in
                        appVM.selectedClassroomId = room.id
                        selectedTab = 1
                    },
                    onAdd: { showCreateClassroom = true }
                )
            }
            .accessibilityAddTraits(.isHeader)
        })
        .sheet(isPresented: $showCreateClassroom) {
            CreateClassroomView(onCreated: { id in
                appVM.selectedClassroomId = id
                selectedTab = 1
            })
        }
        .onAppear {
            // If we already have a selected classroom (single-classroom case), land on Students
            if appVM.selectedClassroomId != nil { selectedTab = 1 } else { selectedTab = 0 }
        }
    }

    private func initials(for name: String) -> String {
        let parts = name.split(separator: " ")
        let initials = parts.prefix(2).compactMap { $0.first }.map { String($0) }.joined()
        return initials.isEmpty ? "G" : initials
    }

    private func currentClassroomName() -> String? {
        guard let id = appVM.selectedClassroomId else { return nil }
        var descriptor = FetchDescriptor<Classroom>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        let room = try? modelContext.fetch(descriptor).first
        return room?.name
    }
}


private struct ClassroomSwitcherMenuContent: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var rooms: [Classroom]
    let selectedId: UUID?
    let onSelect: (Classroom) -> Void
    let onAdd: () -> Void

    init(selectedId: UUID?, onSelect: @escaping (Classroom) -> Void, onAdd: @escaping () -> Void) {
        self.selectedId = selectedId
        self.onSelect = onSelect
        self.onAdd = onAdd
        _rooms = Query()
    }

    var body: some View {
        if rooms.isEmpty {
            Button("Add classroom", action: onAdd)
        } else {
            ForEach(rooms) { room in
                Button(action: { onSelect(room) }) {
                    HStack {
                        if room.id == selectedId { Image(systemName: "checkmark") }
                        Text(room.name)
                    }
                }
            }
            Divider()
            Button("Add classroom", action: onAdd)
        }
    }
}


