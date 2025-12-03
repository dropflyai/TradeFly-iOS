//
//  AdvancedChartView.swift
//  TradeFly AI
//
//  Professional-grade charting similar to ThinkorSwim

import SwiftUI
import Charts

// MARK: - Chart Data Models
struct CandleData: Identifiable {
    let id = UUID()
    let timestamp: Date
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Int

    var isBullish: Bool { close >= open }
    var bodyHigh: Double { max(open, close) }
    var bodyLow: Double { min(open, close) }
}

struct TechnicalIndicators {
    var sma20: [Double] = []
    var sma50: [Double] = []
    var ema9: [Double] = []
    var ema20: [Double] = []
    var vwap: [Double] = []
    var rsi: [Double] = []
    var macd: [Double] = []
    var signal: [Double] = []
    var bollingerUpper: [Double] = []
    var bollingerLower: [Double] = []
}

enum ChartTimeframe: String, CaseIterable {
    case oneMin = "1m"
    case fiveMin = "5m"
    case fifteenMin = "15m"
    case thirtyMin = "30m"
    case oneHour = "1h"
    case fourHour = "4h"
    case oneDay = "1D"
    case oneWeek = "1W"

    var displayName: String { rawValue }
}

enum ChartType: String, CaseIterable {
    case candlestick = "Candles"
    case line = "Line"
    case area = "Area"
    case heikinAshi = "Heikin-Ashi"
}

struct AdvancedChartView: View {
    let ticker: String

    @State private var candleData: [CandleData] = []
    @State private var indicators = TechnicalIndicators()
    @State private var selectedTimeframe: ChartTimeframe = .fiveMin
    @State private var selectedChartType: ChartType = .candlestick
    @State private var isLoading = true
    @State private var errorMessage: String?

    // Indicator toggles
    @State private var showSMA20 = true
    @State private var showSMA50 = true
    @State private var showEMA9 = false
    @State private var showEMA20 = false
    @State private var showVWAP = true
    @State private var showBollinger = false
    @State private var showRSI = false
    @State private var showMACD = false
    @State private var showVolume = true

    // Chart interaction
    @State private var selectedCandle: CandleData?
    @State private var zoomLevel: Double = 1.0

    var body: some View {
        VStack(spacing: 0) {
            // Header with ticker info
            ChartHeaderView(ticker: ticker, currentPrice: candleData.last?.close ?? 0)

            // Timeframe selector
            TimeframeSelector(selectedTimeframe: $selectedTimeframe)
                .onChange(of: selectedTimeframe) { _ in
                    Task {
                        await loadChartData()
                    }
                }

            // Main chart area
            if isLoading {
                Spacer()
                ProgressView("Loading chart data...")
                Spacer()
            } else if let error = errorMessage {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        Task {
                            await loadChartData()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                Spacer()
            } else {
                ScrollView(.vertical) {
                    VStack(spacing: 16) {
                        // Price chart
                        PriceChartView(
                            candleData: candleData,
                            indicators: indicators,
                            chartType: selectedChartType,
                            showSMA20: showSMA20,
                            showSMA50: showSMA50,
                            showEMA9: showEMA9,
                            showEMA20: showEMA20,
                            showVWAP: showVWAP,
                            showBollinger: showBollinger,
                            selectedCandle: $selectedCandle
                        )
                        .frame(height: 350)
                        .padding(.horizontal)

                        // Volume chart
                        if showVolume {
                            VolumeChartView(candleData: candleData)
                                .frame(height: 100)
                                .padding(.horizontal)
                        }

                        // RSI indicator
                        if showRSI {
                            RSIChartView(rsiData: indicators.rsi, candleData: candleData)
                                .frame(height: 100)
                                .padding(.horizontal)
                        }

                        // MACD indicator
                        if showMACD {
                            MACDChartView(
                                macdData: indicators.macd,
                                signalData: indicators.signal,
                                candleData: candleData
                            )
                            .frame(height: 120)
                            .padding(.horizontal)
                        }

                        // Indicator controls
                        IndicatorControlsView(
                            showSMA20: $showSMA20,
                            showSMA50: $showSMA50,
                            showEMA9: $showEMA9,
                            showEMA20: $showEMA20,
                            showVWAP: $showVWAP,
                            showBollinger: $showBollinger,
                            showRSI: $showRSI,
                            showMACD: $showMACD,
                            showVolume: $showVolume
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationTitle("\(ticker) Chart")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadChartData()
        }
    }

    func loadChartData() async {
        isLoading = true
        errorMessage = nil

        do {
            // Fetch candle data from backend
            let data = try await fetchCandleData(ticker: ticker, timeframe: selectedTimeframe)
            candleData = data

            // Calculate indicators
            indicators = calculateIndicators(for: data)

            isLoading = false
        } catch {
            errorMessage = "Failed to load chart: \(error.localizedDescription)"
            isLoading = false
        }
    }

    func fetchCandleData(ticker: String, timeframe: ChartTimeframe) async throws -> [CandleData] {
        // TODO: Replace with actual API call to backend
        // For now, return sample data
        return generateSampleData()
    }

    func calculateIndicators(for data: [CandleData]) -> TechnicalIndicators {
        var indicators = TechnicalIndicators()

        // Calculate SMA
        indicators.sma20 = calculateSMA(data: data, period: 20)
        indicators.sma50 = calculateSMA(data: data, period: 50)

        // Calculate EMA
        indicators.ema9 = calculateEMA(data: data, period: 9)
        indicators.ema20 = calculateEMA(data: data, period: 20)

        // Calculate VWAP
        indicators.vwap = calculateVWAP(data: data)

        // Calculate RSI
        indicators.rsi = calculateRSI(data: data, period: 14)

        // Calculate MACD
        let (macd, signal) = calculateMACD(data: data)
        indicators.macd = macd
        indicators.signal = signal

        // Calculate Bollinger Bands
        let (upper, lower) = calculateBollingerBands(data: data, period: 20, stdDev: 2)
        indicators.bollingerUpper = upper
        indicators.bollingerLower = lower

        return indicators
    }

    // MARK: - Technical Indicator Calculations

    func calculateSMA(data: [CandleData], period: Int) -> [Double] {
        var sma: [Double] = []
        for i in 0..<data.count {
            if i < period - 1 {
                sma.append(data[i].close) // Not enough data yet
            } else {
                let sum = data[i-period+1...i].reduce(0.0) { $0 + $1.close }
                sma.append(sum / Double(period))
            }
        }
        return sma
    }

    func calculateEMA(data: [CandleData], period: Int) -> [Double] {
        guard !data.isEmpty else { return [] }

        var ema: [Double] = []
        let multiplier = 2.0 / Double(period + 1)

        // Start with SMA for first value
        let initialSum = data.prefix(period).reduce(0.0) { $0 + $1.close }
        var currentEMA = initialSum / Double(period)

        for i in 0..<data.count {
            if i < period {
                ema.append(data[i].close)
            } else {
                currentEMA = (data[i].close - currentEMA) * multiplier + currentEMA
                ema.append(currentEMA)
            }
        }
        return ema
    }

    func calculateVWAP(data: [CandleData]) -> [Double] {
        var vwap: [Double] = []
        var cumulativeTPV = 0.0
        var cumulativeVolume = 0.0

        for candle in data {
            let typicalPrice = (candle.high + candle.low + candle.close) / 3.0
            cumulativeTPV += typicalPrice * Double(candle.volume)
            cumulativeVolume += Double(candle.volume)

            vwap.append(cumulativeVolume > 0 ? cumulativeTPV / cumulativeVolume : candle.close)
        }
        return vwap
    }

    func calculateRSI(data: [CandleData], period: Int) -> [Double] {
        guard data.count > period else { return Array(repeating: 50, count: data.count) }

        var rsi: [Double] = []
        var gains: [Double] = []
        var losses: [Double] = []

        for i in 1..<data.count {
            let change = data[i].close - data[i-1].close
            gains.append(change > 0 ? change : 0)
            losses.append(change < 0 ? -change : 0)
        }

        for i in 0..<data.count {
            if i < period {
                rsi.append(50) // Default RSI
            } else {
                let avgGain = gains[i-period..<i].reduce(0, +) / Double(period)
                let avgLoss = losses[i-period..<i].reduce(0, +) / Double(period)

                if avgLoss == 0 {
                    rsi.append(100)
                } else {
                    let rs = avgGain / avgLoss
                    rsi.append(100 - (100 / (1 + rs)))
                }
            }
        }
        return rsi
    }

    func calculateMACD(data: [CandleData]) -> (macd: [Double], signal: [Double]) {
        let ema12 = calculateEMA(data: data, period: 12)
        let ema26 = calculateEMA(data: data, period: 26)

        var macd: [Double] = []
        for i in 0..<data.count {
            macd.append(ema12[i] - ema26[i])
        }

        // Calculate signal line (9-period EMA of MACD)
        let macdData = macd.enumerated().map { CandleData(timestamp: data[$0.offset].timestamp, open: $0.element, high: $0.element, low: $0.element, close: $0.element, volume: 0) }
        let signal = calculateEMA(data: macdData, period: 9)

        return (macd, signal)
    }

    func calculateBollingerBands(data: [CandleData], period: Int, stdDev: Double) -> (upper: [Double], lower: [Double]) {
        let sma = calculateSMA(data: data, period: period)
        var upper: [Double] = []
        var lower: [Double] = []

        for i in 0..<data.count {
            if i < period - 1 {
                upper.append(data[i].close)
                lower.append(data[i].close)
            } else {
                let values = data[i-period+1...i].map { $0.close }
                let mean = sma[i]
                let variance = values.reduce(0.0) { $0 + pow($1 - mean, 2) } / Double(period)
                let standardDeviation = sqrt(variance)

                upper.append(mean + (standardDeviation * stdDev))
                lower.append(mean - (standardDeviation * stdDev))
            }
        }
        return (upper, lower)
    }

    func generateSampleData() -> [CandleData] {
        // Generate realistic sample candlestick data
        var data: [CandleData] = []
        var currentPrice = 150.0
        let baseDate = Date().addingTimeInterval(-3600 * 100) // 100 hours ago

        for i in 0..<100 {
            let timestamp = baseDate.addingTimeInterval(Double(i) * 300) // 5-min candles
            let change = Double.random(in: -2...2)
            currentPrice += change

            let open = currentPrice
            let close = currentPrice + Double.random(in: -1...1)
            let high = max(open, close) + abs(Double.random(in: 0...0.5))
            let low = min(open, close) - abs(Double.random(in: 0...0.5))
            let volume = Int.random(in: 100000...500000)

            data.append(CandleData(timestamp: timestamp, open: open, high: high, low: low, close: close, volume: volume))
        }
        return data
    }
}

// MARK: - Chart Header
struct ChartHeaderView: View {
    let ticker: String
    let currentPrice: Double

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(ticker)
                    .font(.title2)
                    .fontWeight(.bold)
                Text("$\(String(format: "%.2f", currentPrice))")
                    .font(.title3)
                    .foregroundColor(.green)
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - Timeframe Selector
struct TimeframeSelector: View {
    @Binding var selectedTimeframe: ChartTimeframe

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ChartTimeframe.allCases, id: \.self) { timeframe in
                    Button(action: {
                        selectedTimeframe = timeframe
                    }) {
                        Text(timeframe.displayName)
                            .font(.caption)
                            .fontWeight(selectedTimeframe == timeframe ? .bold : .regular)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedTimeframe == timeframe ? Color.blue : Color(.systemGray5))
                            .foregroundColor(selectedTimeframe == timeframe ? .white : .primary)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Price Chart View
struct PriceChartView: View {
    let candleData: [CandleData]
    let indicators: TechnicalIndicators
    let chartType: ChartType
    let showSMA20: Bool
    let showSMA50: Bool
    let showEMA9: Bool
    let showEMA20: Bool
    let showVWAP: Bool
    let showBollinger: Bool
    @Binding var selectedCandle: CandleData?

    var body: some View {
        Chart {
            // Bollinger Bands (background)
            if showBollinger && indicators.bollingerUpper.count == candleData.count {
                ForEach(Array(candleData.enumerated()), id: \.element.id) { index, candle in
                    AreaMark(
                        x: .value("Time", candle.timestamp),
                        yStart: .value("Lower", indicators.bollingerLower[index]),
                        yEnd: .value("Upper", indicators.bollingerUpper[index])
                    )
                    .foregroundStyle(Color.purple.opacity(0.1))
                }
            }

            // Candlesticks
            ForEach(candleData) { candle in
                // Candle wick (high-low)
                RuleMark(
                    x: .value("Time", candle.timestamp),
                    yStart: .value("Low", candle.low),
                    yEnd: .value("High", candle.high)
                )
                .foregroundStyle(candle.isBullish ? Color.green : Color.red)
                .lineStyle(StrokeStyle(lineWidth: 1))

                // Candle body (open-close)
                RectangleMark(
                    x: .value("Time", candle.timestamp),
                    yStart: .value("Body Low", candle.bodyLow),
                    yEnd: .value("Body High", candle.bodyHigh),
                    width: 8
                )
                .foregroundStyle(candle.isBullish ? Color.green : Color.red)
            }

            // Moving averages
            if showSMA20 && indicators.sma20.count == candleData.count {
                ForEach(Array(candleData.enumerated()), id: \.element.id) { index, candle in
                    LineMark(
                        x: .value("Time", candle.timestamp),
                        y: .value("SMA20", indicators.sma20[index])
                    )
                    .foregroundStyle(Color.blue)
                    .lineStyle(StrokeStyle(lineWidth: 1.5))
                }
            }

            if showSMA50 && indicators.sma50.count == candleData.count {
                ForEach(Array(candleData.enumerated()), id: \.element.id) { index, candle in
                    LineMark(
                        x: .value("Time", candle.timestamp),
                        y: .value("SMA50", indicators.sma50[index])
                    )
                    .foregroundStyle(Color.orange)
                    .lineStyle(StrokeStyle(lineWidth: 1.5))
                }
            }

            if showEMA9 && indicators.ema9.count == candleData.count {
                ForEach(Array(candleData.enumerated()), id: \.element.id) { index, candle in
                    LineMark(
                        x: .value("Time", candle.timestamp),
                        y: .value("EMA9", indicators.ema9[index])
                    )
                    .foregroundStyle(Color.cyan)
                    .lineStyle(StrokeStyle(lineWidth: 1.5))
                }
            }

            if showEMA20 && indicators.ema20.count == candleData.count {
                ForEach(Array(candleData.enumerated()), id: \.element.id) { index, candle in
                    LineMark(
                        x: .value("Time", candle.timestamp),
                        y: .value("EMA20", indicators.ema20[index])
                    )
                    .foregroundStyle(Color.purple)
                    .lineStyle(StrokeStyle(lineWidth: 1.5))
                }
            }

            if showVWAP && indicators.vwap.count == candleData.count {
                ForEach(Array(candleData.enumerated()), id: \.element.id) { index, candle in
                    LineMark(
                        x: .value("Time", candle.timestamp),
                        y: .value("VWAP", indicators.vwap[index])
                    )
                    .foregroundStyle(Color.yellow)
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 3]))
                }
            }
        }
        .chartYScale(domain: .automatic(includesZero: false))
    }
}

// MARK: - Volume Chart View
struct VolumeChartView: View {
    let candleData: [CandleData]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Volume")
                .font(.caption)
                .foregroundColor(.secondary)

            Chart {
                ForEach(candleData) { candle in
                    BarMark(
                        x: .value("Time", candle.timestamp),
                        y: .value("Volume", candle.volume)
                    )
                    .foregroundStyle(candle.isBullish ? Color.green.opacity(0.5) : Color.red.opacity(0.5))
                }
            }
        }
    }
}

// MARK: - RSI Chart View
struct RSIChartView: View {
    let rsiData: [Double]
    let candleData: [CandleData]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("RSI (14)")
                .font(.caption)
                .foregroundColor(.secondary)

            Chart {
                // Overbought/Oversold zones
                RectangleMark(
                    yStart: .value("Overbought Start", 70),
                    yEnd: .value("Overbought End", 100)
                )
                .foregroundStyle(Color.red.opacity(0.1))

                RectangleMark(
                    yStart: .value("Oversold Start", 0),
                    yEnd: .value("Oversold End", 30)
                )
                .foregroundStyle(Color.green.opacity(0.1))

                // RSI line
                ForEach(Array(candleData.enumerated()), id: \.element.id) { index, candle in
                    LineMark(
                        x: .value("Time", candle.timestamp),
                        y: .value("RSI", rsiData[index])
                    )
                    .foregroundStyle(Color.purple)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }
            }
            .chartYScale(domain: 0...100)
        }
    }
}

// MARK: - MACD Chart View
struct MACDChartView: View {
    let macdData: [Double]
    let signalData: [Double]
    let candleData: [CandleData]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("MACD (12, 26, 9)")
                .font(.caption)
                .foregroundColor(.secondary)

            Chart {
                // Histogram (MACD - Signal)
                ForEach(Array(candleData.enumerated()), id: \.element.id) { index, candle in
                    let histogram = macdData[index] - signalData[index]
                    BarMark(
                        x: .value("Time", candle.timestamp),
                        y: .value("Histogram", histogram)
                    )
                    .foregroundStyle(histogram >= 0 ? Color.green.opacity(0.5) : Color.red.opacity(0.5))
                }

                // MACD line
                ForEach(Array(candleData.enumerated()), id: \.element.id) { index, candle in
                    LineMark(
                        x: .value("Time", candle.timestamp),
                        y: .value("MACD", macdData[index])
                    )
                    .foregroundStyle(Color.blue)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }

                // Signal line
                ForEach(Array(candleData.enumerated()), id: \.element.id) { index, candle in
                    LineMark(
                        x: .value("Time", candle.timestamp),
                        y: .value("Signal", signalData[index])
                    )
                    .foregroundStyle(Color.orange)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }
            }
            .chartYScale(domain: .automatic(includesZero: true))
        }
    }
}

// MARK: - Indicator Controls
struct IndicatorControlsView: View {
    @Binding var showSMA20: Bool
    @Binding var showSMA50: Bool
    @Binding var showEMA9: Bool
    @Binding var showEMA20: Bool
    @Binding var showVWAP: Bool
    @Binding var showBollinger: Bool
    @Binding var showRSI: Bool
    @Binding var showMACD: Bool
    @Binding var showVolume: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Technical Indicators")
                .font(.headline)
                .padding(.bottom, 4)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                IndicatorToggle(title: "SMA 20", color: .blue, isOn: $showSMA20)
                IndicatorToggle(title: "SMA 50", color: .orange, isOn: $showSMA50)
                IndicatorToggle(title: "EMA 9", color: .cyan, isOn: $showEMA9)
                IndicatorToggle(title: "EMA 20", color: .purple, isOn: $showEMA20)
                IndicatorToggle(title: "VWAP", color: .yellow, isOn: $showVWAP)
                IndicatorToggle(title: "Bollinger", color: .purple, isOn: $showBollinger)
                IndicatorToggle(title: "RSI", color: .purple, isOn: $showRSI)
                IndicatorToggle(title: "MACD", color: .blue, isOn: $showMACD)
                IndicatorToggle(title: "Volume", color: .gray, isOn: $showVolume)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct IndicatorToggle: View {
    let title: String
    let color: Color
    @Binding var isOn: Bool

    var body: some View {
        Button(action: {
            isOn.toggle()
        }) {
            HStack {
                Circle()
                    .fill(isOn ? color : Color.gray)
                    .frame(width: 12, height: 12)
                Text(title)
                    .font(.caption)
                    .foregroundColor(isOn ? .primary : .secondary)
                Spacer()
                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isOn ? .green : .gray)
            }
            .padding(10)
            .background(isOn ? color.opacity(0.1) : Color(.systemGray5))
            .cornerRadius(8)
        }
    }
}

#Preview {
    NavigationView {
        AdvancedChartView(ticker: "AAPL")
    }
}
