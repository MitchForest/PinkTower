import SwiftUI

struct PTSectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(PTTypography.title)
            .foregroundStyle(PTColors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, PTSpacing.s.rawValue)
    }
}


