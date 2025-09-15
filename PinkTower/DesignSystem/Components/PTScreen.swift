import SwiftUI

/// PTScreen standardizes screen background and top content inset so content never underlaps the global navbar.
struct PTScreen<Content: View>: View {
    let contentTopInset: CGFloat
    let content: () -> Content

    init(contentTopInset: CGFloat = 72, @ViewBuilder content: @escaping () -> Content) {
        self.contentTopInset = contentTopInset
        self.content = content
    }

    var body: some View {
        ZStack(alignment: .top) {
            PTColors.surface.ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer().frame(height: contentTopInset)
                content()
            }
        }
    }
}


