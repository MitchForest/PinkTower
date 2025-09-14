import SwiftUI

struct PTEmptyState<Accessory: View>: View {
    let title: String
    let message: String?
    let primaryTitle: String
    let primaryAction: () -> Void
    var primaryEnabled: Bool = true
    var secondaryTitle: String? = nil
    var secondaryAction: (() -> Void)? = nil
    let accessory: Accessory

    init(
        title: String,
        message: String?,
        primaryTitle: String,
        primaryAction: @escaping () -> Void,
        primaryEnabled: Bool = true,
        secondaryTitle: String? = nil,
        secondaryAction: (() -> Void)? = nil,
        @ViewBuilder accessory: () -> Accessory
    ) {
        self.title = title
        self.message = message
        self.primaryTitle = primaryTitle
        self.primaryAction = primaryAction
        self.primaryEnabled = primaryEnabled
        self.secondaryTitle = secondaryTitle
        self.secondaryAction = secondaryAction
        self.accessory = accessory()
    }

    var body: some View {
        VStack(spacing: PTSpacing.l.rawValue) {
            Text(title)
                .font(PTTypography.display)
                .foregroundStyle(PTColors.textPrimary)
                .multilineTextAlignment(.center)
            if let message = message {
                Text(message)
                    .font(PTTypography.body)
                    .foregroundStyle(PTColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            accessory
                .frame(maxWidth: 520)
            Button(primaryTitle, action: primaryAction)
                .ptPrimary()
                .disabled(!primaryEnabled)
            if let secondaryTitle = secondaryTitle, let secondaryAction = secondaryAction {
                Button(secondaryTitle, action: secondaryAction)
                    .font(PTTypography.caption)
            }
        }
        .padding(.horizontal, PTSpacing.xl.rawValue)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PTColors.surface)
    }
}

extension PTEmptyState where Accessory == EmptyView {
    init(
        title: String,
        message: String?,
        primaryTitle: String,
        primaryAction: @escaping () -> Void,
        primaryEnabled: Bool = true,
        secondaryTitle: String? = nil,
        secondaryAction: (() -> Void)? = nil
    ) {
        self.init(
            title: title,
            message: message,
            primaryTitle: primaryTitle,
            primaryAction: primaryAction,
            secondaryTitle: secondaryTitle,
            secondaryAction: secondaryAction
        ) { EmptyView() }
        self.primaryEnabled = primaryEnabled
    }
}


