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
    private var signalsCancellable: AnyCancellable?

    @Published var currentUser: User?
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

        // Profile will be auto-created by database trigger
        // No need to manually create it here
        await MainActor.run {
            self.currentUser = response.user
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
            experience_level: "Beginner",
            trading_style: "Moderate"
        )

        try await client
            .from("user_profiles")
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

        let response: UserProfileResponse = try await client
            .from("user_profiles")
            .select()
            .eq("id", value: userId.uuidString)
            .single()
            .execute()
            .value

        let settings = UserSettings()
        settings.capital = response.capital
        settings.dailyProfitGoal = response.daily_profit_goal
        settings.experienceLevel = ExperienceLevel(rawValue: response.experience_level) ?? .beginner
        settings.tradingStyle = TradingStyle(rawValue: response.trading_style) ?? .moderate

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
            trading_style: settings.tradingStyle.rawValue
        )

        try await client
            .from("user_profiles")
            .update(update)
            .eq("id", value: userId.uuidString)
            .execute()
    }

    // MARK: - Trading Signals

    private struct SignalResponse: Decodable {
        let id: String
        let ticker: String
        let signal_type: String
        let quality: String
        let entry_price: Double
        let stop_loss: Double
        let take_profit_1: Double
        let take_profit_2: Double?
        let take_profit_3: Double?
        let current_price: Double
        let vwap: Double?
        let ema_9: Double?
        let ema_20: Double?
        let volume: Int?
        let avg_volume: Int?
        let relative_volume: Double?
        let market_context: String?
        let catalyst: String?
        let timeframe: String
        let ai_reasoning: String
        let confidence_score: Int?
        let risk_factors: [String]?
        let created_at: String
    }

    func fetchActiveSignals() async throws -> [TradingSignal] {
        let response: [SignalResponse] = try await client
            .from("trading_signals")
            .select()
            .eq("is_active", value: true)
            .order("created_at", ascending: false)
            .limit(20)
            .execute()
            .value

        return response.map { convertToTradingSignal($0) }
    }

    private func convertToTradingSignal(_ response: SignalResponse) -> TradingSignal {
        let currentPrice = response.current_price
        let entryPrice = response.entry_price
        let target = response.take_profit_1
        let targetPercent = ((target - entryPrice) / entryPrice) * 100

        return TradingSignal(
            id: response.id,
            ticker: response.ticker,
            signalType: SignalType(rawValue: response.signal_type) ?? .orbBreakoutLong,
            quality: Quality(rawValue: response.quality) ?? .medium,
            timestamp: ISO8601DateFormatter().date(from: response.created_at) ?? Date(),
            price: currentPrice,
            vwap: response.vwap ?? currentPrice,
            ema9: response.ema_9 ?? currentPrice,
            ema20: response.ema_20 ?? currentPrice,
            ema50: currentPrice, // Not in backend response, use current price
            volume: response.volume ?? 0,
            context: response.market_context ?? "",
            idea: response.signal_type.contains("LONG") ? .call : .put,
            entry: PriceRange(low: entryPrice * 0.995, high: entryPrice * 1.005),
            stopLoss: response.stop_loss,
            target: target,
            targetPercentage: targetPercent,
            timeframe: response.timeframe
        )
    }

    // MARK: - Real-time Subscriptions

    func subscribeToSignals(onNewSignal: @escaping (TradingSignal) -> Void) {
        Task {
            let channel = client.channel("trading_signals")

            let changes = channel.postgresChange(
                InsertAction.self,
                schema: "public",
                table: "trading_signals",
                filter: "is_active=eq.true"
            )

            try? await channel.subscribeWithError()

            for await change in changes {
                // Parse the new signal and call the callback
                if let newSignal = parseSignalFromChange(change) {
                    await MainActor.run {
                        onNewSignal(newSignal)
                    }
                }
            }
        }
    }

    private func parseSignalFromChange(_ change: InsertAction) -> TradingSignal? {
        // Convert the postgres change to a TradingSignal
        // This would need proper JSON parsing based on the change structure
        return nil // Placeholder
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

        try await client
            .from("trades")
            .insert(tradeInsert)
            .execute()
    }

    func fetchUserTrades() async throws -> [Trade] {
        guard let userId = currentUser?.id else {
            throw SupabaseError.notAuthenticated
        }

        struct TradeResponse: Decodable {
            let id: String
            let ticker: String
            let signal_type: String
            let entry_price: Double
            let exit_price: Double?
            let shares: Int
            let profit_loss: Double?
            let profit_loss_percentage: Double?
            let is_open: Bool
            let opened_at: String
            let closed_at: String?
            let notes: String?
        }

        let _: [TradeResponse] = try await client
            .from("trades")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("opened_at", ascending: false)
            .execute()
            .value

        // Convert to Trade objects
        // This would need the full signal data, so might need a join query
        return [] // Placeholder - would convert TradeResponse to Trade
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

        try await client
            .from("learning_progress")
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

        let response: [ProgressResponse] = try await client
            .from("learning_progress")
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
