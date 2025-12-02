//
//  ChartIndicator.swift
//  TradeFly
//
//  Educational content for technical indicators
//

import Foundation

struct ChartIndicator: Identifiable, Codable {
    let id: String
    let name: String
    let shortName: String
    let description: String
    let howToUse: String
    let bullishSignals: [String]
    let bearishSignals: [String]
    let bestTimeframes: [String]
    let tradeFlyUsage: String
    let icon: String
    let color: String

    // All indicators TradeFly uses
    static let allIndicators: [ChartIndicator] = [
        // VWAP
        ChartIndicator(
            id: "vwap",
            name: "Volume Weighted Average Price",
            shortName: "VWAP",
            description: "VWAP is the average price weighted by volume. It shows the true average price that participants paid throughout the day. Think of it as the 'fair value' line - institutions use it heavily.",
            howToUse: """
            VWAP is like a magnet:

            📊 When price is ABOVE VWAP:
            • Buyers are in control
            • Institutions are accumulating
            • Short-term bullish

            📊 When price is BELOW VWAP:
            • Sellers are in control
            • Distribution happening
            • Short-term bearish

            💡 Best Signals:
            • Reclaim: Price crosses from below to above VWAP with volume
            • Rejection: Price tries to cross VWAP but fails (wick above, close below)
            • Support/Resistance: VWAP acts as dynamic support in uptrends
            """,
            bullishSignals: [
                "Price crosses above VWAP with volume surge (VWAP Reclaim)",
                "Price bounces off VWAP as support in uptrend",
                "Price holds above VWAP throughout the day"
            ],
            bearishSignals: [
                "Price rejected at VWAP (tries to cross, fails)",
                "Price breaks below VWAP with volume",
                "Multiple failed attempts to reclaim VWAP"
            ],
            bestTimeframes: ["1-minute", "5-minute", "Intraday only"],
            tradeFlyUsage: "TradeFly's #1 indicator. We scan for VWAP reclaims (long) and VWAP rejections (short). Our signals require volume confirmation and multi-timeframe alignment.",
            icon: "chart.line.uptrend.xyaxis",
            color: "blue"
        ),

        // EMA 9
        ChartIndicator(
            id: "ema9",
            name: "9-Period Exponential Moving Average",
            shortName: "EMA 9",
            description: "The 9 EMA is a fast-moving average that reacts quickly to price changes. It shows the immediate short-term trend and acts as dynamic support/resistance in strong trends.",
            howToUse: """
            EMA 9 is your short-term trend guide:

            📈 In Uptrends:
            • Price stays above EMA 9
            • Pullbacks to EMA 9 are buying opportunities
            • Strong trends never break EMA 9

            📉 In Downtrends:
            • Price stays below EMA 9
            • Rallies to EMA 9 are selling opportunities
            • Breaking above EMA 9 = potential reversal

            💡 Power Move:
            EMA 9 > EMA 20 > EMA 50 = Perfect alignment (strong uptrend)
            EMA 9 < EMA 20 < EMA 50 = Perfect alignment (strong downtrend)
            """,
            bullishSignals: [
                "Price bounces off EMA 9 in uptrend (trend continuation)",
                "EMA 9 crosses above EMA 20 (golden cross)",
                "Price reclaims EMA 9 with volume (reversal)"
            ],
            bearishSignals: [
                "Price breaks below EMA 9 with volume",
                "EMA 9 crosses below EMA 20 (death cross)",
                "Price rejected at EMA 9 from below"
            ],
            bestTimeframes: ["1-minute", "5-minute", "15-minute"],
            tradeFlyUsage: "We use EMA 9 as short-term trend filter. For HIGH quality signals, price must respect EMA 9. Our 'EMA Bounce' pattern triggers when price pulls back to EMA 9 and bounces.",
            icon: "waveform.path",
            color: "green"
        ),

        // EMA 20
        ChartIndicator(
            id: "ema20",
            name: "20-Period Exponential Moving Average",
            shortName: "EMA 20",
            description: "The 20 EMA is a medium-term moving average. It's slower than EMA 9 but still responsive to price changes. Professional traders use it as a trend baseline.",
            howToUse: """
            EMA 20 is your trend anchor:

            🎯 Primary Use:
            • Defines the current trend direction
            • Acts as major support in uptrends
            • Acts as major resistance in downtrends

            📊 Trade Setup:
            • Price above EMA 20 = Look for longs
            • Price below EMA 20 = Look for shorts
            • Price at EMA 20 = Wait for confirmation

            💡 Pro Tip:
            When EMA 9 and EMA 20 are "stacked" (9 > 20 > 50), the trend is very strong. Trade WITH this stack, never against it.
            """,
            bullishSignals: [
                "Price above EMA 20 consistently",
                "Price bounces off EMA 20 as support",
                "EMA 20 sloping upward"
            ],
            bearishSignals: [
                "Price below EMA 20 consistently",
                "Price rejected at EMA 20 from below",
                "EMA 20 sloping downward"
            ],
            bestTimeframes: ["5-minute", "15-minute", "1-hour"],
            tradeFlyUsage: "We require EMA 20 alignment for HIGH signals. If taking a long, EMA 9 must be above EMA 20. We also use EMA 20 as a stop-loss level (below EMA 20 = trend broken).",
            icon: "waveform.path.ecg",
            color: "orange"
        ),

        // EMA 50
        ChartIndicator(
            id: "ema50",
            name: "50-Period Exponential Moving Average",
            shortName: "EMA 50",
            description: "The 50 EMA is a longer-term moving average showing the broader trend. When price is above EMA 50, the bigger picture is bullish. Institutions watch this closely.",
            howToUse: """
            EMA 50 is your trend compass:

            🧭 Big Picture:
            • Above EMA 50 = Bull market for this stock
            • Below EMA 50 = Bear market for this stock
            • At EMA 50 = Major decision point

            🎯 Trading Strategy:
            • In bull market: Only take longs
            • In bear market: Only take shorts
            • At EMA 50: Wait for breakout/breakdown

            💡 Major Levels:
            When price approaches EMA 50:
            • Expect volatility
            • Higher volume
            • Potential reversal or strong continuation
            """,
            bullishSignals: [
                "Price reclaims EMA 50 with conviction",
                "Price consistently above EMA 50",
                "EMA 50 trending upward"
            ],
            bearishSignals: [
                "Price breaks below EMA 50",
                "Price consistently below EMA 50",
                "EMA 50 trending downward"
            ],
            bestTimeframes: ["15-minute", "1-hour", "Daily"],
            tradeFlyUsage: "We use EMA 50 for multi-timeframe confirmation. On the 5-minute chart, EMA 50 shows intermediate trend. For maximum win rate, trade WITH EMA 50 direction.",
            icon: "chart.xyaxis.line",
            color: "red"
        ),

        // RSI
        ChartIndicator(
            id: "rsi",
            name: "Relative Strength Index",
            shortName: "RSI",
            description: "RSI measures momentum on a scale of 0-100. It shows if a stock is 'overbought' (too high, likely to pullback) or 'oversold' (too low, likely to bounce). Great for timing entries.",
            howToUse: """
            RSI is your momentum gauge:

            📊 RSI Levels:
            • 70-100: Overbought (too high, expect pullback)
            • 50-70: Healthy uptrend
            • 30-50: Neutral to weak
            • 0-30: Oversold (too low, expect bounce)

            💡 Best Signals:

            For LONG:
            • RSI 45-65 (healthy, not overheated)
            • RSI pulls back to 40-45, then turns up
            • RSI crosses above 50 (momentum shift)

            For SHORT:
            • RSI 35-55 (shows weakness)
            • RSI rallies to 55-60, then turns down
            • RSI crosses below 50 (momentum shift)

            ⚠️ Avoid:
            • RSI > 80: Overbought, expect pullback
            • RSI < 20: Oversold, expect bounce
            """,
            bullishSignals: [
                "RSI crosses above 50 (momentum shift to bulls)",
                "RSI bounces from 40-45 region (healthy pullback)",
                "RSI in 50-70 range with price making higher highs"
            ],
            bearishSignals: [
                "RSI crosses below 50 (momentum shift to bears)",
                "RSI rejected at 55-60 region",
                "RSI >80 (extreme overbought, pullback likely)"
            ],
            bestTimeframes: ["1-minute", "5-minute", "15-minute"],
            tradeFlyUsage: "TradeFly requires RSI 40-70 for HIGH signals. This ensures the move isn't overextended. We avoid RSI >80 (overbought) and RSI <30 (oversold) for new entries.",
            icon: "waveform",
            color: "purple"
        ),

        // Volume
        ChartIndicator(
            id: "volume",
            name: "Volume Analysis",
            shortName: "Volume",
            description: "Volume shows how many shares are being traded. High volume = strong conviction. Low volume = weak move. Volume confirms price action - it's the 'fuel' for price moves.",
            howToUse: """
            Volume is the truth detector:

            📊 Volume Tells You:
            • High volume breakout = Real move, high conviction
            • Low volume breakout = Fake move, likely to fail
            • Volume surge = Institutions entering
            • Declining volume = Interest fading

            💡 Volume Rules:

            For LONG Signals:
            • Volume must be 2x average (HIGH quality)
            • Volume must be 1.5x average (MEDIUM quality)
            • Volume confirms the breakout

            For SHORT Signals:
            • Volume on breakdown = Real breakdown
            • Low volume rally = Weak bounce, short it

            🎯 Pro Tip:
            Compare current volume to 20-period average:
            • >2.0x = Very strong (TradeFly HIGH signal)
            • 1.5-2.0x = Strong (TradeFly MEDIUM signal)
            • <1.5x = Weak (TradeFly rejects these)
            """,
            bullishSignals: [
                "Volume surge on breakout (2x+ average)",
                "Volume increasing as price rises",
                "High volume reclaim of key levels"
            ],
            bearishSignals: [
                "High volume on breakdown",
                "Declining volume on rally (weak)",
                "Volume divergence (price up, volume down)"
            ],
            bestTimeframes: ["1-minute", "5-minute", "All timeframes"],
            tradeFlyUsage: "Volume is TradeFly's RULE #2. We strictly enforce: HIGH signals need 2.0x average volume, MEDIUM needs 1.5x. Low volume signals are auto-rejected regardless of pattern quality.",
            icon: "chart.bar.fill",
            color: "cyan"
        ),

        // Support & Resistance
        ChartIndicator(
            id: "levels",
            name: "Support & Resistance Levels",
            shortName: "Key Levels",
            description: "Key levels are price zones where buyers and sellers have historically battled. Price tends to bounce off support and get rejected at resistance. These are critical for entries and exits.",
            howToUse: """
            Key levels are decision zones:

            🎯 Support Levels:
            • Where buyers step in strongly
            • Price bounces here repeatedly
            • Good entry zones for longs

            🎯 Resistance Levels:
            • Where sellers step in strongly
            • Price gets rejected here repeatedly
            • Good exit zones or short entries

            💡 Trading at Levels:

            At Support:
            • Look for bounce (long entry)
            • If breaks = strong downtrend
            • Use tight stop below support

            At Resistance:
            • Look for rejection (short entry)
            • If breaks = strong uptrend
            • Breakout with volume = powerful

            🚀 Breakouts:
            When price breaks key level with volume:
            • Old resistance becomes new support
            • Old support becomes new resistance
            • This is called "role reversal"
            """,
            bullishSignals: [
                "Price bounces off support level",
                "Breakout above resistance with volume",
                "Multiple successful tests of support"
            ],
            bearishSignals: [
                "Price rejected at resistance",
                "Breakdown below support with volume",
                "Failed breakout (returns below resistance)"
            ],
            bestTimeframes: ["Daily", "4-hour", "Intraday levels"],
            tradeFlyUsage: "TradeFly requires signals to be within 0.3% of key levels for HIGH quality. We identify: previous day high/low, opening range, VWAP, and major S/R zones. Trading at levels gives best risk/reward.",
            icon: "line.horizontal.3",
            color: "yellow"
        ),

        // Opening Range
        ChartIndicator(
            id: "openingrange",
            name: "Opening Range Breakout",
            shortName: "ORB",
            description: "The opening range is the high and low of the first 5-30 minutes of trading. Breakouts from this range often lead to strong directional moves. ORB is a professional day trading strategy.",
            howToUse: """
            Opening range is the daily battleground:

            📊 How It Works:
            1. First 15 minutes = Opening Range forms
            2. High of range = Resistance
            3. Low of range = Support
            4. Breakout = Direction for the day

            💡 ORB Breakout (Long):
            • Price breaks above OR high
            • Volume must be strong
            • Often runs 1-2% minimum
            • Best signals: 9:45-10:30 AM

            💡 ORB Breakdown (Short):
            • Price breaks below OR low
            • Volume confirms weakness
            • Often drops 1-2% minimum
            • Be careful shorting in strong market

            🎯 Pro Strategy:
            • Wait for clean break (not just wick)
            • Confirm with 5-minute close outside range
            • Use OR boundary as stop loss
            • Target: 2-3x the OR height
            """,
            bullishSignals: [
                "Clean breakout above OR high with volume",
                "5-minute close above OR high",
                "Retest of OR high holds as support"
            ],
            bearishSignals: [
                "Breakdown below OR low with volume",
                "5-minute close below OR low",
                "Retest of OR low fails as resistance"
            ],
            bestTimeframes: ["1-minute", "5-minute", "9:30-11:30 AM ET"],
            tradeFlyUsage: "ORB is one of TradeFly's core patterns. We scan for clean ORB breakouts from 9:45-11:30 AM. Must have volume, multi-timeframe confirmation, and SPY support. Win rate: 75-85%.",
            icon: "rectangle.split.3x1",
            color: "indigo"
        )
    ]

    // Get indicator by ID
    static func getIndicator(_ id: String) -> ChartIndicator? {
        allIndicators.first { $0.id == id }
    }

    // Get indicators used in a signal type
    static func indicatorsForSignal(_ signalType: String) -> [ChartIndicator] {
        switch signalType {
        case "VWAP_RECLAIM_LONG", "VWAP_REJECT_PUT":
            return [
                getIndicator("vwap")!,
                getIndicator("volume")!,
                getIndicator("ema9")!,
                getIndicator("ema20")!
            ]
        case "ORB_BREAKOUT_LONG", "ORB_BREAKDOWN_PUT":
            return [
                getIndicator("openingrange")!,
                getIndicator("volume")!,
                getIndicator("levels")!
            ]
        case "EMA_TREND_CONTINUATION_LONG":
            return [
                getIndicator("ema9")!,
                getIndicator("ema20")!,
                getIndicator("ema50")!,
                getIndicator("rsi")!,
                getIndicator("volume")!
            ]
        default:
            return Array(allIndicators.prefix(4))
        }
    }
}
