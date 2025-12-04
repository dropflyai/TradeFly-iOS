//
//  SignalsView.swift
//  TradeFly AI
//

import SwiftUI

struct SignalsView: View {
    @EnvironmentObject var signalService: SignalService
    @State private var selectedQuality: Quality? = nil
    @State private var selectedAssetType: AssetType? = nil
    @State private var selectedSignal: TradingSignal?

    var filteredSignals: [TradingSignal] {
        var signals = signalService.activeSignals

        if let quality = selectedQuality {
            signals = signals.filter { $0.quality == quality }
        }

        if let assetType = selectedAssetType {
            signals = signals.filter { $0.assetType == assetType }
        }

        return signals
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Asset Type Filter
                AssetTypeFilterBar(selectedAssetType: $selectedAssetType)
                    .padding(.horizontal)
                    .padding(.top, 8)

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

// MARK: - Asset Type Filter Bar
struct AssetTypeFilterBar: View {
    @Binding var selectedAssetType: AssetType?

    var body: some View {
        HStack(spacing: 12) {
            FilterChip(
                title: "All Assets",
                isSelected: selectedAssetType == nil
            ) {
                selectedAssetType = nil
            }

            FilterChip(
                title: "📈 Stocks",
                isSelected: selectedAssetType == .stock
            ) {
                selectedAssetType = .stock
            }

            FilterChip(
                title: "₿ Crypto",
                isSelected: selectedAssetType == .crypto
            ) {
                selectedAssetType = .crypto
            }
        }
    }
}

// MARK: - Quality Filter Bar
struct QualityFilterBar: View {
    @Binding var selectedQuality: Quality?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
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

            // Signal Strength & Success Probability
            HStack(spacing: 16) {
                SignalStrengthMeter(strength: signal.signalStrength)
                SuccessProbabilityMeter(probability: signal.successProbability)
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

// MARK: - Signal Strength Meter
struct SignalStrengthMeter: View {
    let strength: Double

    var strengthColor: Color {
        if strength >= 80 { return .green }
        if strength >= 60 { return .orange }
        return .red
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Signal Strength")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(Int(strength))%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(strengthColor)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(strengthColor)
                        .frame(width: geometry.size.width * CGFloat(strength / 100), height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Success Probability Meter
struct SuccessProbabilityMeter: View {
    let probability: Double

    var probabilityColor: Color {
        if probability >= 70 { return .green }
        if probability >= 55 { return .orange }
        return .red
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Win Probability")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(Int(probability))%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(probabilityColor)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(probabilityColor)
                        .frame(width: geometry.size.width * CGFloat(probability / 100), height: 8)
                }
            }
            .frame(height: 8)
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
