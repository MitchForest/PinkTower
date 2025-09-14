import SwiftUI

struct PTBottomSheet<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let sheetContent: () -> SheetContent

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                sheetContent()
                    .presentationDetents([.fraction(0.9), .large])
                    .presentationDragIndicator(.visible)
            }
    }
}

extension View {
    func ptBottomSheet<SheetContent: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> SheetContent) -> some View {
        self.modifier(PTBottomSheet(isPresented: isPresented, sheetContent: content))
    }
}


