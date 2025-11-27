//
//  SettingsView.swift
//  TradeFly AI
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var userSettings: UserSettings
    @State private var showingCapitalInput = false
    @State private var showingGoalInput = false
    @State private var showingRecalibration = false

    var body: some View {
        NavigationView {
            Form {
                // Strategy Section
                Section(header: Text("Trading Strategy")) {
                    // Capital
                    HStack {
                        Text("💰 Trading Capital")
                        Spacer()
                        Text("$\(String(format: "%.0f", userSettings.capital))")
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showingCapitalInput = true
                    }

                    // Daily Goal
                    HStack {
                        Text("🎯 Daily Profit Goal")
                        Spacer()
                        Text("$\(String(format: "%.0f", userSettings.dailyProfitGoal))")
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showingGoalInput = true
                    }

                    // Current Strategy
                    NavigationLink {
                        StrategyDetailView()
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current Strategy")
                                .font(.subheadline)

                            Text("Position: $\(String(format: "%.0f", userSettings.positionSizeMin))-\(String(format: "%.0f", userSettings.positionSizeMax)) • \(userSettings.tradesPerDay) trades/day")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    // Recalibrate Button
                    Button {
                        showingRecalibration = true
                    } label: {
                        Label("Recalibrate Strategy", systemImage: "arrow.clockwise")
                            .foregroundColor(.blue)
                    }
                }

                // Experience & Style
                Section(header: Text("Preferences")) {
                    Picker("Experience Level", selection: $userSettings.experienceLevel) {
                        ForEach(ExperienceLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }

                    Picker("Trading Style", selection: $userSettings.tradingStyle) {
                        ForEach(TradingStyle.allCases, id: \.self) { style in
                            Text(style.emoji + " " + style.rawValue).tag(style)
                        }
                    }
                }

                // Notifications
                Section(header: Text("Notifications")) {
                    NavigationLink {
                        NotificationSettingsView()
                    } label: {
                        Label("Notification Settings", systemImage: "bell.fill")
                    }
                }

                // About
                Section(header: Text("About")) {
                    NavigationLink {
                        DisclaimerView()
                    } label: {
                        Label("Disclaimer & Terms", systemImage: "doc.text")
                    }

                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingCapitalInput) {
                CapitalInputSheet()
            }
            .sheet(isPresented: $showingGoalInput) {
                GoalInputSheet()
            }
            .sheet(isPresented: $showingRecalibration) {
                RecalibrationSheet()
            }
        }
    }
}

// MARK: - Strategy Detail View
struct StrategyDetailView: View {
    @EnvironmentObject var userSettings: UserSettings

    var body: some View {
        List {
            Section(header: Text("Current Configuration")) {
                DetailItem(label: "Capital", value: "$\(String(format: "%.0f", userSettings.capital))")
                DetailItem(label: "Daily Goal", value: "$\(String(format: "%.0f", userSettings.dailyProfitGoal))")
                DetailItem(label: "Daily Return", value: "\(String(format: "%.1f", (userSettings.dailyProfitGoal/userSettings.capital)*100))%")
            }

            Section(header: Text("Calculated Strategy")) {
                DetailItem(label: "Position Size", value: "$\(String(format: "%.0f", userSettings.positionSizeMin))-\(String(format: "%.0f", userSettings.positionSizeMax))")
                DetailItem(label: "Trades per Day", value: "\(userSettings.tradesPerDay)")
                DetailItem(label: "Return per Trade", value: "+\(String(format: "%.1f", userSettings.returnPerTrade))%")
                DetailItem(label: "Risk per Trade", value: "\(String(format: "%.1f", userSettings.riskPerTrade))%")
            }

            Section(header: Text("Achievability")) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Score:")
                        Spacer()
                        Text("\(userSettings.achievabilityScore)/10")
                            .fontWeight(.bold)
                            .foregroundColor(achievabilityColor)
                    }

                    Text(userSettings.achievabilityMessage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Strategy Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    var achievabilityColor: Color {
        userSettings.achievabilityScore >= 7 ? .green : userSettings.achievabilityScore >= 5 ? .orange : .red
    }
}

struct DetailItem: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Capital Input Sheet
struct CapitalInputSheet: View {
    @EnvironmentObject var userSettings: UserSettings
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("$\(String(format: "%.0f", userSettings.capital))")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.blue)

                Slider(value: $userSettings.capital, in: 1000...100000, step: 1000)
                    .padding(.horizontal, 40)

                Spacer()
            }
            .padding(.top, 60)
            .navigationTitle("Trading Capital")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Goal Input Sheet
struct GoalInputSheet: View {
    @EnvironmentObject var userSettings: UserSettings
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("$\(String(format: "%.0f", userSettings.dailyProfitGoal))/day")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.blue)

                Slider(value: $userSettings.dailyProfitGoal, in: 50...2000, step: 50)
                    .padding(.horizontal, 40)

                Text("Achievability: \(userSettings.achievabilityScore)/10")
                    .foregroundColor(achievabilityColor)

                Spacer()
            }
            .padding(.top, 60)
            .navigationTitle("Daily Profit Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    var achievabilityColor: Color {
        userSettings.achievabilityScore >= 7 ? .green : userSettings.achievabilityScore >= 5 ? .orange : .red
    }
}

// MARK: - Recalibration Sheet
struct RecalibrationSheet: View {
    @EnvironmentObject var userSettings: UserSettings
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Strategy has been recalibrated based on your current settings.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(userSettings.strategyDescription)
                        .font(.body)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                    Button {
                        dismiss()
                    } label: {
                        Text("Got it")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(15)
                    }
                }
                .padding()
            }
            .navigationTitle("Strategy Recalibrated")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Notification Settings View
struct NotificationSettingsView: View {
    @State private var highQualityOnly = false
    @State private var quietHours = false

    var body: some View {
        Form {
            Section(header: Text("Signal Alerts")) {
                Toggle("High Quality Only", isOn: $highQualityOnly)
                Toggle("Quiet Hours (11:30 AM - 2:00 PM)", isOn: $quietHours)
            }

            Section(header: Text("Other Notifications")) {
                Toggle("Daily Summary", isOn: .constant(true))
                Toggle("Trade Reminders", isOn: .constant(true))
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Disclaimer View
struct DisclaimerView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Important Legal Disclaimer")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("""
                TradeFly AI provides educational content and technical analysis for informational purposes only.

                We are not a registered investment advisor. We do not provide personalized investment advice.

                All trading decisions are your own responsibility. You may lose money. Only trade with funds you can afford to lose.

                Past performance does not guarantee future results.

                By using this app, you acknowledge and accept these risks.
                """)
                .font(.body)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Disclaimer")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView()
        .environmentObject(UserSettings())
}
