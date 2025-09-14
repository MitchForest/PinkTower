import SwiftUI

enum PTMotion {
    // Timing
    static var easeOutSoft: Animation { .easeOut(duration: 0.28) }
    static var easeInOutSoft: Animation { .easeInOut(duration: 0.32) }
    static var springMedium: Animation { .interactiveSpring(response: 0.6, dampingFraction: 0.8, blendDuration: 0) }

    // Transitions
    static var fadeUp: AnyTransition { .asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity) }
    static var scaleIn: AnyTransition { .scale.combined(with: .opacity) }
}


