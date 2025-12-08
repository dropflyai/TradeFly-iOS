//
//  BackendAPIModels.swift
//  TradeFly
//
//  Response models for TradeFly Backend API
//

import Foundation

// MARK: - Market Status

struct MarketStatusResponse: Codable {
    let status: String
    let statusText: String
    let isOpen: Bool
    let nextChange: String?
    let indices: MarketIndices
    let timestamp: String
}

struct MarketIndices: Codable {
    let spy: IndexData?
    let qqq: IndexData?
    let btc: IndexData?

    enum CodingKeys: String, CodingKey {
        case spy = "SPY"
        case qqq = "QQQ"
        case btc = "BTC"
    }
}

struct IndexData: Codable {
    let price: Double
    let changePercent: Double
}

// MARK: - Price

struct PriceResponse: Codable {
    let ticker: String
    let price: Double
    let timestamp: String
    let open: Double
    let high: Double
    let low: Double
    let volume: Int
    let vwap: Double?
    let ema9: Double?
    let ema20: Double?
    let ema50: Double?
}

// MARK: - News

struct NewsResponse: Codable {
    let ticker: String
    let newsCount: Int
    let news: [NewsArticle]
    let sentimentSummary: String?
}

struct MarketNewsResponse: Codable {
    let newsCount: Int
    let news: [NewsArticle]
    let summary: String?
}

struct NewsArticle: Codable {
    let title: String
    let url: String?
    let source: String?
    let publishedAt: String?
    let summary: String?
    let sentiment: String?
}

// MARK: - Candles

struct CandlesResponse: Codable {
    let ticker: String
    let interval: String
    let candleCount: Int
    let candles: [Candle]
}

struct Candle: Codable {
    let timestamp: String
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Int
}

// MARK: - Health

struct HealthResponse: Codable {
    let status: String
    let supabase: String
    let marketData: String
    let activeSignals: Int
    let scheduler: String
}

// MARK: - Stats

struct StatsResponse: Codable {
    let totalActiveSignals: Int
    let byQuality: QualityCounts
    let tickersWatched: Int
    let scanInterval: Int
}

struct QualityCounts: Codable {
    let high: Int
    let medium: Int
    let low: Int

    enum CodingKeys: String, CodingKey {
        case high = "HIGH"
        case medium = "MEDIUM"
        case low = "LOW"
    }
}
