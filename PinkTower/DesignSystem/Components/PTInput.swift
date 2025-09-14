import SwiftUI

struct PTInput: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundStyle(PTColors.textSecondary)
                    .padding(.vertical, 12)
                    .padding(.leading, 14)
            }
            TextField("", text: $text)
                .multilineTextAlignment(.leading)
                .textFieldStyle(PTTextFieldStyle())
        }
    }
}

struct PTEmojiField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: Binding(
            get: { text },
            set: { newValue in
                let trimmed = String(newValue.prefix(2))
                text = String(trimmed.suffix(1))
            }
        ))
        .multilineTextAlignment(.center)
        .textFieldStyle(PTTextFieldStyle())
        .frame(width: 60)
    }
}


