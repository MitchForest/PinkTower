import SwiftUI

struct AppRootView: View {
    @StateObject private var appVM = AppViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Group {
            switch appVM.route {
            case .signIn:
                SignInView()
                    .onAppear { appVM.bootstrap(context: modelContext) }
                    .environmentObject(appVM)
            case .promptCreateClassroom:
                CreateClassroomPromptView()
                    .environmentObject(appVM)
            case .main:
                MainTabView()
                    .environmentObject(appVM)
            }
        }
    }
}

#Preview {
    AppRootView()
}


