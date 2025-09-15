import SwiftUI

// MARK: - Native bottom sheet drawer using .sheet with detents

struct PTBottomSheet<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let fraction: CGFloat
    let sheetContent: () -> SheetContent

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                sheetContent()
                    .presentationDetents([.fraction(max(0.5, min(0.98, fraction))), .large])
                    .presentationDragIndicator(.visible)
                    .interactiveDismissDisabled(false)
                    .presentationCornerRadius(16)
                    .presentationBackgroundInteraction(.enabled)
            }
    }
}

extension View {
    func ptBottomSheet<SheetContent: View>(isPresented: Binding<Bool>, fraction: CGFloat = 0.95, @ViewBuilder content: @escaping () -> SheetContent) -> some View {
        self.modifier(PTBottomSheet(isPresented: isPresented, fraction: fraction, sheetContent: content))
    }
}

// Item-based variant to ensure content readiness and avoid blank first presentation
struct PTBottomSheetItem<Item: Identifiable, SheetContent: View>: ViewModifier {
    @Binding var item: Item?
    let fraction: CGFloat
    let sheetContent: (Item) -> SheetContent

    func body(content: Content) -> some View {
        content
            .sheet(item: $item) { value in
                sheetContent(value)
                    .presentationDetents([.fraction(max(0.5, min(0.98, fraction))), .large])
                    .presentationDragIndicator(.visible)
                    .interactiveDismissDisabled(false)
                    .presentationCornerRadius(16)
                    .presentationBackgroundInteraction(.enabled)
            }
    }
}

extension View {
    func ptBottomSheet<Item: Identifiable, SheetContent: View>(item: Binding<Item?>, fraction: CGFloat = 0.95, @ViewBuilder content: @escaping (Item) -> SheetContent) -> some View {
        self.modifier(PTBottomSheetItem(item: item, fraction: fraction, sheetContent: content))
    }
}


