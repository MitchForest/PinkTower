import SwiftUI

struct PTCodeField: View {
    @Binding var code: String
    let length: Int
    var onComplete: () -> Void

    @FocusState private var focused: Bool

    var body: some View {
        ZStack {
            HStack(spacing: PTSpacing.m.rawValue) {
                ForEach(0..<length, id: \.self) { index in
                    ZStack {
                        RoundedRectangle(cornerRadius: PTRadius.m.rawValue, style: .continuous)
                            .stroke(PTColors.border, lineWidth: 1)
                            .background(RoundedRectangle(cornerRadius: PTRadius.m.rawValue, style: .continuous).fill(PTColors.surfaceSecondary))
                        Text(char(at: index))
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .foregroundStyle(PTColors.textPrimary)
                    }
                    .frame(width: 42, height: 52)
                }
            }
            TextField("", text: $code)
                .keyboardType(.asciiCapable)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .foregroundStyle(.clear)
                .accentColor(.clear)
                .tint(.clear)
                .textContentType(.oneTimeCode)
                .focused($focused)
                .onChange(of: code) { _, newValue in
                    code = String(newValue.uppercased().filter { $0.isLetter || $0.isNumber }.prefix(length))
                    if code.count == length { onComplete() }
                }
                .onAppear { focused = true }
                .frame(width: 0, height: 0)
                .opacity(0.05)
        }
    }

    private func char(at index: Int) -> String {
        guard index < code.count else { return "" }
        let i = code.index(code.startIndex, offsetBy: index)
        return String(code[i])
    }
}


