import SwiftUI
import SwiftData

struct JoinOrganizationView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appVM: AppViewModel
    @State private var code: String = ""
    private let invites: InviteServiceProtocol = InviteService()

    var body: some View {
        PTEmptyState(
            title: "Join your school",
            message: "Enter the invite code shared by your superadmin.",
            primaryTitle: "Join",
            primaryAction: { redeem() },
            primaryEnabled: code.count == 8,
            secondaryTitle: "Create a school",
            secondaryAction: { appVM.route = .promptCreateOrganization }
        ) {
            PTCodeField(code: $code, length: 8) { redeem() }
            Text("Tip: Paste from clipboard if copied")
                .font(PTTypography.caption).foregroundStyle(PTColors.textSecondary)
        }
    }

    private func redeem() {
        guard let guide = appVM.currentGuide else { return }
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
        if let _ = try? invites.redeem(code: trimmed, by: guide.id, context: modelContext) {
            Haptics.success()
            appVM.route = .promptCreateClassroom
        }
    }
}


