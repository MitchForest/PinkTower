import SwiftUI

struct PTIconCircleButton: View {
    let systemImage: String
    let size: CGFloat
    let action: () -> Void

    init(systemImage: String, size: CGFloat = 44, action: @escaping () -> Void) {
        self.systemImage = systemImage
        self.size = size
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: size * 0.45, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: size, height: size)
                .background(PTColors.accent)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(.isButton)
    }
}


