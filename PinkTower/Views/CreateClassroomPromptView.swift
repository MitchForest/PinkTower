import SwiftUI
import SwiftData

struct CreateClassroomPromptView: View {
    @EnvironmentObject private var appVM: AppViewModel
    @State private var showingCreate = false

    var body: some View {
        OnboardingWizardView()
            .environmentObject(appVM)
    }
}


