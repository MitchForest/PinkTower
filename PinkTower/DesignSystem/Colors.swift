import SwiftUI

enum PTColors {
    // Semantic colors derived from system where possible for dynamic light/dark & accessibility
    static var accent: Color { .accentColor }
    static var surface: Color { Color(UIColor.systemBackground) }
    static var surfaceSecondary: Color { Color(UIColor.secondarySystemBackground) }
    static var textPrimary: Color { Color(UIColor.label) }
    static var textSecondary: Color { Color(UIColor.secondaryLabel) }
    static var border: Color { Color(UIColor.separator) }
    static var success: Color { Color(UIColor.systemGreen) }
    static var warning: Color { Color(UIColor.systemOrange) }
    static var error: Color { Color(UIColor.systemRed) }
}


