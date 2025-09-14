import SwiftUI

struct PTAvatar: View {
    let image: Image?
    let size: CGFloat
    let initials: String

    init(image: Image? = nil, size: CGFloat = 40, initials: String = "") {
        self.image = image
        self.size = size
        self.initials = initials
    }

    var body: some View {
        ZStack {
            if let image = image {
                image
                    .resizable()
                    .scaledToFill()
            } else {
                Circle()
                    .fill(PTColors.surfaceSecondary)
                Text(initials)
                    .font(.system(size: size * 0.4, weight: .medium, design: .rounded))
                    .foregroundStyle(PTColors.textSecondary)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay {
            Circle().stroke(PTColors.border, lineWidth: 0.5)
        }
    }
}


