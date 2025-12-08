//
//  MarketStatusService.swift
//  TradeFly
//

import Foundation
import Combine

class MarketStatusService: ObservableObject {
    @Published var marketStatus: MarketStatusResponse?
    @Published var isLoading: Bool = false
    @Published var error: String?

    private let apiClient = APIClient.shared
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?

    init() {
        // Fetch initial status
        Task {
            await fetchMarketStatus()
        }

        // Auto-refresh every 60 seconds
        startAutoRefresh()
    }

    func fetchMarketStatus() async {
        isLoading = true

        do {
            let status = try await apiClient.fetchMarketStatus()
            await MainActor.run {
                self.marketStatus = status
                self.isLoading = false
                self.error = nil
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
                print("Failed to fetch market status: \(error)")
            }
        }
    }

    private func startAutoRefresh() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task {
                await self?.fetchMarketStatus()
            }
        }
    }

    deinit {
        timer?.invalidate()
    }
}
