//
//  PriceService.swift
//  TradeFly AI
//
//  Fetches LIVE stock and crypto prices from Yahoo Finance API

import Foundation
import Combine

@MainActor
class PriceService: ObservableObject {
    static let shared = PriceService()

    @Published var cachedPrices: [String: TickerPrice] = [:]
    @Published var isLoading = false

    private var updateTimer: AnyCancellable?
    private let session = URLSession.shared

    private init() {
        startAutoUpdate()
    }

    // Auto-refresh prices every 15 seconds
    func startAutoUpdate() {
        updateTimer = Timer.publish(every: 15, on: .main, in: .common)
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

        // Fetch in batches of 10 to avoid overwhelming the API
        let batches = stride(from: 0, to: tickers.count, by: 10).map {
            Array(tickers[$0..<min($0 + 10, tickers.count)])
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

    // Fetch single ticker price from Yahoo Finance
    private func fetchSinglePrice(ticker: String) async -> TickerPrice? {
        // Use Yahoo Finance quote API
        let urlString = "https://query1.finance.yahoo.com/v8/finance/chart/\(ticker)?interval=1d&range=1d"

        guard let url = URL(string: urlString) else { return nil }

        do {
            let (data, _) = try await session.data(from: url)
            let response = try JSONDecoder().decode(YahooFinanceResponse.self, from: data)

            guard let result = response.chart.result.first,
                  let quote = result.indicators.quote.first else {
                return nil
            }

            // Get current price - try close first, then open
            guard let currentPrice = quote.close?.compactMap({ $0 }).last ?? quote.open?.compactMap({ $0 }).last else {
                return nil
            }

            guard let previousClose = result.meta.previousClose else {
                return nil
            }

            let change = currentPrice - previousClose
            let changePercent = (change / previousClose) * 100
            let volume = quote.volume?.compactMap({ $0 }).last ?? 0

            return TickerPrice(
                ticker: ticker,
                name: result.meta.longName ?? ticker,
                lastPrice: currentPrice,
                change: change,
                changePercent: changePercent,
                volume: volume,
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
        // Return cached if less than 30 seconds old
        if let cached = cachedPrices[ticker],
           Date().timeIntervalSince(cached.timestamp) < 30 {
            return cached
        }

        // Fetch fresh price
        return await fetchSinglePrice(ticker: ticker)
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

// MARK: - Yahoo Finance API Response Models

struct YahooFinanceResponse: Codable {
    let chart: ChartResponse
}

struct ChartResponse: Codable {
    let result: [ChartResult]
    let error: String?
}

struct ChartResult: Codable {
    let meta: ChartMeta
    let timestamp: [Int]?
    let indicators: ChartIndicators
}

struct ChartMeta: Codable {
    let currency: String?
    let symbol: String
    let regularMarketPrice: Double?
    let previousClose: Double?
    let longName: String?
}

struct ChartIndicators: Codable {
    let quote: [QuoteData]
}

struct QuoteData: Codable {
    let open: [Double?]?
    let high: [Double?]?
    let low: [Double?]?
    let close: [Double?]?
    let volume: [Int?]?
}
