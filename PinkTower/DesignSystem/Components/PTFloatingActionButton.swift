import SwiftUI

struct PTFloatingActionButton: View {
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.white)
                .padding(20)
                .background(PTColors.accent)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 6)
        }
        .accessibilityLabel("Primary action")
        .padding(EdgeInsets(top: 0, leading: 0, bottom: PTSpacing.xl.rawValue, trailing: PTSpacing.xl.rawValue))
    }
}

struct FloatingActionButtonContainer<Content: View>: View {
    let content: Content
    let button: PTFloatingActionButton

    init(@ViewBuilder content: () -> Content, button: PTFloatingActionButton) {
        self.content = content()
        self.button = button
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            content
            button
        }
    }
}


