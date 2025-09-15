import Foundation
import SwiftData

protocol SharingServiceProtocol {
    func buildParentSummary(studentName: String, periodLabel: String, summaryText: String) -> String
    func logParentSummary(studentId: UUID, period: ParentSummaryPeriod, guideId: UUID, context: ModelContext) throws -> ParentSummaryLog
    func hasLoggedParentSummary(studentId: UUID, period: ParentSummaryPeriod, on date: Date, context: ModelContext) throws -> Bool
}

struct SharingService: SharingServiceProtocol {
    func buildParentSummary(studentName: String, periodLabel: String, summaryText: String) -> String {
        "Update for \(studentName) — \(periodLabel)\n\n\(summaryText)\n\n— Sent from Pink Tower"
    }

    func logParentSummary(studentId: UUID, period: ParentSummaryPeriod, guideId: UUID, context: ModelContext) throws -> ParentSummaryLog {
        let normalized = ParentSummaryLog.normalize(Date(), for: period)
        let descriptor = FetchDescriptor<ParentSummaryLog>(predicate: #Predicate { $0.studentId == studentId && $0.periodRaw == period.rawValue && $0.date == normalized })
        if let existing = try context.fetch(descriptor).first { return existing }
        let log = ParentSummaryLog(studentId: studentId, date: Date(), period: period, createdByGuideId: guideId)
        context.insert(log)
        try context.save()
        return log
    }

    func hasLoggedParentSummary(studentId: UUID, period: ParentSummaryPeriod, on date: Date, context: ModelContext) throws -> Bool {
        let normalized = ParentSummaryLog.normalize(date, for: period)
        let descriptor = FetchDescriptor<ParentSummaryLog>(predicate: #Predicate { $0.studentId == studentId && $0.periodRaw == period.rawValue && $0.date == normalized })
        return try !context.fetch(descriptor).isEmpty
    }
}


