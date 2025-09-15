import SwiftUI

struct PTNavBar<TitleMenuContent: View>: View {
    let title: String
    var showTitleMenu: Bool
    var showBackButton: Bool
    var onTitleTap: (() -> Void)? = nil
    var onBack: (() -> Void)? = nil
    var onHamburger: (() -> Void)? = nil
    var onSearch: (() -> Void)? = nil
    var onNotifications: (() -> Void)? = nil
    var onAvatar: (() -> Void)? = nil
    let titleMenuContent: () -> TitleMenuContent

    init(
        title: String,
        showTitleMenu: Bool = true,
        showBackButton: Bool = false,
        onTitleTap: (() -> Void)? = nil,
        onBack: (() -> Void)? = nil,
        onHamburger: (() -> Void)? = nil,
        onSearch: (() -> Void)? = nil,
        onNotifications: (() -> Void)? = nil,
        onAvatar: (() -> Void)? = nil,
        @ViewBuilder titleMenu: @escaping () -> TitleMenuContent
    ) {
        self.title = title
        self.showTitleMenu = showTitleMenu
        self.showBackButton = showBackButton
        self.onTitleTap = onTitleTap
        self.onBack = onBack
        self.onHamburger = onHamburger
        self.onSearch = onSearch
        self.onNotifications = onNotifications
        self.onAvatar = onAvatar
        self.titleMenuContent = titleMenu
    }

    var body: some View {
        HStack(alignment: .center, spacing: PTSpacing.m.rawValue) {
            HStack(spacing: PTSpacing.m.rawValue) {
                if showBackButton {
                    navIconButton(systemName: "chevron.left", action: onBack)
                }
                navIconButton(systemName: "line.3.horizontal", action: onHamburger)
                navIconButton(systemName: "magnifyingglass", action: onSearch)
            }
            Spacer(minLength: 0)
            HStack(spacing: PTSpacing.s.rawValue) {
                Button(action: { onTitleTap?() }) {
                    HStack(spacing: PTSpacing.s.rawValue) {
                        Text(title)
                            .font(PTTypography.title)
                            .foregroundStyle(PTColors.textPrimary)
                            .lineLimit(1)
                        Image(systemName: "chevron.down")
                            .font(.system(size: PTIconSize.small.rawValue, weight: .semibold))
                            .foregroundStyle(PTColors.textSecondary)
                    }
                }
                .buttonStyle(.plain)
                // Legacy menu disabled in favor of modal sheet
            }
            Spacer(minLength: 0)
            HStack(spacing: PTSpacing.m.rawValue) {
                navIconButton(systemName: "bell", action: onNotifications)
                // Replace avatar in top bar with a calendar/today icon
                navIconButton(systemName: "calendar", action: onAvatar)
            }
        }
        .padding(.horizontal, PTSpacing.l.rawValue)
        .padding(.vertical, PTSpacing.s.rawValue)
        .background(Color.clear)
        .accessibilityElement(children: .contain)
    }

    private func navIconButton(systemName: String, action: (() -> Void)?) -> some View {
        Button(action: { action?() }) {
            Image(systemName: systemName)
                .font(.system(size: PTIconSize.medium.rawValue, weight: .semibold))
                .foregroundStyle(PTColors.textPrimary)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

extension PTNavBar where TitleMenuContent == EmptyView {
    init(
        title: String,
        onTitleTap: (() -> Void)? = nil,
        onHamburger: (() -> Void)? = nil,
        onSearch: (() -> Void)? = nil,
        onNotifications: (() -> Void)? = nil,
        onAvatar: (() -> Void)? = nil
    ) {
        self.init(
            title: title,
            onTitleTap: onTitleTap,
            onHamburger: onHamburger,
            onSearch: onSearch,
            onNotifications: onNotifications,
            onAvatar: onAvatar,
            titleMenu: { EmptyView() }
        )
    }
}


