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
                    Image(systemName: "apple.logo").font(.system(size: 18, weight: .semibold))
                    Text("Sign in with Apple")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(Color.white)
                .allowsHitTesting(false)
            )
    }
}


