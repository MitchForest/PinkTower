import SwiftUI

struct GettingStartedView: View {
    @EnvironmentObject private var appVM: AppViewModel

    var body: some View {
        VStack(spacing: PTSpacing.m.rawValue) {
            Text("Welcome to Pink Tower")
                .ptHeadingStyle()
            VStack(alignment: .leading, spacing: PTSpacing.s.rawValue) {
                Label("Select your classroom", systemImage: "building.2")
                Label("Select a student", systemImage: "person.circle")
                Label("Add observations, tasks, lessons, habits", systemImage: "square.and.pencil")
                Label("Generate AI-powered summaries and insights", systemImage: "sparkles")
            }
            .font(PTTypography.body)
            .foregroundStyle(PTColors.textSecondary)
            .frame(maxWidth: 520, alignment: .leading)
            .padding(.vertical, PTSpacing.m.rawValue)
            Button("Continue") { appVM.route = .promptCreateClassroom }
                .ptPrimary()
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PTColors.surface)
        .padding(.horizontal, PTSpacing.xl.rawValue)
    }
}


