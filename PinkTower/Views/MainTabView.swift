import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var appVM: AppViewModel
    @State private var selectedTab: Int = 0

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
            SearchView()
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
                .tag(4)
        }
        .safeAreaInset(edge: .top, content: {
            PTTopBarCapsule(
                title: appVM.selectedClassroomId == nil ? "Pink Tower" : "Classroom",
                onSearch: {},
                onNotifications: {},
                onAvatar: {}
            )
            .accessibilityAddTraits(.isHeader)
        })
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
}


