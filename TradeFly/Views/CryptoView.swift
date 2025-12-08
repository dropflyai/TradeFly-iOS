//
//  CryptoView.swift
//  TradeFly AI
//
//  Dedicated cryptocurrency dashboard

import SwiftUI

struct CryptoView: View {
    @State private var cryptoPrices: [CryptoInfo] = []
    @State private var isLoading = false
    @State private var searchText = ""

    var filteredCrypto: [CryptoInfo] {
        if searchText.isEmpty {
            return cryptoPrices
        } else {
            return cryptoPrices.filter {
                $0.symbol.localizedCaseInsensitiveContains(searchText) ||
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

                // Crypto list
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(filteredCrypto) { crypto in
                            CryptoCard(crypto: crypto)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Cryptocurrency")
            .task {
                await loadCryptoPrices()
            }
            .refreshable {
                await loadCryptoPrices()
            }
        }
    }

    func loadCryptoPrices() async {
        isLoading = true

        // Crypto tickers on Polygon
        let cryptoTickers = [
            "BTC-USD", "ETH-USD", "BNB-USD", "SOL-USD",
            "ADA-USD", "DOGE-USD", "AVAX-USD", "DOT-USD",
            "MATIC-USD", "LINK-USD"
        ]

        // Fetch prices from Polygon
        let prices = await PriceService.shared.fetchPrices(for: cryptoTickers)

        // Map to CryptoInfo
        cryptoPrices = prices.map { price in
            CryptoInfo(
                symbol: price.ticker.replacingOccurrences(of: "-USD", with: ""),
                name: getCryptoName(for: price.ticker),
                price: price.lastPrice,
                change24h: price.changePercent,
                marketCap: 0, // TODO: Fetch from different endpoint
                volume24h: Double(price.volume)
            )
        }

        isLoading = false
    }

    func getCryptoName(for ticker: String) -> String {
        let names: [String: String] = [
            "BTC-USD": "Bitcoin",
            "ETH-USD": "Ethereum",
            "BNB-USD": "Binance Coin",
            "SOL-USD": "Solana",
            "ADA-USD": "Cardano",
            "DOGE-USD": "Dogecoin",
            "AVAX-USD": "Avalanche",
            "DOT-USD": "Polkadot",
            "MATIC-USD": "Polygon",
            "LINK-USD": "Chainlink"
        ]
        return names[ticker] ?? ticker
    }
}

// MARK: - Components

struct CryptoCard: View {
    let crypto: CryptoInfo

    var body: some View {
        NavigationLink(destination: AdvancedChartView(ticker: "\(crypto.symbol)-USD")) {
            HStack {
                // Crypto icon/symbol
                Circle()
                    .fill(crypto.change24h >= 0 ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(String(crypto.symbol.prefix(3)))
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(crypto.change24h >= 0 ? .green : .red)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(crypto.name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(crypto.symbol)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("$\(crypto.price, specifier: "%.2f")")
                        .font(.headline)
                        .foregroundColor(.primary)

                    HStack(spacing: 4) {
                        Image(systemName: crypto.change24h >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.caption2)
                        Text("\(abs(crypto.change24h), specifier: "%.2f")%")
                            .font(.caption)
                    }
                    .foregroundColor(crypto.change24h >= 0 ? .green : .red)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

// MARK: - Models

struct CryptoInfo: Identifiable {
    let id = UUID()
    let symbol: String
    let name: String
    let price: Double
    let change24h: Double
    let marketCap: Double
    let volume24h: Double
}

// Note: SearchBar is defined in MarketsView.swift and reused here

#Preview {
    CryptoView()
}
