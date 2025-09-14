import Foundation
import SwiftData

enum AppRoute {
    case signIn
    case promptCreateClassroom
    case main
}

final class AppViewModel: ObservableObject {
    @Published var route: AppRoute = .signIn
    @Published var selectedClassroomId: UUID?
    @Published var currentGuide: Guide?

    private let sessionService: SessionServiceProtocol
    
    init(sessionService: SessionServiceProtocol = SessionService()) {
        self.sessionService = sessionService
    }

    func bootstrap(context: ModelContext) {
        do {
            let route = try sessionService.determineInitialRoute(context: context)
            self.route = route
            if case .main = route {
                try loadSession(context: context)
            }
        } catch {
            self.route = .signIn
        }
    }

    func loadSession(context: ModelContext) throws {
        guard let userId = Keychain.shared.string(forKey: "appleUserId") else { return }
        let guide = try sessionService.getOrCreateGuide(forAppleUserId: userId, context: context)
        self.currentGuide = guide
        self.selectedClassroomId = guide.defaultClassroomId
    }

    func handleSignedIn(context: ModelContext, newRoute: AppRoute) {
        self.route = newRoute
        try? loadSession(context: context)
    }

    func signOut() {
        Keychain.shared.remove(forKey: "appleUserId")
        self.currentGuide = nil
        self.selectedClassroomId = nil
        self.route = .signIn
    }
}


