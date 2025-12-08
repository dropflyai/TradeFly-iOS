//
//  MarketsView.swift
//  TradeFly AI
//
//  Browse stocks, crypto, and watchlists with advanced charting

import SwiftUI

struct MarketsView: View {
    @State private var searchText = ""
    @State private var selectedCategory: MarketCategory = .stocks
    @State private var watchlists: [Watchlist] = Watchlist.defaultWatchlists
    @State private var recentlyViewed: [String] = []
    @State private var livePrices: [TickerInfo] = []
    @State private var isLoadingPrices = false

    var currentTickers: [String] {
        selectedCategory == .stocks ? TickerInfo.popularStockTickers :
        selectedCategory == .crypto ? TickerInfo.popularCryptoTickers :
        TickerInfo.popularETFTickers
    }

    var filteredTickers: [TickerInfo] {
        if searchText.isEmpty {
            return livePrices
        } else {
            return livePrices.filter {
                $0.ticker.localizedCaseInsensitiveContains(searchText) ||
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                SearchBar(text: $searchText)
                    .padding()

                // Category selector
                CategorySelector(selectedCategory: $selectedCategory)
                    .padding(.horizontal)

                // Content
                ScrollView {
                    VStack(spacing: 20) {
                        // Watchlists section
                        if !watchlists.isEmpty {
                            WatchlistsSection(watchlists: $watchlists)
                        }

                        // Recently viewed
                        if !recentlyViewed.isEmpty {
                            RecentlyViewedSection(tickers: recentlyViewed)
                        }

                        // Ticker list
                        TickerListSection(tickers: filteredTickers, onSelect: { ticker in
                            addToRecentlyViewed(ticker)
                        })
                    }
                    .padding()
                }
            }
            .navigationTitle("Markets")
            .task {
                await loadPrices()
            }
            .onChange(of: selectedCategory) {
                Task {
                    await loadPrices()
                }
            }
        }
    }

    func loadPrices() async {
        isLoadingPrices = true
        // TODO: Implement live price fetching
        // For now, show empty state
        livePrices = []
        isLoadingPrices = false
    }

    func addToRecentlyViewed(_ ticker: String) {
        if !recentlyViewed.contains(ticker) {
            recentlyViewed.insert(ticker, at: 0)
            if recentlyViewed.count > 10 {
                recentlyViewed.removeLast()
            }
        }
    }
}

// MARK: - Market Category
enum MarketCategory: String, CaseIterable {
    case stocks = "Stocks"
    case crypto = "Crypto"
    case etfs = "ETFs"
}

struct CategorySelector: View {
    @Binding var selectedCategory: MarketCategory

    var body: some View {
        HStack(spacing: 12) {
            ForEach(MarketCategory.allCases, id: \.self) { category in
                Button(action: {
                    selectedCategory = category
                }) {
                    Text(category.rawValue)
                        .font(.subheadline)
                        .fontWeight(selectedCategory == category ? .semibold : .regular)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(selectedCategory == category ? Color.blue : Color(.systemGray5))
                        .foregroundColor(selectedCategory == category ? .white : .primary)
                        .cornerRadius(20)
                }
            }
            Spacer()
        }
    }
}

// MARK: - Watchlists Section
struct WatchlistsSection: View {
    @Binding var watchlists: [Watchlist]
    @State private var showingAddWatchlist = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Watchlists")
                    .font(.headline)
                Spacer()
                Button(action: {
                    showingAddWatchlist = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(watchlists) { watchlist in
                        NavigationLink(destination: WatchlistDetailView(watchlist: watchlist)) {
                            WatchlistCard(watchlist: watchlist)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddWatchlist) {
            AddWatchlistView(watchlists: $watchlists)
        }
    }
}

struct WatchlistCard: View {
    let watchlist: Watchlist

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: watchlist.icon)
                    .foregroundColor(.blue)
                Text(watchlist.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            Text("\(watchlist.tickers.count) stocks")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 140)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Recently Viewed Section
struct RecentlyViewedSection: View {
    let tickers: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recently Viewed")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(tickers, id: \.self) { ticker in
                        NavigationLink(destination: AdvancedChartView(ticker: ticker)) {
                            TickerChip(ticker: ticker)
                        }
                    }
                }
            }
        }
    }
}

struct TickerChip: View {
    let ticker: String

    var body: some View {
        Text(ticker)
            .font(.subheadline)
            .fontWeight(.semibold)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(20)
    }
}

// MARK: - Ticker List Section
struct TickerListSection: View {
    let tickers: [TickerInfo]
    let onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Browse")
                .font(.headline)

            LazyVStack(spacing: 8) {
                ForEach(tickers) { ticker in
                    NavigationLink(destination: AdvancedChartView(ticker: ticker.ticker)) {
                        TickerRow(ticker: ticker)
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        onSelect(ticker.ticker)
                    })
                }
            }
        }
    }
}

struct TickerRow: View {
    let ticker: TickerInfo

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(ticker.ticker)
                    .font(.headline)
                Text(ticker.name)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(String(format: "%.2f", ticker.lastPrice))")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                HStack(spacing: 4) {
                    Image(systemName: ticker.changePercent >= 0 ? "arrow.up.right" : "arrow.down.right")
                    Text("\(String(format: "%.2f", abs(ticker.changePercent)))%")
                }
                .font(.caption)
                .foregroundColor(ticker.changePercent >= 0 ? .green : .red)
            }

            Image(systemName: "chart.line.uptrend.xyaxis")
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search stocks, crypto...", text: $text)
                .textFieldStyle(.plain)

            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// MARK: - Models
struct TickerInfo: Identifiable {
    let id = UUID()
    let ticker: String
    let name: String
    let lastPrice: Double
    let changePercent: Double

    // NO HARDCODED DATA - These are just ticker symbols to fetch
    static let popularStockTickers = ["AAPL", "NVDA", "TSLA", "MSFT", "GOOGL", "AMZN", "META", "AMD", "SPY", "QQQ"]
    static let popularCryptoTickers = ["BTC-USD", "ETH-USD", "BNB-USD", "SOL-USD", "ADA-USD", "DOGE-USD", "AVAX-USD", "DOT-USD"]
    static let popularETFTickers = ["SPY", "QQQ", "IWM", "VOO", "VTI", "ARKK"]
}

struct Watchlist: Identifiable {
    let id = UUID()
    var name: String
    var icon: String
    var tickers: [String]

    static let defaultWatchlists = [
        Watchlist(name: "Tech Giants", icon: "cpu", tickers: ["AAPL", "MSFT", "GOOGL", "AMZN", "META"]),
        Watchlist(name: "AI Plays", icon: "brain", tickers: ["NVDA", "AMD", "PLTR", "C3AI"]),
        Watchlist(name: "Day Trading", icon: "chart.line.uptrend.xyaxis", tickers: ["SPY", "QQQ", "TSLA", "NVDA"])
    ]
}

// MARK: - Watchlist Detail View
struct WatchlistDetailView: View {
    let watchlist: Watchlist

    var body: some View {
        List {
            ForEach(watchlist.tickers, id: \.self) { ticker in
                NavigationLink(destination: AdvancedChartView(ticker: ticker)) {
                    Text(ticker)
                        .font(.headline)
                }
            }
        }
        .navigationTitle(watchlist.name)
    }
}

// MARK: - Add Watchlist View
struct AddWatchlistView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var watchlists: [Watchlist]

    @State private var watchlistName = ""
    @State private var selectedIcon = "star"
    @State private var tickers: [String] = []
    @State private var tickerInput = ""

    let availableIcons = ["star", "heart", "bolt", "chart.bar", "brain", "cpu", "dollarsign", "flame"]

    var body: some View {
        NavigationView {
            Form {
                Section("Watchlist Name") {
                    TextField("My Watchlist", text: $watchlistName)
                }

                Section("Icon") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(availableIcons, id: \.self) { icon in
                                Button(action: {
                                    selectedIcon = icon
                                }) {
                                    Image(systemName: icon)
                                        .font(.title2)
                                        .foregroundColor(selectedIcon == icon ? .blue : .gray)
                                        .padding(12)
                                        .background(selectedIcon == icon ? Color.blue.opacity(0.1) : Color.clear)
                                        .clipShape(Circle())
                                }
                            }
                        }
                    }
                }

                Section("Tickers") {
                    HStack {
                        TextField("Enter ticker (e.g., AAPL)", text: $tickerInput)
                            .textFieldStyle(.plain)
                            .textInputAutocapitalization(.characters)

                        Button("Add") {
                            let ticker = tickerInput.uppercased()
                            if !ticker.isEmpty && !tickers.contains(ticker) {
                                tickers.append(ticker)
                                tickerInput = ""
                            }
                        }
                        .disabled(tickerInput.isEmpty)
                    }

                    ForEach(tickers, id: \.self) { ticker in
                        HStack {
                            Text(ticker)
                            Spacer()
                            Button(action: {
                                tickers.removeAll { $0 == ticker }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .navigationTitle("New Watchlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newWatchlist = Watchlist(name: watchlistName.isEmpty ? "My Watchlist" : watchlistName, icon: selectedIcon, tickers: tickers)
                        watchlists.append(newWatchlist)
                        dismiss()
                    }
                    .disabled(tickers.isEmpty)
                }
            }
        }
    }
}

#Preview {
    MarketsView()
}
