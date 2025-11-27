//
//  TradesView.swift
//  TradeFly AI
//

import SwiftUI

struct TradesView: View {
    @State private var trades: [Trade] = Trade.samples
    @State private var selectedFilter: TradeFilter = .all

    var filteredTrades: [Trade] {
        switch selectedFilter {
        case .all: return trades
        case .open: return trades.filter { $0.isOpen }
        case .closed: return trades.filter { !$0.isOpen }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter Bar
                TradeFilterBar(selectedFilter: $selectedFilter)
                    .padding(.horizontal)
                    .padding(.vertical, 8)

                // Statistics Card
                TradeStatisticsCard(trades: trades)
                    .padding(.horizontal)

                // Trades List
                if filteredTrades.isEmpty {
                    EmptyTradesView()
                } else {
                    List(filteredTrades) { trade in
                        TradeRow(trade: trade)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Trade Journal")
        }
    }
}

// MARK: - Trade Filter
enum TradeFilter: String, CaseIterable {
    case all = "All"
    case open = "Open"
    case closed = "Closed"
}

struct TradeFilterBar: View {
    @Binding var selectedFilter: TradeFilter

    var body: some View {
        HStack(spacing: 12) {
            ForEach(TradeFilter.allCases, id: \.self) { filter in
                FilterChip(
                    title: filter.rawValue,
                    isSelected: selectedFilter == filter
                ) {
                    selectedFilter = filter
                }
            }
            Spacer()
        }
    }
}

// MARK: - Statistics Card
struct TradeStatisticsCard: View {
    let trades: [Trade]

    var closedTrades: [Trade] {
        trades.filter { !$0.isOpen }
    }

    var winningTrades: Int {
        closedTrades.filter { ($0.profitLoss ?? 0) > 0 }.count
    }

    var winRate: Double {
        guard !closedTrades.isEmpty else { return 0 }
        return Double(winningTrades) / Double(closedTrades.count) * 100
    }

    var totalPL: Double {
        closedTrades.compactMap { $0.profitLoss }.reduce(0, +)
    }

    var body: some View {
        HStack(spacing: 20) {
            StatBox(title: "Win Rate", value: "\(Int(winRate))%", color: .green)
            StatBox(title: "Total P/L", value: "$\(Int(totalPL))", color: totalPL >= 0 ? .green : .red)
            StatBox(title: "Trades", value: "\(closedTrades.count)", color: .blue)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct StatBox: View {
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

// MARK: - Trade Row
struct TradeRow: View {
    let trade: Trade

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Text(trade.signal.ticker)
                    .font(.headline)

                Text(trade.signal.signalType.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                if trade.isOpen {
                    Text("OPEN")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                } else if let pl = trade.profitLoss {
                    Text(pl >= 0 ? "+$\(Int(pl))" : "-$\(Int(abs(pl)))")
                        .font(.headline)
                        .foregroundColor(pl >= 0 ? .green : .red)
                }
            }

            // Details
            HStack {
                Label("Entry: $\(String(format: "%.2f", trade.entryPrice))", systemImage: "arrow.right.circle")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if let exitPrice = trade.exitPrice {
                    Label("Exit: $\(String(format: "%.2f", exitPrice))", systemImage: "arrow.left.circle")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // P/L
            if let plPct = trade.profitLossPercentage {
                Text("\(plPct >= 0 ? "+" : "")\(String(format: "%.1f", plPct))%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(plPct >= 0 ? .green : .red)
            }

            // Notes
            if let notes = trade.notes {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Empty State
struct EmptyTradesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("No trades yet")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("Your trades will appear here when you start trading")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 60)

            Spacer()
        }
    }
}

#Preview {
    TradesView()
}
