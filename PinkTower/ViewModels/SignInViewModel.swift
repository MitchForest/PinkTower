import Foundation
import AuthenticationServices
import SwiftData

@MainActor
final class SignInViewModel: ObservableObject {
    private let authService: AuthServiceProtocol
    private let sessionService: SessionServiceProtocol
    private let modelContext: ModelContext
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    var onSignedIn: ((AppRoute) -> Void)?

    init(authService: AuthServiceProtocol, sessionService: SessionServiceProtocol, modelContext: ModelContext) {
        self.authService = authService
        self.sessionService = sessionService
        self.modelContext = modelContext
    }

    func handleAuthorization(_ authorization: ASAuthorization) async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let userId = try authService.extractAppleUserId(from: authorization)
            _ = try sessionService.getOrCreateGuide(forAppleUserId: userId, context: modelContext)
            let route = try sessionService.determineInitialRoute(context: modelContext)
            onSignedIn?(route)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}


