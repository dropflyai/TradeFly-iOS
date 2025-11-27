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
    private var useSupabase = false // Toggle this when Supabase is configured

    init() {
        // Load sample data initially
        loadSampleData()

        // Subscribe to real-time signals if using Supabase
        if useSupabase {
            subscribeToRealTimeSignals()
        }

        // Start polling for new signals (every 30 seconds)
        startPolling()
    }

    func loadSampleData() {
        activeSignals = TradingSignal.samples
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
        } else {
            // Use sample data for now
            loadSampleData()
        }
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
                    // Fallback to sample data
                    self.loadSampleData()
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
