import Foundation
import SwiftData

enum AppRoute {
    case signIn
    case promptCreateOrganization
    case promptJoinOrganization
    case promptCreateClassroom
    case main
}

enum AuthState { case notAuthenticated, authenticated }
enum OrgState { case none, haveOrgsNoActive, active(orgId: UUID) }
enum ClassroomState { case none, one(classroomId: UUID), many }

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
            // Ensure we always have a loaded session (guide + default classroom)
            // even when the initial route is onboarding/empty-state.
            try loadSession(context: context)
            recalcRoute(context: context)
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
        recalcRoute(context: context)
    }

    func signOut() {
        Keychain.shared.remove(forKey: "appleUserId")
        self.currentGuide = nil
        self.selectedClassroomId = nil
        self.route = .signIn
    }

    // MARK: - State machine
    func recalcRoute(context: ModelContext) {
        let auth: AuthState = Keychain.shared.string(forKey: "appleUserId") == nil ? .notAuthenticated : .authenticated
        guard auth == .authenticated else { self.route = .signIn; return }

        guard let guide = currentGuide else { self.route = .signIn; return }

        // Org
        let gid = guide.id
        let memberships = (try? context.fetch(FetchDescriptor<Membership>(predicate: #Predicate { $0.guideId == gid }))) ?? []
        let orgState: OrgState = memberships.isEmpty ? .none : .active(orgId: memberships.first!.orgId)

        switch orgState {
        case .none:
            self.route = .promptCreateOrganization
            return
        case .haveOrgsNoActive:
            self.route = .promptCreateOrganization
            return
        case .active(let orgId):
            // Classrooms in active org
            let oid = orgId
            let rooms = (try? context.fetch(FetchDescriptor<Classroom>(predicate: #Predicate { $0.orgId == oid }))) ?? []
            let classState: ClassroomState
            if rooms.isEmpty { classState = .none }
            else if rooms.count == 1 { classState = .one(classroomId: rooms[0].id) }
            else { classState = .many }

            switch classState {
            case .none:
                self.route = .promptCreateClassroom
            case .one(let cid):
                self.selectedClassroomId = cid
                self.route = .main
            case .many:
                self.route = .main
            }
        }
    }
}


