//
//  SupabaseService.swift
//  TradeFly AI
//

import Foundation
import Supabase
import Combine

class SupabaseService: ObservableObject {
    static let shared = SupabaseService()

    private let supabaseURL = URL(string: SupabaseConfig.url)!
    private let supabaseKey = SupabaseConfig.anonKey

    private var client: SupabaseClient

    @Published var currentUser: Auth.User?
    @Published var isAuthenticated = false

    init() {
        self.client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey
        )

        // Check if user is already logged in
        Task {
            await checkAuthStatus()
        }
    }

    // MARK: - Authentication

    func checkAuthStatus() async {
        do {
            let session = try await client.auth.session
            await MainActor.run {
                self.currentUser = session.user
                self.isAuthenticated = true
            }
        } catch {
            await MainActor.run {
                self.isAuthenticated = false
            }
        }
    }

    func signUp(email: String, password: String) async throws {
        let response = try await client.auth.signUp(
            email: email,
            password: password
        )

        // Create user profile
        let user = response.user
        try await createUserProfile(userId: user.id)
        await MainActor.run {
            self.currentUser = user
            self.isAuthenticated = true
        }
    }

    func signIn(email: String, password: String) async throws {
        let session = try await client.auth.signIn(
            email: email,
            password: password
        )

        await MainActor.run {
            self.currentUser = session.user
            self.isAuthenticated = true
        }
    }

    func signOut() async throws {
        try await client.auth.signOut()
        await MainActor.run {
            self.currentUser = nil
            self.isAuthenticated = false
        }
    }

    // MARK: - User Profile

    private func createUserProfile(userId: UUID) async throws {
        struct UserProfile: Encodable {
            let id: UUID
            let capital: Double
            let daily_profit_goal: Double
            let experience_level: String
            let trading_style: String
        }

        let profile = UserProfile(
            id: userId,
            capital: 10000,
            daily_profit_goal: 300,
            experience_level: "beginner",
            trading_style: "moderate"
        )

        try await client.from("user_profiles")
            .insert(profile)
            .execute()
    }

    func getUserProfile() async throws -> UserSettings {
        guard let userId = currentUser?.id else {
            throw SupabaseError.notAuthenticated
        }

        struct UserProfileResponse: Decodable {
            let capital: Double
            let daily_profit_goal: Double
            let experience_level: String
            let trading_style: String
        }

        let response: UserProfileResponse = try await client.from("user_profiles")
            .select()
            .eq("id", value: userId.uuidString)
            .single()
            .execute()
            .value

        let settings = UserSettings()
        settings.capital = response.capital
        settings.dailyProfitGoal = response.daily_profit_goal
        settings.experienceLevel = ExperienceLevel(rawValue: response.experience_level) ?? .beginner
        settings.tradingStyle = TradingStyle(rawValue: response.trading_style.capitalized) ?? .moderate

        return settings
    }

    func updateUserProfile(settings: UserSettings) async throws {
        guard let userId = currentUser?.id else {
            throw SupabaseError.notAuthenticated
        }

        struct UserProfileUpdate: Encodable {
            let capital: Double
            let daily_profit_goal: Double
            let experience_level: String
            let trading_style: String
        }

        let update = UserProfileUpdate(
            capital: settings.capital,
            daily_profit_goal: settings.dailyProfitGoal,
            experience_level: settings.experienceLevel.rawValue,
            trading_style: settings.tradingStyle.rawValue.lowercased()
        )

        try await client.from("user_profiles")
            .update(update)
            .eq("id", value: userId.uuidString)
            .execute()
    }

    // MARK: - Trading Signals

    func fetchActiveSignals() async throws -> [TradingSignal] {
        // For now, return sample data
        // In production, you'd fetch from Supabase and convert to TradingSignal
        return TradingSignal.samples
    }

    // MARK: - Trades

    func saveTrade(_ trade: Trade) async throws {
        guard let userId = currentUser?.id else {
            throw SupabaseError.notAuthenticated
        }

        struct TradeInsert: Encodable {
            let user_id: String
            let signal_id: String?
            let ticker: String
            let signal_type: String
            let entry_price: Double
            let exit_price: Double?
            let shares: Int
            let profit_loss: Double?
            let profit_loss_percentage: Double?
            let is_open: Bool
            let notes: String?
        }

        let tradeInsert = TradeInsert(
            user_id: userId.uuidString,
            signal_id: trade.signal.id,
            ticker: trade.signal.ticker,
            signal_type: trade.signal.signalType.rawValue,
            entry_price: trade.entryPrice,
            exit_price: trade.exitPrice,
            shares: trade.quantity,
            profit_loss: trade.profitLoss,
            profit_loss_percentage: trade.profitLossPercentage,
            is_open: trade.isOpen,
            notes: trade.notes
        )

        try await client.from("trades")
            .insert(tradeInsert)
            .execute()
    }

    func fetchUserTrades() async throws -> [Trade] {
        // For now, return sample data
        // In production, you'd fetch from Supabase and convert to Trade
        return Trade.samples
    }

    // MARK: - Learning Progress

    func markLessonComplete(moduleId: String) async throws {
        guard let userId = currentUser?.id else {
            throw SupabaseError.notAuthenticated
        }

        struct LearningProgressInsert: Encodable {
            let user_id: String
            let module_id: String
            let completed: Bool
            let completed_at: String
        }

        let progress = LearningProgressInsert(
            user_id: userId.uuidString,
            module_id: moduleId,
            completed: true,
            completed_at: ISO8601DateFormatter().string(from: Date())
        )

        try await client.from("learning_progress")
            .upsert(progress)
            .execute()
    }

    func getLearningProgress() async throws -> Set<String> {
        guard let userId = currentUser?.id else {
            throw SupabaseError.notAuthenticated
        }

        struct ProgressResponse: Decodable {
            let module_id: String
        }

        let response: [ProgressResponse] = try await client.from("learning_progress")
            .select("module_id")
            .eq("user_id", value: userId.uuidString)
            .eq("completed", value: true)
            .execute()
            .value

        return Set(response.map { $0.module_id })
    }
}

// MARK: - Errors

enum SupabaseError: LocalizedError {
    case notAuthenticated
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "User is not authenticated"
        case .invalidResponse:
            return "Invalid response from server"
        }
    }
}
