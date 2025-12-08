//
//  APIClient.swift
//  TradeFly AI
//

import Foundation

class APIClient {
    static let shared = APIClient()

    private let session: URLSession

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
    }

    // MARK: - Market Status

    func fetchMarketStatus() async throws -> MarketStatusResponse {
        guard let url = BackendConfig.Endpoint.marketStatus.url else {
            throw APIError.invalidURL
        }

        let (data, response) = try await session.data(from: url)
        try validateResponse(response)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(MarketStatusResponse.self, from: data)
    }

    // MARK: - Real-time Price

    func fetchPrice(ticker: String) async throws -> PriceResponse {
        guard let url = BackendConfig.Endpoint.price(ticker: ticker).url else {
            throw APIError.invalidURL
        }

        let (data, response) = try await session.data(from: url)
        try validateResponse(response)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(PriceResponse.self, from: data)
    }

    // MARK: - News

    func fetchTickerNews(ticker: String, hoursBack: Int = 4) async throws -> NewsResponse {
        guard let url = BackendConfig.Endpoint.news(ticker: ticker, hoursBack: hoursBack).url else {
            throw APIError.invalidURL
        }

        let (data, response) = try await session.data(from: url)
        try validateResponse(response)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(NewsResponse.self, from: data)
    }

    func fetchMarketNews(hoursBack: Int = 6) async throws -> MarketNewsResponse {
        guard let url = BackendConfig.Endpoint.marketNews(hoursBack: hoursBack).url else {
            throw APIError.invalidURL
        }

        let (data, response) = try await session.data(from: url)
        try validateResponse(response)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(MarketNewsResponse.self, from: data)
    }

    // MARK: - Candles (for charting)

    func fetchCandles(ticker: String, interval: String = "1m", limit: Int = 100) async throws -> CandlesResponse {
        guard let url = BackendConfig.Endpoint.candles(ticker: ticker, interval: interval, limit: limit).url else {
            throw APIError.invalidURL
        }

        let (data, response) = try await session.data(from: url)
        try validateResponse(response)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(CandlesResponse.self, from: data)
    }

    // MARK: - Health Check

    func checkHealth() async throws -> HealthResponse {
        guard let url = BackendConfig.Endpoint.health.url else {
            throw APIError.invalidURL
        }

        let (data, response) = try await session.data(from: url)
        try validateResponse(response)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(HealthResponse.self, from: data)
    }

    // MARK: - Manual Signal Scan

    func triggerSignalScan() async throws {
        guard let url = BackendConfig.Endpoint.scanSignals.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let (_, response) = try await session.data(for: request)
        try validateResponse(response)
    }

    // MARK: - Backend Stats

    func fetchStats() async throws -> StatsResponse {
        guard let url = BackendConfig.Endpoint.stats.url else {
            throw APIError.invalidURL
        }

        let (data, response) = try await session.data(from: url)
        try validateResponse(response)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(StatsResponse.self, from: data)
    }

    // MARK: - Legacy Methods (for compatibility)

    func fetchSignals(completion: @escaping (Result<[TradingSignal], Error>) -> Void) {
        // NOTE: Signals come from Supabase, not backend API
        // This is kept for compatibility but returns empty
        completion(.success([]))
    }

    func submitTrade(_ trade: Trade, completion: @escaping (Result<Void, Error>) -> Void) {
        // Trades are stored in Supabase
        completion(.success(()))
    }

    func updateUserSettings(_ settings: UserSettings, completion: @escaping (Result<Void, Error>) -> Void) {
        // Settings stored in Supabase
        completion(.success(()))
    }

    func fetchEducationalContent(completion: @escaping (Result<[LearningModule], Error>) -> Void) {
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

    // MARK: - Helper Methods

    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError("HTTP \(httpResponse.statusCode)")
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
