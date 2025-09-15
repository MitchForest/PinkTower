import SwiftUI

// MARK: - Centered modal with light overlay and tap-to-dismiss

struct PTModal<ModalContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let modalContent: () -> ModalContent

    func body(content: Content) -> some View {
        ZStack {
            content
            if isPresented {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture { withAnimation(PTMotion.easeInOutSoft) { isPresented = false } }

                modalContent()
                    .padding(PTSpacing.l.rawValue)
                    .background(PTColors.surfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: PTRadius.l.rawValue, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: PTRadius.l.rawValue, style: .continuous).stroke(PTColors.border, lineWidth: 1))
                    .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 8)
                    .frame(maxWidth: 600)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(PTMotion.easeInOutSoft, value: isPresented)
    }
}

extension View {
    func ptModal<ModalContent: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> ModalContent) -> some View {
        self.modifier(PTModal(isPresented: isPresented, modalContent: content))
    }
}

// MARK: - Item-based variant

struct PTModalItem<Item: Identifiable, ModalContent: View>: ViewModifier {
    @Binding var item: Item?
    let modalContent: (Item) -> ModalContent

    func body(content: Content) -> some View {
        ZStack {
            content
            if let value = item {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture { withAnimation(PTMotion.easeInOutSoft) { item = nil } }

                modalContent(value)
                    .padding(PTSpacing.l.rawValue)
                    .background(PTColors.surfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: PTRadius.l.rawValue, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: PTRadius.l.rawValue, style: .continuous).stroke(PTColors.border, lineWidth: 1))
                    .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 8)
                    .frame(maxWidth: 600)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(PTMotion.easeInOutSoft, value: item != nil)
    }
}

extension View {
    func ptModal<Item: Identifiable, ModalContent: View>(item: Binding<Item?>, @ViewBuilder content: @escaping (Item) -> ModalContent) -> some View {
        self.modifier(PTModalItem(item: item, modalContent: content))
    }
}


