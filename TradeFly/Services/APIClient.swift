//
//  APIClient.swift
//  TradeFly AI
//

import Foundation

class APIClient {
    static let shared = APIClient()

    // TODO: Replace with your actual backend URL (or use Supabase)
    private let baseURL = "https://api.tradefly.ai" // Placeholder

    private init() {}

    func fetchSignals(completion: @escaping (Result<[TradingSignal], Error>) -> Void) {
        // TODO: Implement actual API call
        // For now, return sample data after delay to simulate network

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // NO SAMPLE DATA - return empty array
            completion(.success([]))
        }
    }

    func submitTrade(_ trade: Trade, completion: @escaping (Result<Void, Error>) -> Void) {
        // TODO: Implement actual API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(.success(()))
        }
    }

    func updateUserSettings(_ settings: UserSettings, completion: @escaping (Result<Void, Error>) -> Void) {
        // TODO: Implement actual API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(.success(()))
        }
    }

    func fetchEducationalContent(completion: @escaping (Result<[LearningModule], Error>) -> Void) {
        // TODO: Implement actual API call
        // NO SAMPLE DATA - Fetch from Supabase
        Task {
            do {
                let modules = try await SupabaseService.shared.fetchLearningModules()
                await MainActor.run {
                    completion(.success(modules))
                }
            } catch {
                await MainActor.run {
                    completion(.failure(error))
                }
            }
        }
    }
}

// MARK: - API Error
enum APIError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    case serverError(String)

    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingError:
            return "Failed to decode response"
        case .serverError(let message):
            return message
        }
    }
}
