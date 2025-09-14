import UIKit

enum Haptics {
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    static func warning() { UINotificationFeedbackGenerator().notificationOccurred(.warning) }
    static func error() { UINotificationFeedbackGenerator().notificationOccurred(.error) }
    static func lightTap() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .soft) { UIImpactFeedbackGenerator(style: style).impactOccurred() }
}


