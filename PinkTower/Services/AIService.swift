import Foundation

enum AIError: Error {
    case missingAPIKey
    case notImplemented
}

protocol AIServiceProtocol {
    func transcribeAudio(url: URL, apiKey: String?) async throws -> String
    func generateSummary(for studentId: UUID, periodLabel: String, contextText: String, apiKey: String?) async throws -> String
    func generateInsights(for studentId: UUID, periodLabel: String, contextText: String, apiKey: String?) async throws -> [String]
}

struct AIService: AIServiceProtocol {
    func transcribeAudio(url: URL, apiKey: String?) async throws -> String {
        guard let _ = apiKey else { throw AIError.missingAPIKey }
        // Placeholder for OpenAI Whisper request. Implement in a later step.
        throw AIError.notImplemented
    }

    func generateSummary(for studentId: UUID, periodLabel: String, contextText: String, apiKey: String?) async throws -> String {
        guard let _ = apiKey else { throw AIError.missingAPIKey }
        // Placeholder for GPT call. Implement in a later step.
        throw AIError.notImplemented
    }

    func generateInsights(for studentId: UUID, periodLabel: String, contextText: String, apiKey: String?) async throws -> [String] {
        guard let _ = apiKey else { throw AIError.missingAPIKey }
        // Placeholder for GPT call. Implement in a later step.
        throw AIError.notImplemented
    }
}


