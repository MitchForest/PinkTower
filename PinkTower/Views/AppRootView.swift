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
            case .promptCreateOrganization:
                OnboardingWizardView()
                    .environmentObject(appVM)
            case .promptJoinOrganization:
                JoinOrganizationView()
                    .environmentObject(appVM)
            case .promptCreateClassroom:
                OnboardingWizardView()
                    .environmentObject(appVM)
            case .main:
                MainShellView()
                    .environmentObject(appVM)
            }
        }
    }
}

#Preview {
    AppRootView()
}


