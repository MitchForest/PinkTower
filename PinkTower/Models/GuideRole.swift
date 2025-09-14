import Foundation

enum GuideRole: String, Codable, CaseIterable, Identifiable {
    case superAdmin
    case admin
    case guide

    var id: String { rawValue }
}


