//
//  PriceService.swift
//  TradeFly AI
//
//  Fetches LIVE stock and crypto prices from Polygon.io API

import Foundation
import Combine

@MainActor
class PriceService: ObservableObject {
    static let shared = PriceService()

    @Published var cachedPrices: [String: TickerPrice] = [:]
    @Published var isLoading = false

    private var updateTimer: AnyCancellable?
    private let session = URLSession.shared
    private let apiKey = SupabaseConfig.polygonAPIKey

    private init() {
        startAutoUpdate()
    }

    // Auto-refresh prices every 5 seconds for real-time updates
    func startAutoUpdate() {
        updateTimer = Timer.publish(every: 5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    await self?.refreshAllCachedTickers()
                }
            }
    }

    // Fetch multiple tickers at once
    func fetchPrices(for tickers: [String]) async -> [TickerPrice] {
        guard !tickers.isEmpty else { return [] }

        var results: [TickerPrice] = []

        // Fetch in batches of 5 to avoid rate limiting
        let batches = stride(from: 0, to: tickers.count, by: 5).map {
            Array(tickers[$0..<min($0 + 5, tickers.count)])
        }

        for batch in batches {
            await withTaskGroup(of: TickerPrice?.self) { group in
                for ticker in batch {
                    group.addTask {
                        await self.fetchSinglePrice(ticker: ticker)
                    }
                }

                for await result in group {
                    if let price = result {
                        results.append(price)
                        self.cachedPrices[price.ticker] = price
                    }
                }
            }
        }

        return results
    }

    // Fetch single ticker price from Polygon.io
    private func fetchSinglePrice(ticker: String) async -> TickerPrice? {
        // Use Polygon.io Previous Close endpoint for reliable data
        // This gives us the most recent trading day's data
        let urlString = "https://api.polygon.io/v2/aggs/ticker/\(ticker)/prev?adjusted=true&apiKey=\(apiKey)"

        guard let url = URL(string: urlString) else { return nil }

        do {
            let (data, response) = try await session.data(from: url)

            // Check for HTTP errors
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 401 {
                    print("❌ Polygon API Key invalid or missing. Please set SupabaseConfig.polygonAPIKey")
                    return cachedPrices[ticker]
                } else if httpResponse.statusCode == 429 {
                    print("⚠️ Polygon API rate limit exceeded. Consider upgrading your plan.")
                    return cachedPrices[ticker]
                } else if httpResponse.statusCode != 200 {
                    print("⚠️ Polygon API returned status \(httpResponse.statusCode) for \(ticker)")
                    return cachedPrices[ticker]
                }
            }

            let polygonResponse = try JSONDecoder().decode(PolygonPrevCloseResponse.self, from: data)

            guard let result = polygonResponse.results.first else {
                print("No data returned for \(ticker)")
                return cachedPrices[ticker]
            }

            let change = result.c - result.o
            let changePercent = (change / result.o) * 100

            return TickerPrice(
                ticker: ticker,
                name: ticker, // Polygon doesn't provide company name in this endpoint
                lastPrice: result.c,
                change: change,
                changePercent: changePercent,
                volume: result.v,
                timestamp: Date()
            )
        } catch {
            print("Error fetching price for \(ticker): \(error)")
            // Return cached price if available
            return cachedPrices[ticker]
        }
    }

    // Refresh all cached tickers
    private func refreshAllCachedTickers() async {
        let tickers = Array(cachedPrices.keys)
        guard !tickers.isEmpty else { return }

        _ = await fetchPrices(for: tickers)
    }

    // Get cached price or fetch new one
    func getPrice(for ticker: String) async -> TickerPrice? {
        // Return cached if less than 10 seconds old (for real-time feel)
        if let cached = cachedPrices[ticker],
           Date().timeIntervalSince(cached.timestamp) < 10 {
            return cached
        }

        // Fetch fresh price
        return await fetchSinglePrice(ticker: ticker)
    }

    // Get real-time quote (for paid Polygon plans)
    func getRealTimeQuote(for ticker: String) async -> TickerPrice? {
        let urlString = "https://api.polygon.io/v2/last/trade/\(ticker)?apiKey=\(apiKey)"

        guard let url = URL(string: urlString) else { return nil }

        do {
            let (data, _) = try await session.data(from: url)
            let response = try JSONDecoder().decode(PolygonLastTradeResponse.self, from: data)

            // Calculate change from cached or fetch previous close
            let previousPrice = cachedPrices[ticker]?.lastPrice ?? response.results.p
            let change = response.results.p - previousPrice
            let changePercent = (change / previousPrice) * 100

            return TickerPrice(
                ticker: ticker,
                name: ticker,
                lastPrice: response.results.p,
                change: change,
                changePercent: changePercent,
                volume: response.results.s,
                timestamp: Date()
            )
        } catch {
            print("Real-time quote failed for \(ticker), falling back to prev close: \(error)")
            return await fetchSinglePrice(ticker: ticker)
        }
    }
}

// MARK: - Models

struct TickerPrice: Codable {
    let ticker: String
    let name: String
    let lastPrice: Double
    let change: Double
    let changePercent: Double
    let volume: Int
    let timestamp: Date
}

// MARK: - Polygon.io API Response Models

struct PolygonPrevCloseResponse: Codable {
    let status: String
    let resultsCount: Int?
    let results: [PolygonBar]

    enum CodingKeys: String, CodingKey {
        case status
        case resultsCount
        case results
    }
}

struct PolygonBar: Codable {
    let v: Int        // Volume
    let vw: Double?   // Volume weighted average price
    let o: Double     // Open
    let c: Double     // Close
    let h: Double     // High
    let l: Double     // Low
    let t: Int        // Timestamp (milliseconds) - always provided
    let n: Int?       // Number of transactions
}

struct PolygonLastTradeResponse: Codable {
    let status: String
    let results: PolygonTrade
}

struct PolygonTrade: Codable {
    let p: Double     // Price
    let s: Int        // Size (volume)
    let t: Int?       // Timestamp
    let x: Int?       // Exchange ID
}
