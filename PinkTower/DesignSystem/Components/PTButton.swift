import SwiftUI

struct PTButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, PTSpacing.m.rawValue)
            .padding(.horizontal, PTSpacing.xl.rawValue)
            .background(backgroundColor(isPressed: configuration.isPressed))
            .foregroundStyle(foregroundColor())
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .opacity(configuration.isPressed ? 0.95 : 1.0)
    }

    @Environment(\.isEnabled) private var isEnabled

    private func backgroundColor(isPressed: Bool) -> Color {
        guard isEnabled else { return PTColors.accent.opacity(0.35) }
        return isPressed ? PTColors.accent.opacity(0.9) : PTColors.accent
    }

    private func foregroundColor() -> Color {
        isEnabled ? .white : .white.opacity(0.8)
    }
}

extension Button {
    func ptPrimary() -> some View {
        self.buttonStyle(PTButtonStyle())
    }
}


