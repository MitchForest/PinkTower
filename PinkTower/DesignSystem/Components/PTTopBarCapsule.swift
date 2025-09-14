import SwiftUI

struct PTTopBarCapsule: View {
    let title: String
    var showSearch: Bool = true
    var showNotifications: Bool = true
    var avatar: Image? = nil
    var onSearch: (() -> Void)?
    var onNotifications: (() -> Void)?
    var onAvatar: (() -> Void)?

    var body: some View {
        HStack(spacing: PTSpacing.m.rawValue) {
            Spacer(minLength: 0)
            Text(title)
                .font(PTTypography.subtitle)
                .foregroundStyle(PTColors.textPrimary)
                .lineLimit(1)
            Spacer(minLength: 0)
            HStack(spacing: PTSpacing.m.rawValue) {
                if showSearch {
                    Button(action: { onSearch?() }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(PTColors.textSecondary)
                    }
                    .contentShape(Rectangle())
                }
                if showNotifications {
                    Button(action: { onNotifications?() }) {
                        Image(systemName: "bell")
                            .foregroundStyle(PTColors.textSecondary)
                    }
                    .contentShape(Rectangle())
                }
                Button(action: { onAvatar?() }) {
                    if let avatar = avatar {
                        PTAvatar(image: avatar, size: 28)
                    } else {
                        PTAvatar(image: nil, size: 28, initials: "G")
                    }
                }
            }
        }
        .padding(.vertical, PTSpacing.s.rawValue)
        .padding(.horizontal, PTSpacing.l.rawValue)
        .background(PTColors.surfaceSecondary)
        .clipShape(Capsule(style: .continuous))
        .overlay(
            Capsule(style: .continuous).stroke(PTColors.border, lineWidth: 0.5)
        )
        .padding(.horizontal, PTSpacing.l.rawValue)
    }
}


