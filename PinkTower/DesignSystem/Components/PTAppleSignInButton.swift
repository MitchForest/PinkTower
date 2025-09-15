import SwiftUI
import AuthenticationServices

struct PTAppleSignInButton: View {
    let onRequest: (ASAuthorizationAppleIDRequest) -> Void
    let onCompletion: (Result<ASAuthorization, Error>) -> Void

    var body: some View {
        SignInWithAppleButton(.signIn, onRequest: onRequest, onCompletion: onCompletion)
            .signInWithAppleButtonStyle(.white)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .fill(PTColors.accent)
                    .allowsHitTesting(false)
            )
            .overlay(
                HStack(spacing: 8) {
                    Image(systemName: "apple.logo").font(.system(size: PTIconSize.small.rawValue, weight: .semibold))
                    Text("Sign in with Apple")
                        .font(PTTypography.subtitle)
                }
                .foregroundStyle(Color.white)
                .allowsHitTesting(false)
            )
    }
}


