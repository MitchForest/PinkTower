import SwiftUI

enum PTColors {
    // Montessori palette (fixed for now to ensure consistent vibe)
    // Hex palette reference:
    // Beige #FCF1D2, OffWhite #FCFCFC, OffBlack #2B2B2B, Orange #FE703C, Pink #FFB3DD, Yellow #F4BC37
    static var accent: Color { Color(red: 254/255, green: 112/255, blue: 60/255) } // Orange
    static var surface: Color { Color(red: 252/255, green: 241/255, blue: 210/255) } // Beige
    static var surfaceSecondary: Color { Color(red: 252/255, green: 252/255, blue: 252/255) } // OffWhite
    static var surfaceAlt: Color { Color(red: 244/255, green: 188/255, blue: 55/255).opacity(0.08) } // Soft yellow wash
    static var textPrimary: Color { Color(red: 43/255, green: 43/255, blue: 43/255) } // OffBlack
    static var textSecondary: Color { Color(red: 43/255, green: 43/255, blue: 43/255).opacity(0.7) }
    static var border: Color { Color(red: 43/255, green: 43/255, blue: 43/255).opacity(0.12) }
    static var success: Color { Color(UIColor.systemGreen) }
    static var successMuted: Color { Color(UIColor.systemGreen).opacity(0.15) }
    static var warning: Color { Color(UIColor.systemOrange) }
    static var warningMuted: Color { Color(UIColor.systemOrange).opacity(0.15) }
    static var error: Color { Color(UIColor.systemRed) }

    // Natural Montessori palette (dynamic for light/dark using UIUserInterfaceStyle)
    static var sand: Color { Color(red: 252/255, green: 241/255, blue: 210/255) }
    static var clay: Color { Color(red: 255/255, green: 179/255, blue: 221/255) } // pink as accent wash
    static var leaf: Color { Color(red: 0.71, green: 0.84, blue: 0.74) }
    static var sky: Color { Color(red: 0.77, green: 0.88, blue: 0.96) }
    static var berry: Color { Color(red: 0.95, green: 0.77, blue: 0.84) }
}


