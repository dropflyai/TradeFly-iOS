//
//  ContentView.swift
//  TradeFly AI
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var userSettings: UserSettings

    var body: some View {
        Group {
            if appState.isOnboarding {
                OnboardingFlow()
            } else {
                MainTabView()
            }
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var signalService: SignalService

    var body: some View {
        TabView(selection: $appState.currentTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(AppState.Tab.home)

            SignalsView()
                .tabItem {
                    Label("Signals", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(AppState.Tab.signals)
                .badge(signalService.activeSignals.count)

            MarketsView()
                .tabItem {
                    Label("Markets", systemImage: "chart.bar")
                }
                .tag(AppState.Tab.markets)

            LearnView()
                .tabItem {
                    Label("Learn", systemImage: "book.fill")
                }
                .tag(AppState.Tab.learn)

            TradesView()
                .tabItem {
                    Label("Trades", systemImage: "list.bullet.clipboard")
                }
                .tag(AppState.Tab.trades)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(AppState.Tab.settings)
        }
        .accentColor(.blue)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
        .environmentObject(SignalService())
        .environmentObject(UserSettings())
}
