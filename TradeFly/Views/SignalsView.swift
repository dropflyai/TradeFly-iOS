//
//  SignalsView.swift
//  TradeFly AI
//

import SwiftUI

struct SignalsView: View {
    @EnvironmentObject var signalService: SignalService
    @State private var selectedQuality: Quality? = nil
    @State private var selectedSignal: TradingSignal?

    var filteredSignals: [TradingSignal] {
        if let quality = selectedQuality {
            return signalService.activeSignals.filter { $0.quality == quality }
        }
        return signalService.activeSignals
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Quality Filter
                QualityFilterBar(selectedQuality: $selectedQuality)
                    .padding(.horizontal)
                    .padding(.vertical, 8)

                if filteredSignals.isEmpty {
                    EmptyStateView(selectedQuality: selectedQuality)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredSignals) { signal in
                                SignalCard(signal: signal)
                                    .onTapGesture {
                                        selectedSignal = signal
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Signals")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        signalService.fetchSignals()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .sheet(item: $selectedSignal) { signal in
                SignalDetailView(signal: signal)
            }
        }
    }
}

// MARK: - Quality Filter Bar
struct QualityFilterBar: View {
    @Binding var selectedQuality: Quality?

    var body: some View {
        HStack(spacing: 12) {
            FilterChip(
                title: "All",
                isSelected: selectedQuality == nil
            ) {
                selectedQuality = nil
            }

            FilterChip(
                title: "⭐⭐⭐ HIGH",
                isSelected: selectedQuality == .high
            ) {
                selectedQuality = .high
            }

            FilterChip(
                title: "⭐⭐ MEDIUM",
                isSelected: selectedQuality == .medium
            ) {
                selectedQuality = .medium
            }

            FilterChip(
                title: "⭐ LOW",
                isSelected: selectedQuality == .low
            ) {
                selectedQuality = .low
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .cornerRadius(20)
        }
    }
}

// MARK: - Signal Card (Full)
struct SignalCard: View {
    let signal: TradingSignal

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(signal.ticker)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(signal.qualityIcon)
                            .font(.body)
                    }

                    Text(signal.signalType.displayName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                QualityBadge(quality: signal.quality)
            }

            Divider()

            // Price Info
            HStack {
                PriceInfoItem(label: "Price", value: "$\(String(format: "%.2f", signal.price))")
                Spacer()
                PriceInfoItem(label: "VWAP", value: "$\(String(format: "%.2f", signal.vwap))")
                Spacer()
                PriceInfoItem(label: "Target", value: "+\(String(format: "%.0f", signal.targetPercentage))%")
            }

            // Context
            Text(signal.context)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)

            // Trade Idea
            HStack {
                Label(signal.idea.rawValue, systemImage: signal.idea == .call ? "arrow.up.circle.fill" : signal.idea == .put ? "arrow.down.circle.fill" : "xmark.circle.fill")
                    .font(.headline)
                    .foregroundColor(signal.idea == .call ? .green : signal.idea == .put ? .red : .gray)

                Spacer()

                Text(signal.formattedTimestamp)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct QualityBadge: View {
    let quality: Quality

    var backgroundColor: Color {
        switch quality {
        case .high: return .green
        case .medium: return .orange
        case .low: return .red
        }
    }

    var body: some View {
        Text(quality.rawValue)
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(backgroundColor)
            .cornerRadius(8)
    }
}

struct PriceInfoItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
}

// MARK: - Empty State
struct EmptyStateView: View {
    let selectedQuality: Quality?

    var message: String {
        if let quality = selectedQuality {
            return "No \(quality.rawValue) quality signals right now"
        }
        return "No active signals"
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "antenna.radiowaves.left.and.right.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text(message)
                .font(.headline)
                .foregroundColor(.secondary)

            Text("We'll notify you when a quality setup appears")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 60)

            Spacer()
        }
    }
}

#Preview {
    SignalsView()
        .environmentObject(SignalService())
}
