//
//  MoreView.swift
//  TradeFly AI
//
//  "More" tab containing Learn, Trades, Settings, and other features

import SwiftUI

struct MoreView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            List {
                // Main Features Section
                Section(header: Text("Features")) {
                    NavigationLink(destination: LearnView()) {
                        HStack {
                            Image(systemName: "book.fill")
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            Text("Learn")
                            Spacer()
                            Text("50+ Lessons")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    NavigationLink(destination: TradesView()) {
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .foregroundColor(.green)
                                .frame(width: 30)
                            Text("Trade Journal")
                            Spacer()
                            Text("Track Performance")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Account Section
                Section(header: Text("Account")) {
                    NavigationLink(destination: SettingsView()) {
                        HStack {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.gray)
                                .frame(width: 30)
                            Text("Settings")
                        }
                    }

                    Button(action: {
                        // TODO: Implement profile
                    }) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.purple)
                                .frame(width: 30)
                            Text("Profile")
                        }
                    }
                }

                // Tools Section
                Section(header: Text("Tools")) {
                    NavigationLink(destination: Text("Watchlists")) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.orange)
                                .frame(width: 30)
                            Text("Watchlists")
                        }
                    }

                    NavigationLink(destination: Text("Alerts")) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.red)
                                .frame(width: 30)
                            Text("Price Alerts")
                        }
                    }

                    NavigationLink(destination: Text("Screener")) {
                        HStack {
                            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            Text("Stock Screener")
                        }
                    }
                }

                // Support Section
                Section(header: Text("Support")) {
                    Button(action: {
                        // TODO: Open help center
                    }) {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            Text("Help Center")
                        }
                    }

                    Button(action: {
                        // TODO: Open feedback
                    }) {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.green)
                                .frame(width: 30)
                            Text("Send Feedback")
                        }
                    }

                    NavigationLink(destination: Text("About TradeFly")) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.gray)
                                .frame(width: 30)
                            Text("About")
                        }
                    }
                }
            }
            .navigationTitle("More")
            .listStyle(InsetGroupedListStyle())
        }
    }
}

#Preview {
    MoreView()
        .environmentObject(AppState())
}
