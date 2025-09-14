import SwiftUI
import PhotosUI

struct PTAvatarSelector: View {
    @Binding var emoji: String
    @Binding var imageData: Data?
    @State private var showEmojiSheet = false
    @State private var photoItem: PhotosPickerItem?

    private let emojiChoices: [String] = ["🙂","😀","🧒","👧","👦","🎒","📚","🌿","🌼","🧩","✏️","🎨"]

    var body: some View {
        Menu {
            PhotosPicker(selection: $photoItem, matching: .images, photoLibrary: .shared()) {
                Label("Select Photo", systemImage: "photo")
            }
            Button { showEmojiSheet = true } label: { Label("Select Emoji", systemImage: "face.smiling") }
            Button(role: .destructive) { self.imageData = nil; self.emoji = "" } label: { Label("No Avatar", systemImage: "nosign") }
        } label: {
            ZStack {
                if let data = imageData, let ui = UIImage(data: data) {
                    Image(uiImage: ui).resizable().scaledToFill()
                } else if !emoji.isEmpty {
                    Text(emoji).font(.system(size: 28))
                } else {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 24))
                        .foregroundStyle(PTColors.textSecondary)
                }
            }
            .frame(width: 56, height: 56)
            .background(PTColors.surfaceSecondary)
            .clipShape(Circle())
            .overlay(Circle().stroke(PTColors.border, lineWidth: 1))
        }

        .onChange(of: photoItem) { _, newItem in
            guard let newItem = newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    await MainActor.run { self.imageData = data; self.emoji = "" }
                }
            }
        }

        .sheet(isPresented: $showEmojiSheet) {
            VStack(spacing: PTSpacing.m.rawValue) {
                Text("Choose an emoji")
                    .font(PTTypography.title)
                    .foregroundStyle(PTColors.textPrimary)
                emojiGrid
            }
            .padding()
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
            .background(PTColors.surface)
        }
    }

    private var emojiGrid: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(48), spacing: PTSpacing.s.rawValue), count: 6), spacing: PTSpacing.m.rawValue) {
                ForEach(emojiChoices, id: \.self) { e in
                    Button(action: { self.emoji = e; self.imageData = nil; showEmojiSheet = false }) {
                        Text(e).font(.system(size: 28))
                            .frame(width: 44, height: 44)
                            .background(PTColors.surfaceSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
            }
            .padding()
        }
    }
}


