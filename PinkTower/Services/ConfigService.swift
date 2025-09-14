import Foundation

protocol ConfigServiceProtocol {
    func openAIAPIKey() -> String?
    func setOpenAIAPIKey(_ key: String?)
}

struct ConfigService: ConfigServiceProtocol {
    private let keychainKey = "openai_api_key"

    func openAIAPIKey() -> String? {
        if let key = Keychain.shared.string(forKey: keychainKey) { return key }
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
           let key = dict["OPENAI_API_KEY"] as? String, !key.isEmpty {
            return key
        }
        return nil
    }

    func setOpenAIAPIKey(_ key: String?) {
        if let key = key, !key.isEmpty {
            Keychain.shared.set(key, forKey: keychainKey)
        } else {
            Keychain.shared.remove(forKey: keychainKey)
        }
    }
}


