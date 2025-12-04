//
//  TradingSignal.swift
//  TradeFly AI
//

import Foundation

struct TradingSignal: Identifiable, Codable {
    let id: String
    let ticker: String
    let signalType: SignalType
    let quality: Quality
    let timestamp: Date
    let price: Double
    let vwap: Double
    let ema9: Double
    let ema20: Double
    let ema50: Double
    let volume: Int
    let context: String
    let idea: TradeIdea
    let entry: PriceRange
    let stopLoss: Double
    let target: Double
    let targetPercentage: Double
    let timeframe: String
    let assetType: AssetType
    let signalStrength: Double // 0-100
    let successProbability: Double // 0-100

    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }

    var qualityIcon: String {
        switch quality {
        case .high: return "⭐⭐⭐"
        case .medium: return "⭐⭐"
        case .low: return "⭐"
        }
    }

    var qualityColor: String {
        switch quality {
        case .high: return "green"
        case .medium: return "yellow"
        case .low: return "red"
        }
    }

    var potentialProfit: Double {
        // Calculate based on typical position size
        return 0 // Will be calculated based on user settings
    }
}

enum SignalType: String, Codable {
    case orbBreakoutLong = "ORB_BREAKOUT_LONG"
    case vwapReclaimLong = "VWAP_RECLAIM_LONG"
    case emaTrendLong = "EMA_TREND_CONTINUATION_LONG"
    case hodBreakoutLong = "HOD_BREAKOUT_LONG"
    case orbBreakdownPut = "ORB_BREAKDOWN_PUT"
    case vwapRejectPut = "VWAP_REJECT_PUT"
    case lodBreakPut = "LOD_BREAK_PUT"

    var displayName: String {
        switch self {
        case .orbBreakoutLong: return "ORB Breakout LONG"
        case .vwapReclaimLong: return "VWAP Reclaim LONG"
        case .emaTrendLong: return "EMA Trend LONG"
        case .hodBreakoutLong: return "HOD Breakout LONG"
        case .orbBreakdownPut: return "ORB Breakdown PUT"
        case .vwapRejectPut: return "VWAP Reject PUT"
        case .lodBreakPut: return "LOD Break PUT"
        }
    }

    var description: String {
        switch self {
        case .orbBreakoutLong:
            return "Opening Range Breakout above - Price breaks above the first 5-minute range with volume"
        case .vwapReclaimLong:
            return "Price reclaims VWAP after being below - Strong bullish signal"
        case .emaTrendLong:
            return "EMA alignment with bullish trend - All EMAs pointing up"
        case .hodBreakoutLong:
            return "High of Day breakout - Price makes new high with volume"
        case .orbBreakdownPut:
            return "Opening Range Breakdown below - Price breaks below the first 5-minute range"
        case .vwapRejectPut:
            return "Price rejects VWAP downward - Strong bearish signal"
        case .lodBreakPut:
            return "Low of Day breakdown - Price makes new low with volume"
        }
    }
}

enum Quality: String, Codable {
    case high = "HIGH"
    case medium = "MEDIUM"
    case low = "LOW"

    var score: Int {
        switch self {
        case .high: return 3
        case .medium: return 2
        case .low: return 1
        }
    }
}

enum TradeIdea: String, Codable {
    case call = "CALL"
    case put = "PUT"
    case skip = "SKIP"
}

enum AssetType: String, Codable {
    case stock = "STOCK"
    case crypto = "CRYPTO"

    var displayName: String {
        switch self {
        case .stock: return "Stocks"
        case .crypto: return "Crypto"
        }
    }
}

struct PriceRange: Codable {
    let low: Double
    let high: Double

    var formatted: String {
        return "$\(String(format: "%.2f", low)) - $\(String(format: "%.2f", high))"
    }
}

// MARK: - Preview Sample (for SwiftUI previews only)
#if DEBUG
extension TradingSignal {
    static let previewSample = TradingSignal(
        id: UUID().uuidString,
        ticker: "NVDA",
        signalType: .vwapReclaimLong,
        quality: .high,
        timestamp: Date(),
        price: 188.20,
        vwap: 187.90,
        ema9: 188.10,
        ema20: 187.70,
        ema50: 186.90,
        volume: 1250000,
        context: "Strong VWAP reclaim with rising volume and bullish EMA alignment",
        idea: .call,
        entry: PriceRange(low: 188.10, high: 188.30),
        stopLoss: 187.80,
        target: 188.20 * 1.12,
        targetPercentage: 12.0,
        timeframe: "1min",
        assetType: .stock,
        signalStrength: 92.0,
        successProbability: 78.0
    )
}
#endif
