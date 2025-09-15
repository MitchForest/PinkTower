import SwiftUI

struct ObservationDetailView: View {
    let observation: StudentObservation

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PTSpacing.m.rawValue) {
                Text(observation.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(PTTypography.caption)
                    .foregroundStyle(PTColors.textSecondary)
                Text(observation.content)
                    .font(PTTypography.body)
                    .foregroundStyle(PTColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(PTSpacing.l.rawValue)
        }
        .background(PTColors.surface)
        .navigationTitle("Observation")
    }
}


