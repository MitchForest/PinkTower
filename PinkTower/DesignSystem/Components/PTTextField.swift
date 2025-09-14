import SwiftUI

struct PTTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(PTColors.surfaceSecondary)
            .foregroundStyle(PTColors.textPrimary)
            .tint(PTColors.accent)
            .clipShape(RoundedRectangle(cornerRadius: PTRadius.m.rawValue, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: PTRadius.m.rawValue, style: .continuous).stroke(PTColors.border, lineWidth: 1))
    }
}

extension TextFieldStyle where Self == PTTextFieldStyle { static var pt: PTTextFieldStyle { PTTextFieldStyle() } }


