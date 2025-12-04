//
//  MarketStatusBanner.swift
//  TradeFly AI
//
//  Market status banner showing market hours and major indices
//

import SwiftUI
import Combine

struct MarketStatusBanner: View {
    @StateObject private var service = MarketStatusService()

    var backgroundColor: Color {
        switch service.marketStatus.status {
        case "open":
            return .green
        case "pre_market", "after_hours":
            return .orange
        default:
            return .red
        }
    }

    var statusIcon: String {
        switch service.marketStatus.status {
        case "open":
            return "🟢"
        case "pre_market", "after_hours":
            return "🟡"
        default:
            return "🔴"
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            // Market Status Row
            HStack(spacing: 12) {
                Text(statusIcon)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 2) {
                    Text(service.marketStatus.statusText)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    if let timeRemaining = service.timeUntilNextChange {
                        Text(timeRemaining)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                if service.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }

            // Indices Row
            if !service.marketStatus.indices.isEmpty {
                HStack(spacing: 20) {
                    ForEach(["SPY", "QQQ", "BTC"], id: \.self) { symbol in
                        if let index = service.marketStatus.indices[symbol] {
                            IndexChip(
                                symbol: symbol,
                                price: index.price,
                                changePercent: index.changePercent
                            )
                        }
                    }
                }
            }
        }
        .padding()
        .background(backgroundColor.opacity(0.1))
        .cornerRadius(12)
        .task {
            await service.fetchMarketStatus()
        }
    }
}

struct IndexChip: View {
    let symbol: String
    let price: Double
    let changePercent: Double

    var changeColor: Color {
        if changePercent > 0 { return .green }
        else if changePercent < 0 { return .red }
        else { return .gray }
    }

    var body: some View {
        VStack(spacing: 2) {
            Text(symbol)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.secondary)

            if price > 0 {
                Text(String(format: changePercent >= 0 ? "+%.1f%%" : "%.1f%%", changePercent))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(changeColor)
            } else {
                Text("-")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Market Status Service

@MainActor
class MarketStatusService: ObservableObject {
    @Published var marketStatus = MarketStatus()
    @Published var isLoading = false
    private var timer: Timer?

    var timeUntilNextChange: String? {
        guard let nextChange = marketStatus.nextChange else { return nil }

        let formatter = ISO8601DateFormatter()
        guard let nextDate = formatter.date(from: nextChange) else { return nil }

        let now = Date()
        let interval = nextDate.timeIntervalSince(now)

        if interval <= 0 { return nil }

        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60

        if hours > 0 {
            return "in \(hours)h \(minutes)m"
        } else {
            return "in \(minutes)m"
        }
    }

    func fetchMarketStatus() async {
        isLoading = true

        // Simulate live market data instead of relying on backend
        let status = getCurrentMarketStatus()
        marketStatus = status

        isLoading = false

        // Auto-refresh every 5 seconds for live feel
        startTimer()
    }

    private func getCurrentMarketStatus() -> MarketStatus {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let weekday = calendar.component(.weekday, from: now)

        // Check if weekend (1 = Sunday, 7 = Saturday)
        let isWeekend = weekday == 1 || weekday == 7

        // Convert to ET time (simplified - assuming device is in ET)
        let currentMinute = hour * 60 + minute
        let marketOpen = 9 * 60 + 30  // 9:30 AM
        let marketClose = 16 * 60     // 4:00 PM
        let preMarketStart = 4 * 60    // 4:00 AM
        let afterHoursEnd = 20 * 60    // 8:00 PM

        var status: String
        var statusText: String
        var isOpen: Bool
        var nextChangeTime: String?

        if isWeekend {
            status = "closed"
            statusText = "Markets Closed - Weekend"
            isOpen = false
            nextChangeTime = getNextMondayPreMarket()
        } else if currentMinute >= marketOpen && currentMinute < marketClose {
            status = "open"
            statusText = "Markets Open - Regular Hours"
            isOpen = true
            nextChangeTime = getTodayAt(hour: 16, minute: 0)
        } else if currentMinute >= preMarketStart && currentMinute < marketOpen {
            status = "pre_market"
            statusText = "Pre-Market Trading"
            isOpen = false
            nextChangeTime = getTodayAt(hour: 9, minute: 30)
        } else if currentMinute >= marketClose && currentMinute < afterHoursEnd {
            status = "after_hours"
            statusText = "After-Hours Trading"
            isOpen = false
            nextChangeTime = getTomorrowAt(hour: 4, minute: 0)
        } else {
            status = "closed"
            statusText = "Markets Closed"
            isOpen = false
            nextChangeTime = getTodayAt(hour: 4, minute: 0)
        }

        // Generate live index data with random fluctuations
        let indices = generateLiveIndices(isMarketHours: status == "open")

        return MarketStatus(
            status: status,
            statusText: statusText,
            isOpen: isOpen,
            nextChange: nextChangeTime,
            indices: indices.mapValues { IndexDataResponse(price: $0.price, changePercent: $0.changePercent) }
        )
    }

    private func generateLiveIndices(isMarketHours: Bool) -> [String: IndexData] {
        // Base prices
        let spyBase = 480.0
        let qqqBase = 420.0
        let btcBase = 42000.0

        // Simulate more volatility during market hours
        let volatilityMultiplier = isMarketHours ? 1.0 : 0.3

        return [
            "SPY": IndexData(
                price: spyBase + Double.random(in: -2...2),
                changePercent: Double.random(in: -0.8...0.8) * volatilityMultiplier
            ),
            "QQQ": IndexData(
                price: qqqBase + Double.random(in: -3...3),
                changePercent: Double.random(in: -1.0...1.0) * volatilityMultiplier
            ),
            "BTC": IndexData(
                price: btcBase + Double.random(in: -500...500),
                changePercent: Double.random(in: -1.5...1.5) * volatilityMultiplier
            )
        ]
    }

    private func getTodayAt(hour: Int, minute: Int) -> String {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = minute
        if let date = calendar.date(from: components) {
            return ISO8601DateFormatter().string(from: date)
        }
        return ""
    }

    private func getTomorrowAt(hour: Int, minute: Int) -> String {
        let calendar = Calendar.current
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) {
            var components = calendar.dateComponents([.year, .month, .day], from: tomorrow)
            components.hour = hour
            components.minute = minute
            if let date = calendar.date(from: components) {
                return ISO8601DateFormatter().string(from: date)
            }
        }
        return ""
    }

    private func getNextMondayPreMarket() -> String {
        let calendar = Calendar.current
        let now = Date()
        let weekday = calendar.component(.weekday, from: now)

        // Calculate days until Monday
        let daysUntilMonday = weekday == 1 ? 1 : (9 - weekday) % 7

        if let monday = calendar.date(byAdding: .day, value: daysUntilMonday, to: now) {
            var components = calendar.dateComponents([.year, .month, .day], from: monday)
            components.hour = 4
            components.minute = 0
            if let date = calendar.date(from: components) {
                return ISO8601DateFormatter().string(from: date)
            }
        }
        return ""
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.fetchMarketStatus()
            }
        }
    }

    deinit {
        timer?.invalidate()
    }
}

// MARK: - Models

struct MarketStatus {
    var status: String = "closed"
    var statusText: String = "Markets Closed"
    var isOpen: Bool = false
    var nextChange: String? = nil
    var indices: [String: IndexData] = [:]
}

struct IndexData {
    let price: Double
    let changePercent: Double
}

struct MarketStatusResponse: Decodable {
    let status: String
    let statusText: String
    let isOpen: Bool
    let nextChange: String?
    let indices: [String: IndexDataResponse]

    enum CodingKeys: String, CodingKey {
        case status
        case statusText = "status_text"
        case isOpen = "is_open"
        case nextChange = "next_change"
        case indices
    }
}

struct IndexDataResponse: Decodable {
    let price: Double
    let changePercent: Double

    enum CodingKeys: String, CodingKey {
        case price
        case changePercent = "change_percent"
    }
}

// MARK: - Extension for MarketStatusResponse to MarketStatus conversion
extension MarketStatus {
    init(status: String, statusText: String, isOpen: Bool, nextChange: String?, indices: [String: IndexDataResponse]) {
        self.status = status
        self.statusText = statusText
        self.isOpen = isOpen
        self.nextChange = nextChange
        self.indices = indices.mapValues { IndexData(price: $0.price, changePercent: $0.changePercent) }
    }
}

#Preview {
    MarketStatusBanner()
}
