//
//  HomeView.swift
//  TradeFly AI
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var signalService: SignalService
    @State private var todayProfit: Double = 0
    @State private var todayTrades: Int = 0

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Today's Progress Card
                    ProgressCard(
                        currentProfit: todayProfit,
                        goalProfit: userSettings.dailyProfitGoal,
                        tradesCompleted: todayTrades,
                        maxTrades: userSettings.tradesPerDay
                    )

                    // Active Signals Section
                    ActiveSignalsSection()

                    // Quick Stats
                    QuickStatsCard()

                    // Learning Tip of the Day
                    LearningTipCard()

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("TradeFly AI")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NotificationButton()
                }
            }
        }
    }
}

// MARK: - Progress Card
struct ProgressCard: View {
    let currentProfit: Double
    let goalProfit: Double
    let tradesCompleted: Int
    let maxTrades: Int

    var progress: Double {
        guard goalProfit > 0 else { return 0 }
        return min(currentProfit / goalProfit, 1.0)
    }

    var isOnTrack: Bool {
        currentProfit >= goalProfit * 0.5 // On track if 50%+ of goal
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📈 Today's Progress")
                .font(.headline)

            // Profit Progress
            HStack {
                Text("$\(String(format: "%.0f", currentProfit))")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(currentProfit >= 0 ? .green : .red)

                Text("/ $\(String(format: "%.0f", goalProfit)) goal")
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(Int(progress * 100))%")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }

            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 12)

                    RoundedRectangle(cornerRadius: 10)
                        .fill(currentProfit >= 0 ? Color.green : Color.red)
                        .frame(width: geometry.size.width * CGFloat(progress), height: 12)
                }
            }
            .frame(height: 12)

            // Trades Info
            HStack {
                Text("\(tradesCompleted) trade\(tradesCompleted == 1 ? "" : "s") completed")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(maxTrades - tradesCompleted) remaining (max \(maxTrades)/day)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Status
            HStack {
                Image(systemName: isOnTrack ? "checkmark.circle.fill" : "clock.fill")
                    .foregroundColor(isOnTrack ? .green : .orange)

                Text(isOnTrack ? "On track to hit goal" : "Keep going!")
                    .font(.subheadline)
                    .foregroundColor(isOnTrack ? .green : .orange)
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Active Signals Section
struct ActiveSignalsSection: View {
    @EnvironmentObject var signalService: SignalService
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🔥 Active Signals")
                    .font(.headline)

                Spacer()

                if signalService.activeSignals.isEmpty {
                    Text("Next scan in: 45s")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            if signalService.activeSignals.isEmpty {
                EmptySignalsView()
            } else {
                ForEach(signalService.activeSignals.prefix(3)) { signal in
                    SignalCardCompact(signal: signal)
                        .onTapGesture {
                            appState.selectedSignal = signal
                            appState.currentTab = .signals
                        }
                }

                if signalService.activeSignals.count > 3 {
                    Button {
                        appState.currentTab = .signals
                    } label: {
                        Text("View all \(signalService.activeSignals.count) signals")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}

struct EmptySignalsView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "antenna.radiowaves.left.and.right.slash")
                .font(.system(size: 40))
                .foregroundColor(.gray)

            Text("No signals right now")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("We'll notify you when a high-quality setup appears")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// MARK: - Signal Card (Compact)
struct SignalCardCompact: View {
    let signal: TradingSignal

    var body: some View {
        HStack(spacing: 12) {
            // Quality Indicator
            VStack {
                Text(signal.qualityIcon)
                    .font(.title3)

                Text(signal.quality.rawValue)
                    .font(.caption)
                    .fontWeight(.bold)
            }
            .frame(width: 50)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(signal.ticker)
                        .font(.headline)

                    Text("•")
                        .foregroundColor(.secondary)

                    Text(signal.signalType.displayName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Text(signal.idea.rawValue + " • Target: +\(String(format: "%.0f", signal.targetPercentage))%")
                    .font(.caption)
                    .foregroundColor(signal.idea == .call ? .green : .red)

                Text(signal.formattedTimestamp)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

// MARK: - Quick Stats Card
struct QuickStatsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📊 This Week")
                .font(.headline)

            HStack(spacing: 20) {
                StatItem(title: "Win Rate", value: "68%", color: .green)
                StatItem(title: "Avg Gain", value: "+11.2%", color: .blue)
                StatItem(title: "Trades", value: "12", color: .orange)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Learning Tip Card
struct LearningTipCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("📚 Learning")
                    .font(.headline)

                Spacer()

                Text("2 min")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text("Understanding VWAP Reclaims")
                .font(.subheadline)
                .fontWeight(.semibold)

            Text("Learn why price reclaiming VWAP is one of the strongest bullish signals in day trading.")
                .font(.caption)
                .foregroundColor(.secondary)

            Button {
                // Navigate to lesson
            } label: {
                Text("Watch Quick Video")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Notification Button
struct NotificationButton: View {
    var body: some View {
        Button {
            // Open notifications
        } label: {
            Image(systemName: "bell.fill")
                .foregroundColor(.blue)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(UserSettings())
        .environmentObject(SignalService())
}
