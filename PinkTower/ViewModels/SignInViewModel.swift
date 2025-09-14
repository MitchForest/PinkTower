import Foundation
import AuthenticationServices
import SwiftData

@MainActor
final class SignInViewModel: ObservableObject {
    private let authService: AuthServiceProtocol
    private let sessionService: SessionServiceProtocol
    private var modelContext: ModelContext?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    var onSignedIn: ((AppRoute) -> Void)?

    init(authService: AuthServiceProtocol, sessionService: SessionServiceProtocol, modelContext: ModelContext? = nil) {
        self.authService = authService
        self.sessionService = sessionService
        self.modelContext = modelContext
    }

    func setModelContext(_ context: ModelContext) { self.modelContext = context }

    func handleAuthorization(_ authorization: ASAuthorization) async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            guard let ctx = modelContext else { errorMessage = "Internal error: missing context"; return }
            let userId = try authService.extractAppleUserId(from: authorization)
            _ = try sessionService.getOrCreateGuide(forAppleUserId: userId, context: ctx)
            let route = try sessionService.determineInitialRoute(context: ctx)
            onSignedIn?(route)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}


