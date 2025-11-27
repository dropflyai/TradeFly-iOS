//
//  Trade.swift
//  TradeFly AI
//

import Foundation

struct Trade: Identifiable, Codable {
    let id: String
    let signal: TradingSignal
    let entryPrice: Double
    let exitPrice: Double?
    let positionSize: Double
    let quantity: Int
    let entryTime: Date
    let exitTime: Date?
    let status: TradeStatus
    let profitLoss: Double?
    let profitLossPercentage: Double?
    let notes: String?

    var isOpen: Bool {
        status == .open
    }

    var formattedProfitLoss: String {
        guard let pl = profitLoss else { return "N/A" }
        let sign = pl >= 0 ? "+" : ""
        return "\(sign)$\(String(format: "%.2f", pl))"
    }

    var formattedProfitLossPercentage: String {
        guard let plPct = profitLossPercentage else { return "N/A" }
        let sign = plPct >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", plPct))%"
    }
}

enum TradeStatus: String, Codable {
    case open = "Open"
    case closed = "Closed"
    case stopped = "Stopped Out"
    case targetHit = "Target Hit"
}

// MARK: - Sample Data
extension Trade {
    static let sample = Trade(
        id: UUID().uuidString,
        signal: TradingSignal.sample,
        entryPrice: 188.20,
        exitPrice: 210.64,
        positionSize: 1000,
        quantity: 5,
        entryTime: Date().addingTimeInterval(-3600),
        exitTime: Date(),
        status: .targetHit,
        profitLoss: 120,
        profitLossPercentage: 12.0,
        notes: "Perfect setup, followed plan"
    )

    static let samples: [Trade] = [
        sample,
        Trade(
            id: UUID().uuidString,
            signal: TradingSignal.samples[1],
            entryPrice: 175.80,
            exitPrice: 193.38,
            positionSize: 1200,
            quantity: 6,
            entryTime: Date().addingTimeInterval(-7200),
            exitTime: Date().addingTimeInterval(-3600),
            status: .targetHit,
            profitLoss: 132,
            profitLossPercentage: 11.0,
            notes: "Great ORB setup"
        ),
        Trade(
            id: UUID().uuidString,
            signal: TradingSignal.samples[2],
            entryPrice: 242.10,
            exitPrice: nil,
            positionSize: 1000,
            quantity: 4,
            entryTime: Date().addingTimeInterval(-1800),
            exitTime: nil,
            status: .open,
            profitLoss: nil,
            profitLossPercentage: nil,
            notes: nil
        )
    ]
}
