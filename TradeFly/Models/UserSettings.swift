//
//  UserSettings.swift
//  TradeFly AI
//

import Foundation
import Combine

class UserSettings: ObservableObject {
    @Published var capital: Double {
        didSet {
            recalculateStrategy()
            save()
        }
    }

    @Published var dailyProfitGoal: Double {
        didSet {
            recalculateStrategy()
            save()
        }
    }

    @Published var experienceLevel: ExperienceLevel {
        didSet { save() }
    }

    @Published var tradingStyle: TradingStyle {
        didSet {
            recalculateStrategy()
            save()
        }
    }

    // Calculated strategy values
    @Published var positionSizeMin: Double = 0
    @Published var positionSizeMax: Double = 0
    @Published var tradesPerDay: Int = 2
    @Published var returnPerTrade: Double = 0
    @Published var riskPerTrade: Double = 0
    @Published var achievabilityScore: Int = 0
    @Published var achievabilityMessage: String = ""

    private let defaults = UserDefaults.standard

    init() {
        self.capital = defaults.double(forKey: "capital") != 0 ? defaults.double(forKey: "capital") : 10000
        self.dailyProfitGoal = defaults.double(forKey: "dailyProfitGoal") != 0 ? defaults.double(forKey: "dailyProfitGoal") : 300

        if let levelRaw = defaults.string(forKey: "experienceLevel"),
           let level = ExperienceLevel(rawValue: levelRaw) {
            self.experienceLevel = level
        } else {
            self.experienceLevel = .beginner
        }

        if let styleRaw = defaults.string(forKey: "tradingStyle"),
           let style = TradingStyle(rawValue: styleRaw) {
            self.tradingStyle = style
        } else {
            self.tradingStyle = .moderate
        }

        recalculateStrategy()
    }

    func save() {
        defaults.set(capital, forKey: "capital")
        defaults.set(dailyProfitGoal, forKey: "dailyProfitGoal")
        defaults.set(experienceLevel.rawValue, forKey: "experienceLevel")
        defaults.set(tradingStyle.rawValue, forKey: "tradingStyle")
    }

    func load() {
        // Trigger recalculation
        recalculateStrategy()
    }

    // MARK: - Strategy Recalibration
    func recalculateStrategy() {
        let dailyReturnPercentage = (dailyProfitGoal / capital) * 100

        // Calculate position sizing based on capital and style
        switch tradingStyle {
        case .conservative:
            positionSizeMin = capital * 0.25
            positionSizeMax = capital * 0.35
            tradesPerDay = 2
        case .moderate:
            positionSizeMin = capital * 0.30
            positionSizeMax = capital * 0.40
            tradesPerDay = 3
        case .aggressive:
            positionSizeMin = capital * 0.40
            positionSizeMax = capital * 0.50
            tradesPerDay = 4
        }

        // Calculate required return per trade
        returnPerTrade = dailyReturnPercentage / Double(tradesPerDay)

        // Risk per trade (typically 0.7-1.5%)
        riskPerTrade = min(returnPerTrade * 0.5, 1.5)

        // Calculate achievability score (1-10)
        achievabilityScore = calculateAchievabilityScore(dailyReturnPercentage: dailyReturnPercentage)
        achievabilityMessage = getAchievabilityMessage(score: achievabilityScore)
    }

    private func calculateAchievabilityScore(dailyReturnPercentage: Double) -> Int {
        switch dailyReturnPercentage {
        case 0..<1.5:
            return 10 // Very achievable
        case 1.5..<3:
            return 8 // Realistic
        case 3..<5:
            return 6 // Moderate challenge
        case 5..<7:
            return 4 // Aggressive
        case 7..<10:
            return 2 // Very aggressive
        default:
            return 1 // Unrealistic
        }
    }

    private func getAchievabilityMessage(score: Int) -> String {
        switch score {
        case 9...10:
            return "Very achievable! Conservative and sustainable goal."
        case 7...8:
            return "Realistic goal with moderate risk."
        case 5...6:
            return "Challenging but possible with discipline."
        case 3...4:
            return "Aggressive goal - requires high win rate."
        case 1...2:
            return "Very aggressive - consider lowering goal or increasing capital."
        default:
            return "Invalid goal"
        }
    }

    var strategyDescription: String {
        """
        Capital: $\(String(format: "%.0f", capital))
        Daily Goal: $\(String(format: "%.0f", dailyProfitGoal)) (\(String(format: "%.1f", (dailyProfitGoal/capital)*100))% return)

        Strategy:
        • Position Size: $\(String(format: "%.0f", positionSizeMin))-\(String(format: "%.0f", positionSizeMax))
        • Trades per Day: \(tradesPerDay)
        • Return per Trade: +\(String(format: "%.1f", returnPerTrade))%
        • Risk per Trade: \(String(format: "%.1f", riskPerTrade))%

        Achievability: \(achievabilityScore)/10
        \(achievabilityMessage)
        """
    }
}

enum ExperienceLevel: String, Codable, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case experienced = "Experienced"

    var description: String {
        switch self {
        case .beginner:
            return "I'm new to trading"
        case .intermediate:
            return "I've traded before but want to improve"
        case .experienced:
            return "I understand trading concepts"
        }
    }
}

enum TradingStyle: String, Codable, CaseIterable {
    case conservative = "Conservative"
    case moderate = "Moderate"
    case aggressive = "Aggressive"

    var description: String {
        switch self {
        case .conservative:
            return "2 trades/day, +8-10% targets\nLower frequency, higher quality"
        case .moderate:
            return "2-3 trades/day, +10-15% targets\nBalanced approach (Recommended)"
        case .aggressive:
            return "3-5 trades/day, +15-20% targets\nHigher frequency, more risk"
        }
    }

    var emoji: String {
        switch self {
        case .conservative: return "🐢"
        case .moderate: return "⚖️"
        case .aggressive: return "🚀"
        }
    }
}
