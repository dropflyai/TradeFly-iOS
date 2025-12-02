//
//  ChartView.swift
//  TradeFly
//
//  Interactive charting with TradingView + Educational overlays
//

import SwiftUI
import WebKit

struct ChartView: View {
    let ticker: String
    let signalType: String?
    let entryPrice: Double?

    @State private var selectedTimeframe = "5"
    @State private var showIndicators = true
    @State private var selectedIndicator: ChartIndicator?
    @State private var showEducation = false

    let timeframes = ["1", "5", "15", "60", "D"]
    let timeframeLabels = ["1m": "1", "5m": "5", "15m": "15", "1h": "60", "Daily": "D"]

    var body: some View {
        VStack(spacing: 0) {
            // Chart Header
            chartHeader

            // TradingView Chart
            TradingViewChart(
                ticker: ticker,
                timeframe: selectedTimeframe,
                showIndicators: showIndicators,
                entryPrice: entryPrice
            )
            .frame(height: 400)

            // Timeframe Selector
            timeframeSelector

            // Indicator Cards
            if showIndicators {
                indicatorCards
            }

            // Educational Panel
            if showEducation, let indicator = selectedIndicator {
                educationalPanel(for: indicator)
            }
        }
        .navigationTitle("📊 \(ticker) Chart")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Chart Header
    private var chartHeader: some View {
        HStack {
            Text(ticker)
                .font(.title2)
                .fontWeight(.bold)

            Spacer()

            // Toggle indicators
            Button(action: { showIndicators.toggle() }) {
                Label(
                    showIndicators ? "Hide Indicators" : "Show Indicators",
                    systemImage: showIndicators ? "eye.slash" : "eye"
                )
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }

    // MARK: - Timeframe Selector
    private var timeframeSelector: some View {
        HStack(spacing: 12) {
            Text("Timeframe:")
                .font(.caption)
                .foregroundColor(.secondary)

            ForEach(Array(timeframeLabels), id: \.key) { label, value in
                Button(action: {
                    selectedTimeframe = value
                }) {
                    Text(label)
                        .font(.caption)
                        .fontWeight(selectedTimeframe == value ? .bold : .regular)
                        .foregroundColor(selectedTimeframe == value ? .white : .blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            selectedTimeframe == value ? Color.blue : Color.blue.opacity(0.1)
                        )
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }

    // MARK: - Indicator Cards
    private var indicatorCards: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ChartIndicator.indicatorsForSignal(signalType ?? "")) { indicator in
                    IndicatorCard(indicator: indicator)
                        .onTapGesture {
                            selectedIndicator = indicator
                            showEducation = true
                        }
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Educational Panel
    private func educationalPanel(for indicator: ChartIndicator) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    Image(systemName: indicator.icon)
                        .font(.title)
                        .foregroundColor(Color(indicator.color))

                    VStack(alignment: .leading) {
                        Text(indicator.name)
                            .font(.headline)
                        Text(indicator.shortName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Button(action: { showEducation = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }

                Divider()

                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("What is it?")
                        .font(.headline)
                    Text(indicator.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }

                // How to Use
                VStack(alignment: .leading, spacing: 8) {
                    Text("How to Use")
                        .font(.headline)
                    Text(indicator.howToUse)
                        .font(.body)
                        .foregroundColor(.secondary)
                }

                // Bullish Signals
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.green)
                        Text("Bullish Signals")
                            .font(.headline)
                    }

                    ForEach(indicator.bullishSignals, id: \.self) { signal in
                        HStack(alignment: .top) {
                            Text("•")
                            Text(signal)
                                .font(.caption)
                        }
                    }
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)

                // Bearish Signals
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(.red)
                        Text("Bearish Signals")
                            .font(.headline)
                    }

                    ForEach(indicator.bearishSignals, id: \.self) { signal in
                        HStack(alignment: .top) {
                            Text("•")
                            Text(signal)
                                .font(.caption)
                        }
                    }
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)

                // TradeFly Usage
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("How TradeFly Uses This")
                            .font(.headline)
                    }
                    Text(indicator.tradeFlyUsage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(12)
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .frame(height: 500)
    }
}

// MARK: - Indicator Card
struct IndicatorCard: View {
    let indicator: ChartIndicator

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: indicator.icon)
                .font(.title2)
                .foregroundColor(Color(indicator.color))

            Text(indicator.shortName)
                .font(.caption)
                .fontWeight(.semibold)

            Text("Tap to learn")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(width: 80, height: 80)
        .background(Color(indicator.color).opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(indicator.color), lineWidth: 1)
        )
    }
}

// MARK: - TradingView Chart (WebView)
struct TradingViewChart: UIViewRepresentable {
    let ticker: String
    let timeframe: String
    let showIndicators: Bool
    let entryPrice: Double?

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let htmlString = generateTradingViewHTML()
        webView.loadHTMLString(htmlString, baseURL: nil)
    }

    private func generateTradingViewHTML() -> String {
        // Indicators string
        let indicators = showIndicators ? """
        "studies": [
          "MAExp@tv-basicstudies",
          "Volume@tv-basicstudies",
          "RSI@tv-basicstudies"
        ],
        """ : ""

        // Entry price line
        let entryLine = entryPrice != nil ? """
        "shapes": [
          {
            "type": "horizontal_line",
            "price": \(entryPrice!),
            "color": "#2196F3",
            "linewidth": 2,
            "linestyle": 0,
            "text": "Entry: $\(String(format: "%.2f", entryPrice!))"
          }
        ],
        """ : ""

        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body, html {
                    margin: 0;
                    padding: 0;
                    width: 100%;
                    height: 100%;
                    overflow: hidden;
                }
                #tradingview_chart {
                    width: 100%;
                    height: 100%;
                }
            </style>
        </head>
        <body>
            <div id="tradingview_chart"></div>
            <script type="text/javascript" src="https://s3.tradingview.com/tv.js"></script>
            <script type="text/javascript">
                new TradingView.widget({
                    "width": "100%",
                    "height": "100%",
                    "symbol": "\(ticker)",
                    "interval": "\(timeframe)",
                    "timezone": "America/New_York",
                    "theme": "light",
                    "style": "1",
                    "locale": "en",
                    "toolbar_bg": "#f1f3f6",
                    "enable_publishing": false,
                    "hide_side_toolbar": false,
                    "allow_symbol_change": false,
                    "save_image": false,
                    "container_id": "tradingview_chart",
                    \(indicators)
                    \(entryLine)
                    "overrides": {
                        "mainSeriesProperties.candleStyle.upColor": "#26a69a",
                        "mainSeriesProperties.candleStyle.downColor": "#ef5350",
                        "mainSeriesProperties.candleStyle.borderUpColor": "#26a69a",
                        "mainSeriesProperties.candleStyle.borderDownColor": "#ef5350",
                        "mainSeriesProperties.candleStyle.wickUpColor": "#26a69a",
                        "mainSeriesProperties.candleStyle.wickDownColor": "#ef5350"
                    }
                });
            </script>
        </body>
        </html>
        """
    }
}

// MARK: - Preview
struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChartView(
                ticker: "AAPL",
                signalType: "VWAP_RECLAIM_LONG",
                entryPrice: 175.50
            )
        }
    }
}
