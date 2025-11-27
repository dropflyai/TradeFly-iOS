//
//  TradeFlyApp.swift
//  TradeFly AI
//
//  Day Trading Signal Agent - iOS App
//

import SwiftUI

@main
struct TradeFlyApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var signalService = SignalService()
    @StateObject private var userSettings = UserSettings()
    @StateObject private var supabase = SupabaseService.shared

    var body: some Scene {
        WindowGroup {
            if !supabase.isAuthenticated {
                // Show auth screen if not logged in
                AuthView()
                    .environmentObject(supabase)
            } else if appState.isOnboarding {
                // Show onboarding if first time
                OnboardingFlow(onComplete: {
                    appState.completeOnboarding()
                })
                .environmentObject(userSettings)
            } else {
                // Show main app
                ContentView()
                    .environmentObject(appState)
                    .environmentObject(signalService)
                    .environmentObject(userSettings)
                    .onAppear {
                        setupNotifications()
                        loadUserData()
                    }
            }
        }
    }

    private func setupNotifications() {
        NotificationManager.shared.requestAuthorization()
    }

    private func loadUserData() {
        userSettings.load()
    }
}

// MARK: - App State Manager
class AppState: ObservableObject {
    @Published var isOnboarding: Bool = true
    @Published var currentTab: Tab = .home
    @Published var selectedSignal: TradingSignal?

    enum Tab {
        case home
        case signals
        case learn
        case trades
        case settings
    }

    init() {
        // Check if user has completed onboarding
        isOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }

    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        isOnboarding = false
    }
}
