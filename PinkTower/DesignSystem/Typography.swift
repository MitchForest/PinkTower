import SwiftUI

enum PTTypography {
    static var display: Font { .system(size: 44, weight: .bold, design: .rounded) }
    static var title: Font { .system(.title2, design: .rounded).weight(.semibold) }
    static var subtitle: Font { .system(.headline, design: .rounded).weight(.regular) }
    static var body: Font { .system(.body, design: .rounded) }
    static var caption: Font { .system(.caption, design: .rounded) }
    static var small: Font { .system(.footnote, design: .rounded) }
}

extension View {
    func ptHeadingStyle() -> some View {
        self.font(PTTypography.display)
            .foregroundStyle(PTColors.textPrimary)
    }

    func ptSubtitleStyle() -> some View {
        self.font(PTTypography.subtitle)
            .foregroundStyle(PTColors.textSecondary)
    }
}


