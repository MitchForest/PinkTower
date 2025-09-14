import SwiftUI

struct PTCheckmarkBurst: View {
    @Binding var isVisible: Bool

    var body: some View {
        ZStack {
            if isVisible {
                Circle()
                    .fill(PTColors.successMuted)
                    .frame(width: 120, height: 120)
                    .scaleEffect(isVisible ? 1 : 0.8)
                    .animation(PTMotion.springMedium, value: isVisible)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(PTColors.success)
                    .scaleEffect(isVisible ? 1 : 0.7)
                    .opacity(isVisible ? 1 : 0)
                    .animation(PTMotion.springMedium, value: isVisible)
            }
        }
        .transition(.opacity)
        .onChange(of: isVisible) { _, newValue in
            if newValue {
                Haptics.success()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(PTMotion.easeOutSoft) { isVisible = false }
                }
            }
        }
    }
}


