import SwiftUI
import SwiftData

struct CreateClassroomPromptView: View {
    @EnvironmentObject private var appVM: AppViewModel
    @State private var showingCreate = false

    var body: some View {
        VStack(spacing: PTSpacing.l.rawValue) {
            Text("No classroom yet")
                .font(PTTypography.title)
                .foregroundStyle(PTColors.textPrimary)
            Button("Create classroom") { showingCreate = true }
                .ptPrimary()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PTColors.surface)
        .sheet(isPresented: $showingCreate) {
            CreateClassroomView(onCreated: { id in
                appVM.selectedClassroomId = id
                appVM.route = .main
            })
        }
    }
}


