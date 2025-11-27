//
//  OnboardingFlow.swift
//  TradeFly AI
//

import SwiftUI

struct OnboardingFlow: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var userSettings: UserSettings
    @State private var currentStep = 0

    var body: some View {
        TabView(selection: $currentStep) {
            WelcomeScreen(onNext: { currentStep = 1 })
                .tag(0)

            CapitalInputScreen(onNext: { currentStep = 2 })
                .tag(1)

            ProfitGoalScreen(onNext: { currentStep = 3 })
                .tag(2)

            ExperienceLevelScreen(onNext: { currentStep = 4 })
                .tag(3)

            TradingStyleScreen(onNext: { currentStep = 5 })
                .tag(4)

            DisclaimerScreen(onComplete: {
                appState.completeOnboarding()
            })
                .tag(5)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

// MARK: - Welcome Screen
struct WelcomeScreen: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.blue)

            Text("Welcome to TradeFly AI")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("Your AI-powered day trading assistant that adapts to YOUR goals")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()

            Button {
                onNext()
            } label: {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(15)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Capital Input Screen
struct CapitalInputScreen: View {
    @EnvironmentObject var userSettings: UserSettings
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 12) {
                Text("💰 How much capital do you have for day trading?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Text("This is the total amount you're comfortable using for day trading. We'll calculate position sizes based on this.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .padding(.top, 60)

            Spacer()

            VStack(spacing: 20) {
                Text("$\(String(format: "%.0f", userSettings.capital))")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.blue)

                Slider(value: $userSettings.capital, in: 1000...100000, step: 1000)
                    .padding(.horizontal, 40)

                HStack {
                    Text("$1,000")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("$100,000")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 40)
            }

            Spacer()

            Button {
                onNext()
            } label: {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(15)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Profit Goal Screen
struct ProfitGoalScreen: View {
    @EnvironmentObject var userSettings: UserSettings
    let onNext: () -> Void

    var dailyReturnPercentage: Double {
        (userSettings.dailyProfitGoal / userSettings.capital) * 100
    }

    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 12) {
                Text("🎯 What's your daily profit target?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                HStack {
                    Image(systemName: achievabilityIcon)
                        .foregroundColor(achievabilityColor)

                    Text("Achievability Score: \(userSettings.achievabilityScore)/10")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(achievabilityColor)
                }
            }
            .padding(.top, 60)

            Spacer()

            VStack(spacing: 20) {
                Text("$\(String(format: "%.0f", userSettings.dailyProfitGoal))/day")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.blue)

                Text("(\(String(format: "%.1f", dailyReturnPercentage))% daily return)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Slider(value: $userSettings.dailyProfitGoal, in: 50...2000, step: 50)
                    .padding(.horizontal, 40)

                HStack {
                    Text("$50")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("$2,000")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 40)

                // Suggested Goals
                VStack(alignment: .leading, spacing: 8) {
                    Text("Suggested goals for $\(String(format: "%.0f", userSettings.capital)) capital:")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    SuggestedGoalButton(
                        label: "Conservative",
                        amount: userSettings.capital * 0.015,
                        percentage: 1.5,
                        isSelected: abs(userSettings.dailyProfitGoal - userSettings.capital * 0.015) < 10
                    ) {
                        userSettings.dailyProfitGoal = userSettings.capital * 0.015
                    }

                    SuggestedGoalButton(
                        label: "Moderate",
                        amount: userSettings.capital * 0.03,
                        percentage: 3.0,
                        isSelected: abs(userSettings.dailyProfitGoal - userSettings.capital * 0.03) < 10
                    ) {
                        userSettings.dailyProfitGoal = userSettings.capital * 0.03
                    }

                    SuggestedGoalButton(
                        label: "Aggressive",
                        amount: userSettings.capital * 0.05,
                        percentage: 5.0,
                        isSelected: abs(userSettings.dailyProfitGoal - userSettings.capital * 0.05) < 10
                    ) {
                        userSettings.dailyProfitGoal = userSettings.capital * 0.05
                    }
                }
                .padding(.horizontal, 40)
            }

            // Achievability Message
            Text(userSettings.achievabilityMessage)
                .font(.subheadline)
                .foregroundColor(achievabilityColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()

            Button {
                onNext()
            } label: {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(15)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }

    var achievabilityIcon: String {
        userSettings.achievabilityScore >= 7 ? "checkmark.circle.fill" : userSettings.achievabilityScore >= 5 ? "exclamationmark.triangle.fill" : "xmark.circle.fill"
    }

    var achievabilityColor: Color {
        userSettings.achievabilityScore >= 7 ? .green : userSettings.achievabilityScore >= 5 ? .orange : .red
    }
}

struct SuggestedGoalButton: View {
    let label: String
    let amount: Double
    let percentage: Double
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .fontWeight(.medium)

                Spacer()

                Text("$\(String(format: "%.0f", amount))/day (\(String(format: "%.1f", percentage))%)")
                    .font(.caption)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .cornerRadius(8)
        }
    }
}

// MARK: - Experience Level Screen
struct ExperienceLevelScreen: View {
    @EnvironmentObject var userSettings: UserSettings
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 12) {
                Text("📚 What's your trading experience?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Text("We'll adjust explanations and education based on your level")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .padding(.top, 60)

            Spacer()

            VStack(spacing: 16) {
                ForEach(ExperienceLevel.allCases, id: \.self) { level in
                    ExperienceLevelButton(
                        level: level,
                        isSelected: userSettings.experienceLevel == level
                    ) {
                        userSettings.experienceLevel = level
                    }
                }
            }
            .padding(.horizontal, 40)

            Spacer()

            Button {
                onNext()
            } label: {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(15)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
}

struct ExperienceLevelButton: View {
    let level: ExperienceLevel
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(level.rawValue)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)

                Text(level.description)
                    .font(.subheadline)
                    .foregroundColor(isSelected ? .white.opacity(0.9) : .secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

// MARK: - Trading Style Screen
struct TradingStyleScreen: View {
    @EnvironmentObject var userSettings: UserSettings
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 12) {
                Text("⚡ Choose your trading style")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Text("Based on $\(String(format: "%.0f", userSettings.capital)) capital, $\(String(format: "%.0f", userSettings.dailyProfitGoal))/day goal")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .padding(.top, 60)

            Spacer()

            VStack(spacing: 16) {
                ForEach(TradingStyle.allCases, id: \.self) { style in
                    TradingStyleButton(
                        style: style,
                        isSelected: userSettings.tradingStyle == style,
                        isRecommended: style == .moderate
                    ) {
                        userSettings.tradingStyle = style
                    }
                }
            }
            .padding(.horizontal, 40)

            Spacer()

            Button {
                onNext()
            } label: {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(15)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
}

struct TradingStyleButton: View {
    let style: TradingStyle
    let isSelected: Bool
    let isRecommended: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(style.emoji + " " + style.rawValue)
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : .primary)

                    if isRecommended {
                        Text("Recommended")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green)
                            .cornerRadius(6)
                    }

                    Spacer()
                }

                Text(style.description)
                    .font(.subheadline)
                    .foregroundColor(isSelected ? .white.opacity(0.9) : .secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

// MARK: - Disclaimer Screen
struct DisclaimerScreen: View {
    let onComplete: () -> Void
    @State private var hasAccepted = false

    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)

                Text("Important Disclaimer")
                    .font(.title)
                    .fontWeight(.bold)
            }
            .padding(.top, 60)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    DisclaimerPoint(
                        icon: "info.circle.fill",
                        title: "Educational Purposes Only",
                        description: "TradeFly AI provides educational content and technical analysis for informational purposes. We are not a registered investment advisor."
                    )

                    DisclaimerPoint(
                        icon: "person.fill.checkmark",
                        title: "You Make All Decisions",
                        description: "We do not provide personalized investment advice. All trading decisions are your own responsibility."
                    )

                    DisclaimerPoint(
                        icon: "exclamationmark.triangle.fill",
                        title: "Trading Involves Risk",
                        description: "You may lose money. Only trade with funds you can afford to lose. Past performance does not guarantee future results."
                    )
                }
                .padding(.horizontal, 40)
            }

            Button {
                hasAccepted.toggle()
            } label: {
                HStack {
                    Image(systemName: hasAccepted ? "checkmark.square.fill" : "square")
                        .foregroundColor(hasAccepted ? .blue : .gray)

                    Text("I understand and accept the risks")
                        .font(.subheadline)
                }
            }
            .padding(.horizontal, 40)

            Button {
                if hasAccepted {
                    onComplete()
                }
            } label: {
                Text("Start Trading")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(hasAccepted ? Color.blue : Color.gray)
                    .cornerRadius(15)
            }
            .disabled(!hasAccepted)
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
}

struct DisclaimerPoint: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    OnboardingFlow()
        .environmentObject(AppState())
        .environmentObject(UserSettings())
}
