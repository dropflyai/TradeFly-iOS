//
//  SignalDetailView.swift
//  TradeFly AI
//

import SwiftUI

struct SignalDetailView: View {
    let signal: TradingSignal
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var signalService: SignalService
    @State private var showingTerm: EducationalTerm?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header Card
                    HeaderCard(signal: signal)

                    // Educational Signal Label
                    EducationalLabel()

                    // Trade Details
                    TradeDetailsSection(signal: signal, showingTerm: $showingTerm)

                    // Chart Placeholder
                    ChartSection(signal: signal)

                    // Why This is Quality
                    QualityReasonSection(signal: signal, showingTerm: $showingTerm)

                    // Historical Performance
                    HistoricalPerformanceSection(signal: signal)

                    // Risk Factors
                    RiskFactorsSection(signal: signal)

                    // Action Buttons
                    ActionButtonsSection(signal: signal, dismiss: dismiss)
                }
                .padding()
            }
            .navigationTitle("Signal Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $showingTerm) { term in
                EducationalTermView(term: term)
            }
        }
    }
}

// MARK: - Header Card
struct HeaderCard: View {
    let signal: TradingSignal

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(signal.ticker)
                    .font(.system(size: 40, weight: .bold))

                Spacer()

                QualityBadge(quality: signal.quality)
            }

            Text(signal.signalType.displayName)
                .font(.title3)
                .foregroundColor(.secondary)

            Text(signal.formattedTimestamp)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

// MARK: - Educational Label
struct EducationalLabel: View {
    var body: some View {
        HStack {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.blue)

            Text("Educational Signal")
                .font(.subheadline)
                .fontWeight(.semibold)

            Spacer()

            Text("Not investment advice")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - Trade Details Section
struct TradeDetailsSection: View {
    let signal: TradingSignal
    @Binding var showingTerm: EducationalTerm?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📊 Trade Details")
                .font(.headline)

            // Signal Strength & Win Probability
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Signal Strength")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack {
                        Text("\(Int(signal.signalStrength))%")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(signal.signalStrength >= 80 ? .green : signal.signalStrength >= 60 ? .orange : .red)

                        ProgressView(value: signal.signalStrength / 100)
                            .tint(signal.signalStrength >= 80 ? .green : signal.signalStrength >= 60 ? .orange : .red)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Win Probability")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack {
                        Text("\(Int(signal.successProbability))%")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(signal.successProbability >= 70 ? .green : signal.successProbability >= 55 ? .orange : .red)

                        ProgressView(value: signal.successProbability / 100)
                            .tint(signal.successProbability >= 70 ? .green : signal.successProbability >= 55 ? .orange : .red)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)

            VStack(spacing: 12) {
                DetailRow(label: "Entry", value: signal.entry.formatted)
                DetailRow(label: "Stop Loss", value: "$\(String(format: "%.2f", signal.stopLoss)) (-\(String(format: "%.1f", ((signal.price - signal.stopLoss) / signal.price * 100)))%)")
                DetailRow(label: "Target", value: "$\(String(format: "%.2f", signal.target)) (+\(String(format: "%.0f", signal.targetPercentage))%)")

                Divider()

                DetailRow(label: "Price", value: "$\(String(format: "%.2f", signal.price))")

                HStack {
                    Text("VWAP")
                        .foregroundColor(.secondary)

                    Button {
                        showingTerm = .vwap
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                    }

                    Spacer()

                    Text("$\(String(format: "%.2f", signal.vwap))")
                        .fontWeight(.semibold)
                }

                HStack {
                    Text("EMAs")
                        .foregroundColor(.secondary)

                    Button {
                        showingTerm = .ema
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                    }

                    Spacer()

                    Text("9: $\(String(format: "%.2f", signal.ema9)) | 20: $\(String(format: "%.2f", signal.ema20)) | 50: $\(String(format: "%.2f", signal.ema50))")
                        .font(.caption)
                        .fontWeight(.semibold)
                }

                DetailRow(label: "Volume", value: "\(signal.volume.formatted())")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .fontWeight(.semibold)
        }
    }
}

// MARK: - Chart Section
struct ChartSection: View {
    let signal: TradingSignal

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📈 Chart")
                .font(.headline)

            // Placeholder for chart
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemGray6))
                .frame(height: 200)
                .overlay(
                    VStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)

                        Text("Chart integration coming soon")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                )
        }
    }
}

// MARK: - Quality Reason Section
struct QualityReasonSection: View {
    let signal: TradingSignal
    @Binding var showingTerm: EducationalTerm?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🧠 Why This Signal is \(signal.quality.rawValue) Quality")
                .font(.headline)

            VStack(alignment: .leading, spacing: 12) {
                QualityCheckRow(
                    isPositive: true,
                    text: "Price reclaimed VWAP",
                    term: .vwap,
                    showingTerm: $showingTerm
                )

                QualityCheckRow(
                    isPositive: true,
                    text: "Strong volume (1.8x average)",
                    term: .volume,
                    showingTerm: $showingTerm
                )

                QualityCheckRow(
                    isPositive: true,
                    text: "EMAs aligned bullish",
                    term: .ema,
                    showingTerm: $showingTerm
                )

                QualityCheckRow(
                    isPositive: true,
                    text: "Clean candle structure",
                    term: nil,
                    showingTerm: $showingTerm
                )

                QualityCheckRow(
                    isPositive: true,
                    text: "Optimal time (9:45 AM)",
                    term: nil,
                    showingTerm: $showingTerm
                )
            }

            Text(signal.context)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

struct QualityCheckRow: View {
    let isPositive: Bool
    let text: String
    let term: EducationalTerm?
    @Binding var showingTerm: EducationalTerm?

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isPositive ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isPositive ? .green : .red)

            Text(text)
                .font(.subheadline)

            if let term = term {
                Button {
                    showingTerm = term
                } label: {
                    Image(systemName: "info.circle")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

// MARK: - Historical Performance Section
struct HistoricalPerformanceSection: View {
    let signal: TradingSignal
    @State private var performance: SignalTypePerformance?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📊 Historical Performance")
                .font(.headline)

            if let perf = performance {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Win Rate:")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "%.0f%%", perf.winRate))
                            .fontWeight(.semibold)
                            .foregroundColor(perf.winRate >= 60 ? .green : .orange)
                    }

                    HStack {
                        Text("Avg Gain:")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "%+.1f%%", perf.avgGain))
                            .fontWeight(.semibold)
                            .foregroundColor(perf.avgGain > 0 ? .green : .red)
                    }

                    HStack {
                        Text("Sample Size:")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(perf.totalSignals) signals")
                            .fontWeight(.semibold)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            } else {
                Text("Loading performance data...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
        .task {
            await fetchPerformance()
        }
    }

    private func fetchPerformance() async {
        do {
            let perf = try await SupabaseService.shared.fetchSignalTypePerformance(signalType: signal.signalType)
            performance = perf
        } catch {
            print("Failed to fetch signal performance: \(error)")
        }
    }
}

struct SignalTypePerformance {
    let winRate: Double
    let avgGain: Double
    let totalSignals: Int
}

// MARK: - Risk Factors Section
struct RiskFactorsSection: View {
    let signal: TradingSignal

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("⚠️ Risk Factors")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                RiskItem(text: "Watch for volume to stay strong")
                RiskItem(text: "If price falls below VWAP, exit immediately")
                RiskItem(text: "Don't hold past 11:30 AM (lunch hour)")
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(15)
    }
}

struct RiskItem: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundColor(.orange)

            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Action Buttons Section
struct ActionButtonsSection: View {
    let signal: TradingSignal
    let dismiss: DismissAction

    var body: some View {
        VStack(spacing: 12) {
            Button {
                // Log trade intent
                dismiss()
            } label: {
                Text("Log in Trade Journal")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(15)
            }

            Button {
                // Pass on signal
                dismiss()
            } label: {
                Text("Pass on This Signal")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
            }

            Text("Already took 2 trades today? This would be trade #2 of your max 3.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Educational Term
enum EducationalTerm: Identifiable {
    case vwap
    case ema
    case volume
    case orb
    case hod
    case lod

    var id: String {
        switch self {
        case .vwap: return "vwap"
        case .ema: return "ema"
        case .volume: return "volume"
        case .orb: return "orb"
        case .hod: return "hod"
        case .lod: return "lod"
        }
    }

    var title: String {
        switch self {
        case .vwap: return "What is VWAP?"
        case .ema: return "What are EMAs?"
        case .volume: return "Why Volume Matters"
        case .orb: return "Opening Range Breakouts"
        case .hod: return "High of Day"
        case .lod: return "Low of Day"
        }
    }

    var description: String {
        switch self {
        case .vwap:
            return """
            VWAP = Volume Weighted Average Price

            The average price weighted by volume that institutions paid for the stock today.

            💡 Why It Matters:
            When a stock crosses ABOVE VWAP after being below it, it means buyers are taking control and willing to pay higher prices.

            📈 What to Watch:
            • Price ABOVE VWAP = Bullish
            • Price BELOW VWAP = Bearish
            • Strong volume confirms the move
            """
        case .ema:
            return """
            EMA = Exponential Moving Average

            Shows price trends by giving more weight to recent prices.

            💡 The 3 EMAs We Use:
            • EMA 9: Short-term momentum
            • EMA 20: Medium-term trend
            • EMA 50: Long-term trend

            📈 Perfect Alignment:
            Bullish: EMA9 > EMA20 > EMA50 (all pointing up)
            Bearish: EMA9 < EMA20 < EMA50 (all pointing down)
            """
        case .volume:
            return """
            Volume = Number of shares traded

            💡 Why It Matters:
            Higher volume = more conviction in the move
            We look for 1.5x+ normal volume

            📈 What to Watch:
            • Volume spike at breakout = confirmation
            • Increasing volume = strong trend
            • Decreasing volume = weakening trend
            """
        case .orb:
            return """
            ORB = Opening Range Breakout

            The high/low of the first 5-15 minutes of trading.

            💡 The Setup:
            1. Identify the opening range
            2. Wait for breakout above high or below low
            3. Confirm with volume
            4. Enter on breakout

            📈 Best Time:
            First 30 minutes of market open (9:30-10:00 AM)
            """
        case .hod:
            return """
            HOD = High of Day

            The highest price reached during the trading day so far.

            💡 Why It Matters:
            Breaking above HOD often leads to continuation higher as breakout traders jump in.

            📈 What to Watch:
            • Must have volume confirmation
            • Previous HOD acts as resistance
            • Clean break = bullish signal
            """
        case .lod:
            return """
            LOD = Low of Day

            The lowest price reached during the trading day so far.

            💡 Why It Matters:
            Breaking below LOD often leads to continuation lower as stop losses trigger.

            📈 What to Watch:
            • Must have volume confirmation
            • Previous LOD acts as support
            • Clean break = bearish signal
            """
        }
    }
}

// MARK: - Educational Term View
struct EducationalTermView: View {
    let term: EducationalTerm
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(term.description)
                        .font(.body)
                        .padding()

                    Button {
                        // Navigate to full lesson
                    } label: {
                        Text("Watch 2-min Video Lesson")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(15)
                    }
                    .padding()
                }
            }
            .navigationTitle(term.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Got it") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Preview removed - previewSample only available in DEBUG builds
