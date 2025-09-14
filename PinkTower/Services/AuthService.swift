import Foundation
import AuthenticationServices
import UIKit

protocol AuthServiceProtocol {
    func extractAppleUserId(from authorization: ASAuthorization) throws -> String
    func signOut()
    var currentAppleUserId: String? { get }
}

final class AuthService: NSObject, AuthServiceProtocol {
    private let keychainKey = "appleUserId"

    var currentAppleUserId: String? {
        Keychain.shared.string(forKey: keychainKey)
    }

    func extractAppleUserId(from authorization: ASAuthorization) throws -> String {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid credential"])
        }
        let userId = credential.user
        Keychain.shared.set(userId, forKey: keychainKey)
        return userId
    }

    func signOut() {
        Keychain.shared.remove(forKey: keychainKey)
    }
}

// MARK: - Helper keychain

final class Keychain {
    static let shared = Keychain()
    private init() {}

    func set(_ value: String, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key) // Placeholder; replace with real Keychain later
    }

    func string(forKey key: String) -> String? {
        UserDefaults.standard.string(forKey: key)
    }

    func remove(forKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

// (Real Keychain storage can replace this later.)


