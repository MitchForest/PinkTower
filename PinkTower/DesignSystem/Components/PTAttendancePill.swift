import SwiftUI

struct PTAttendancePill: View {
    @Binding var isPresent: Bool
    var onToggle: (() -> Void)? = nil

    var body: some View {
        Button(action: {
            isPresent.toggle()
            Haptics.lightTap()
            onToggle?()
        }) {
            Text(isPresent ? "Present" : "Absent")
                .font(PTTypography.small)
                .foregroundStyle(isPresent ? PTColors.textPrimary : PTColors.textSecondary)
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background((isPresent ? PTColors.successMuted : PTColors.surfaceSecondary))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(PTColors.border, lineWidth: 0.5))
        }
        .accessibilityLabel("Attendance")
    }
}


