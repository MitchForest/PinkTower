import SwiftUI

struct NotificationsView: View {
    var body: some View {
        VStack(alignment: .center, spacing: PTSpacing.l.rawValue) {
            Text("NOTIFICATIONS PAGE COMING SOON")
                .font(PTTypography.title)
                .foregroundStyle(PTColors.textPrimary)
            Text("No notifications yet")
                .font(PTTypography.body)
                .foregroundStyle(PTColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PTColors.surface)
    }
}


