import SwiftUI
import AuthenticationServices
import SwiftData

struct SignInView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appVM: AppViewModel
    @StateObject private var vm: SignInViewModel

    init() {
        // Simple composition here; later inject via container
        let auth = AuthService()
        let session = SessionService()
        // modelContext will be set after init; we will reinit in body
        _vm = StateObject(wrappedValue: SignInViewModel(authService: auth, sessionService: session, modelContext: ModelContext(try! ModelContainer(for: Item.self))))
    }

    var body: some View {
        let _ = vm // keep reference
        VStack(spacing: PTSpacing.xxl.rawValue) {
            VStack(spacing: PTSpacing.s.rawValue) {
                Text("Pink Tower")
                    .ptHeadingStyle()
                Text("The app for Montessori classroom management")
                    .ptSubtitleStyle()
            }
            .multilineTextAlignment(.center)

            SignInWithAppleButton(.signIn, onRequest: { request in
                request.requestedScopes = [.fullName, .email]
            }, onCompletion: { result in
                switch result {
                case .success(let auth):
                    Task { await vm.handleAuthorization(auth) }
                case .failure(let error):
                    vm.errorMessage = error.localizedDescription
                }
            })
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            .clipShape(RoundedRectangle(cornerRadius: PTRadius.m.rawValue, style: .continuous))
            .padding(.horizontal, PTSpacing.xl.rawValue)
            .overlay(alignment: .center) {
                if vm.isLoading { ProgressView() }
            }
            if let error = vm.errorMessage {
                Text(error).font(PTTypography.caption).foregroundStyle(PTColors.error)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PTColors.surface)
        .task {
            // rebuild vm with real context once available
            if vm.onSignedIn == nil {
                let auth = AuthService()
                let session = SessionService()
                let newVM = SignInViewModel(authService: auth, sessionService: session, modelContext: modelContext)
                newVM.onSignedIn = { route in
                    appVM.handleSignedIn(context: modelContext, newRoute: route)
                }
                _vm.wrappedValue = newVM
            }
        }
    }
}

#Preview {
    SignInView()
}


