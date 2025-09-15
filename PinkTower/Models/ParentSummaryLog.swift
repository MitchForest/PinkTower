import Foundation
import SwiftData

enum ParentSummaryPeriod: String, Codable, CaseIterable, Identifiable {
    case day
    case week
    case month
    var id: String { rawValue }
}

@Model
final class ParentSummaryLog {
    var id: UUID
    var studentId: UUID
    var date: Date // normalized to start of period (e.g., start of day/week/month)
    var periodRaw: String
    var createdByGuideId: UUID
    var createdAt: Date

    init(
        id: UUID = UUID(),
        studentId: UUID,
        date: Date,
        period: ParentSummaryPeriod,
        createdByGuideId: UUID,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.studentId = studentId
        self.date = ParentSummaryLog.normalize(date, for: period)
        self.periodRaw = period.rawValue
        self.createdByGuideId = createdByGuideId
        self.createdAt = createdAt
    }

    var period: ParentSummaryPeriod {
        get { ParentSummaryPeriod(rawValue: periodRaw) ?? .day }
        set { periodRaw = newValue.rawValue }
    }

    static func normalize(_ date: Date, for period: ParentSummaryPeriod) -> Date {
        let cal = Calendar.current
        switch period {
        case .day:
            return cal.startOfDay(for: date)
        case .week:
            let comp = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
            return cal.date(from: comp) ?? cal.startOfDay(for: date)
        case .month:
            let comp = cal.dateComponents([.year, .month], from: date)
            return cal.date(from: comp) ?? cal.startOfDay(for: date)
        }
    }
}


