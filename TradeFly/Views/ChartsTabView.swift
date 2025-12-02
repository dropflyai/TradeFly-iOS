//
//  ChartsTabView.swift
//  TradeFly
//
//  Educational charting with quick access to all watched tickers
//

import SwiftUI

struct ChartsTabView: View {
    @State private var selectedTicker = "AAPL"
    @State private var searchText = ""
    @State private var showingSearch = false

    // Watched tickers (matches backend)
    let watchedTickers = ["NVDA", "TSLA", "AAPL", "AMD", "MSFT", "GOOGL", "AMZN", "META"]
    let popularTickers = ["SPY", "QQQ", "IWM", "DIA"]

    var filteredTickers: [String] {
        if searchText.isEmpty {
            return watchedTickers
        }
        return watchedTickers.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Ticker selector
                tickerSelector

                // Main chart
                ChartView(
                    ticker: selectedTicker,
                    signalType: nil,
                    entryPrice: nil
                )

                // Educational footer
                educationalFooter
            }
            .navigationTitle("📊 Charts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSearch.toggle() }) {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
            .searchable(text: $searchText, isPresented: $showingSearch, prompt: "Search tickers...")
        }
    }

    // MARK: - Ticker Selector
    private var tickerSelector: some View {
        VStack(spacing: 12) {
            // Watched tickers
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(watchedTickers, id: \.self) { ticker in
                        TickerButton(
                            ticker: ticker,
                            isSelected: selectedTicker == ticker,
                            action: { selectedTicker = ticker }
                        )
                    }
                }
                .padding(.horizontal)
            }

            // Market indices
            HStack(spacing: 8) {
                Text("Market:")
                    .font(.caption)
                    .foregroundColor(.secondary)

                ForEach(popularTickers, id: \.self) { ticker in
                    Button(action: { selectedTicker = ticker }) {
                        Text(ticker)
                            .font(.caption)
                            .fontWeight(selectedTicker == ticker ? .bold : .regular)
                            .foregroundColor(selectedTicker == ticker ? .white : .blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                selectedTicker == ticker ? Color.blue : Color.blue.opacity(0.1)
                            )
                            .cornerRadius(6)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.systemGray4)),
            alignment: .bottom
        )
    }

    // MARK: - Educational Footer
    private var educationalFooter: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "graduationcap.fill")
                    .foregroundColor(.blue)

                Text("Learning Tip")
                    .font(.headline)

                Spacer()
            }

            Text("Practice reading charts by identifying VWAP, EMA alignments, and volume spikes. TradeFly's signals are based on these patterns!")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)

            NavigationLink(destination: LearnView()) {
                HStack {
                    Text("Go to Lessons")
                    Spacer()
                    Image(systemName: "arrow.right")
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
    }
}

// MARK: - Ticker Button
struct TickerButton: View {
    let ticker: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(ticker)
                    .font(.body)
                    .fontWeight(isSelected ? .bold : .semibold)
                    .foregroundColor(isSelected ? .white : .primary)

                if isSelected {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 4, height: 4)
                }
            }
            .frame(width: 70, height: 44)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .cornerRadius(10)
        }
    }
}

// MARK: - Preview
struct ChartsTabView_Previews: PreviewProvider {
    static var previews: some View {
        ChartsTabView()
    }
}
