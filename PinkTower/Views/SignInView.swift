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
        _vm = StateObject(wrappedValue: SignInViewModel(authService: auth, sessionService: session))
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

            PTAppleSignInButton(onRequest: { request in
                request.requestedScopes = [.fullName, .email]
            }, onCompletion: { result in
                switch result {
                case .success(let auth):
                    Task { await vm.handleAuthorization(auth) }
                case .failure(let error):
                    vm.errorMessage = error.localizedDescription
                }
            })
            .frame(maxWidth: 400, minHeight: 56, maxHeight: 56)
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
            // Provide the real context and callback once available
            vm.setModelContext(modelContext)
            if vm.onSignedIn == nil {
                vm.onSignedIn = { route in
                    appVM.handleSignedIn(context: modelContext, newRoute: route)
                }
            }
        }
    }
}

#Preview {
    SignInView()
}


