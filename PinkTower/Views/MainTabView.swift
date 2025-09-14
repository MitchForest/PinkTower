import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var appVM: AppViewModel

    var body: some View {
        TabView {
            HomeroomView()
                .tabItem { Label("Homeroom", systemImage: "person.3") }
            MyDayView()
                .tabItem { Label("My Day", systemImage: "sun.max") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
            SearchView()
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Text("Pink Tower").font(PTTypography.subtitle).foregroundStyle(PTColors.textSecondary)
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                NavigationLink(destination: NotificationsView()) {
                    Image(systemName: "bell")
                }
                Menu {
                    Button("Profile", action: {})
                    Button("Switch classroom", action: {})
                    Button("Sign out", role: .destructive) { appVM.signOut() }
                } label: {
                    PTAvatar(initials: initials(for: appVM.currentGuide?.fullName ?? "G"), size: 28)
                }
            }
        }
    }

    private func initials(for name: String) -> String {
        let parts = name.split(separator: " ")
        let initials = parts.prefix(2).compactMap { $0.first }.map { String($0) }.joined()
        return initials.isEmpty ? "G" : initials
    }
}


