import Foundation

protocol SharingServiceProtocol {
    func buildParentSummary(studentName: String, periodLabel: String, summaryText: String) -> String
}

struct SharingService: SharingServiceProtocol {
    func buildParentSummary(studentName: String, periodLabel: String, summaryText: String) -> String {
        "Update for \(studentName) — \(periodLabel)\n\n\(summaryText)\n\n— Sent from Pink Tower"
    }
}


