//
//  SignalService.swift
//  TradeFly AI
//

import Foundation
import Combine

class SignalService: ObservableObject {
    @Published var activeSignals: [TradingSignal] = []
    @Published var historicalSignals: [TradingSignal] = []
    @Published var isLoading: Bool = false
    @Published var error: String?

    private var cancellables = Set<AnyCancellable>()
    private let supabase = SupabaseService.shared
    private var useSupabase = true // Using Supabase for live data

    init() {
        // Start with empty signals - will be populated from Supabase
        activeSignals = []

        // Subscribe to real-time signals if using Supabase
        if useSupabase {
            subscribeToRealTimeSignals()
            // Fetch initial data immediately
            Task {
                await fetchInitialSignals()
            }
        }

        // Start polling for new signals (every 30 seconds)
        startPolling()
    }

    @MainActor
    private func fetchInitialSignals() async {
        fetchSignalsFromSupabase()
    }

    func startPolling() {
        Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.fetchSignals()
            }
            .store(in: &cancellables)
    }

    func fetchSignals() {
        if useSupabase {
            fetchSignalsFromSupabase()
        }
        // NO FALLBACK TO SAMPLE DATA - only use real data from Supabase
    }

    private func fetchSignalsFromSupabase() {
        isLoading = true

        Task {
            do {
                let signals = try await supabase.fetchActiveSignals()
                await MainActor.run {
                    self.activeSignals = signals
                    self.isLoading = false
                    self.error = nil
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.isLoading = false
                    // NO FALLBACK - keep empty or existing signals
                    print("Failed to fetch signals from Supabase: \(error)")
                }
            }
        }
    }

    private func subscribeToRealTimeSignals() {
        supabase.subscribeToSignals { [weak self] newSignal in
            // Add new signal to the top of the list
            self?.activeSignals.insert(newSignal, at: 0)

            // Send notification
            NotificationManager.shared.sendSignalNotification(signal: newSignal)
        }
    }

    func markSignalAsExecuted(_ signal: TradingSignal) {
        // Remove from active
        activeSignals.removeAll { $0.id == signal.id }

        // Add to historical
        historicalSignals.insert(signal, at: 0)
    }

    func dismissSignal(_ signal: TradingSignal) {
        activeSignals.removeAll { $0.id == signal.id }
    }

    // Enable Supabase integration
    func enableSupabase() {
        useSupabase = true
        subscribeToRealTimeSignals()
        fetchSignalsFromSupabase()
    }
}
