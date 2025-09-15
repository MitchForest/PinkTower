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


struct PTButtonSecondaryStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, PTSpacing.m.rawValue)
            .padding(.horizontal, PTSpacing.xl.rawValue)
            .background(PTColors.surfaceSecondary)
            .foregroundStyle(PTColors.textPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(PTColors.border, lineWidth: 1))
            .opacity(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct PTButtonQuietStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, PTSpacing.s.rawValue)
            .padding(.horizontal, PTSpacing.l.rawValue)
            .foregroundStyle(PTColors.accent)
            .background(Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

extension Button {
    func ptSecondary() -> some View { self.buttonStyle(PTButtonSecondaryStyle()) }
    func ptQuiet() -> some View { self.buttonStyle(PTButtonQuietStyle()) }
}


