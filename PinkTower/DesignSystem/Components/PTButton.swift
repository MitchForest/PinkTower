import SwiftUI

struct PTButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, PTSpacing.m.rawValue)
            .padding(.horizontal, PTSpacing.xl.rawValue)
            .background(PTColors.accent)
            .foregroundStyle(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

extension Button {
    func ptPrimary() -> some View {
        self.buttonStyle(PTButtonStyle())
    }
}


