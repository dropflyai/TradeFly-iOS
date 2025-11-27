//
//  LearningModule.swift
//  TradeFly AI
//

import Foundation

struct LearningModule: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let category: LearningCategory
    let durationMinutes: Int
    let difficulty: Difficulty
    let isCompleted: Bool
    let videoURL: String?
    let content: String

    var durationText: String {
        "\(durationMinutes) min"
    }

    var progressStars: String {
        isCompleted ? "⭐⭐⭐⭐⭐" : "⭐☆☆☆☆"
    }
}

enum LearningCategory: String, Codable, CaseIterable {
    case fundamentals = "Trading Fundamentals"
    case indicators = "Technical Indicators"
    case strategies = "Trading Strategies"
    case riskManagement = "Risk Management"
    case psychology = "Trading Psychology"

    var icon: String {
        switch self {
        case .fundamentals: return "book.fill"
        case .indicators: return "chart.bar.fill"
        case .strategies: return "target"
        case .riskManagement: return "shield.fill"
        case .psychology: return "brain.head.profile"
        }
    }
}

enum Difficulty: String, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
}

// MARK: - Sample Data
extension LearningModule {
    static let samples: [LearningModule] = [
        LearningModule(
            id: "1",
            title: "What is VWAP?",
            description: "Learn about Volume Weighted Average Price and why it matters",
            category: .indicators,
            durationMinutes: 3,
            difficulty: .beginner,
            isCompleted: true,
            videoURL: nil,
            content: """
            VWAP (Volume Weighted Average Price) is the average price weighted by volume.

            ## Why It Matters
            - Shows where institutions are buying/selling
            - Acts as support/resistance
            - Price above VWAP = bullish
            - Price below VWAP = bearish

            ## Trading with VWAP
            - Look for reclaims after being below
            - Watch for rejections when testing from below
            - Use as dynamic support/resistance
            """
        ),
        LearningModule(
            id: "2",
            title: "Understanding EMAs",
            description: "Exponential Moving Averages and trend identification",
            category: .indicators,
            durationMinutes: 4,
            difficulty: .beginner,
            isCompleted: false,
            videoURL: nil,
            content: """
            EMAs (Exponential Moving Averages) show price trends by giving more weight to recent prices.

            ## The 3 EMAs We Use
            - EMA 9: Short-term momentum
            - EMA 20: Medium-term trend
            - EMA 50: Long-term trend

            ## Perfect Alignment
            Bullish: EMA9 > EMA20 > EMA50 (all pointing up)
            Bearish: EMA9 < EMA20 < EMA50 (all pointing down)

            ## Trading Signals
            - Crossovers indicate trend changes
            - Use EMAs as dynamic support/resistance
            - Price bouncing off EMA = continuation opportunity
            """
        ),
        LearningModule(
            id: "3",
            title: "Day Trading Basics",
            description: "Essential concepts every day trader must know",
            category: .fundamentals,
            durationMinutes: 5,
            difficulty: .beginner,
            isCompleted: true,
            videoURL: nil,
            content: """
            ## What is Day Trading?
            Opening and closing positions within the same trading day.

            ## Key Rules
            1. Never hold overnight
            2. Cut losses quickly
            3. Take profits at target
            4. Don't overtrade
            5. Focus on high-quality setups

            ## Success Factors
            - Discipline
            - Risk management
            - Consistent strategy
            - Emotional control
            """
        ),
        LearningModule(
            id: "4",
            title: "Opening Range Breakouts",
            description: "Master the ORB strategy",
            category: .strategies,
            durationMinutes: 8,
            difficulty: .intermediate,
            isCompleted: false,
            videoURL: nil,
            content: """
            ## What is an ORB?
            The Opening Range is the high/low of the first 5-15 minutes.

            ## The Setup
            1. Identify the opening range
            2. Wait for breakout above high or below low
            3. Confirm with volume
            4. Enter on breakout

            ## Entry Rules
            - Must have volume spike
            - Should be above VWAP for longs
            - Clean candle structure
            - Best in first 30 minutes

            ## Targets
            - First target: 1-2% for stocks
            - Second target: Previous resistance/support
            - Options: +10-15%
            """
        ),
        LearningModule(
            id: "5",
            title: "Risk Management 101",
            description: "Protect your capital and stay in the game",
            category: .riskManagement,
            durationMinutes: 6,
            difficulty: .beginner,
            isCompleted: false,
            videoURL: nil,
            content: """
            ## The Golden Rules
            1. Never risk more than 1-2% per trade
            2. Always use stop losses
            3. Position size based on risk
            4. Maximum daily loss limit

            ## Position Sizing
            Risk Amount = Account Size × Risk %
            Position Size = Risk Amount / Stop Distance

            Example:
            - Account: $10,000
            - Risk: 1% = $100
            - Stop: 2% away
            - Position: $5,000

            ## Stop Loss Placement
            - Below VWAP for longs
            - Above VWAP for shorts
            - Below support / above resistance
            - Maximum 7% from entry
            """
        )
    ]

    static func modulesByCategory() -> [LearningCategory: [LearningModule]] {
        Dictionary(grouping: samples) { $0.category }
    }
}
