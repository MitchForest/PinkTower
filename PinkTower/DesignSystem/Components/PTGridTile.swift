import SwiftUI

enum PTGridTileSize {
    case large, medium, compact

    var avatar: CGFloat {
        switch self {
        case .large: return 88
        case .medium: return 64
        case .compact: return 48
        }
    }

    var titleFont: Font {
        switch self {
        case .large: return PTTypography.title
        case .medium: return PTTypography.body
        case .compact: return PTTypography.caption
        }
    }
}

struct PTGridTile: View {
    let title: String
    let initials: String
    let image: Image?
    let size: PTGridTileSize

    init(title: String, initials: String, image: Image? = nil, size: PTGridTileSize) {
        self.title = title
        self.initials = initials
        self.image = image
        self.size = size
    }

    var body: some View {
        VStack(spacing: PTSpacing.s.rawValue) {
            PTAvatar(image: image, size: size.avatar, initials: initials)
            Text(title)
                .font(size.titleFont)
                .foregroundStyle(PTColors.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, PTSpacing.s.rawValue)
        .accessibilityElement(children: .combine)
    }
}


