//
//  SupabaseService.swift
//  TradeFly AI
//

import Foundation
import Supabase
import Combine

class SupabaseService: ObservableObject {
    static let shared = SupabaseService()

    // TODO: Replace with your actual Supabase credentials
    // Get these from: https://app.supabase.com/project/_/settings/api
    private let supabaseURL = URL(string: "YOUR_SUPABASE_URL")!
    private let supabaseKey = "YOUR_SUPABASE_ANON_KEY"

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

        // Create user profile
        if let user = response.user {
            try await createUserProfile(userId: user.id)
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticated = true
            }
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
            trading_style: "scalper"
        )

        try await client.database
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

        let response: UserProfileResponse = try await client.database
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
        settings.tradingStyle = TradingStyle(rawValue: response.trading_style) ?? .scalper

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

        try await client.database
            .from("user_profiles")
            .update(update)
            .eq("id", value: userId.uuidString)
            .execute()
    }

    // MARK: - Trading Signals

    func fetchActiveSignals() async throws -> [TradingSignal] {
        struct SignalResponse: Decodable {
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

        let response: [SignalResponse] = try await client.database
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
        return TradingSignal(
            id: response.id,
            ticker: response.ticker,
            signalType: SignalType(rawValue: response.signal_type) ?? .orbBreakoutLong,
            quality: SignalQuality(rawValue: response.quality) ?? .medium,
            entryPrice: response.entry_price,
            stopLoss: response.stop_loss,
            takeProfit1: response.take_profit_1,
            takeProfit2: response.take_profit_2,
            takeProfit3: response.take_profit_3,
            currentPrice: response.current_price,
            vwap: response.vwap,
            ema9: response.ema_9,
            ema20: response.ema_20,
            volume: response.volume,
            avgVolume: response.avg_volume,
            relativeVolume: response.relative_volume,
            marketContext: response.market_context ?? "",
            catalyst: response.catalyst,
            timeframe: response.timeframe,
            aiReasoning: response.ai_reasoning,
            confidenceScore: response.confidence_score ?? 70,
            riskFactors: response.risk_factors ?? [],
            timestamp: ISO8601DateFormatter().date(from: response.created_at) ?? Date()
        )
    }

    // MARK: - Real-time Subscriptions

    func subscribeToSignals(onNewSignal: @escaping (TradingSignal) -> Void) {
        Task {
            let channel = await client.channel("trading_signals")

            let changes = channel.postgresChange(
                InsertAction.self,
                schema: "public",
                table: "trading_signals",
                filter: "is_active=eq.true"
            )

            await channel.subscribe()

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
            shares: trade.shares,
            profit_loss: trade.profitLoss,
            profit_loss_percentage: trade.profitLossPercentage,
            is_open: trade.isOpen,
            notes: trade.notes
        )

        try await client.database
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

        let response: [TradeResponse] = try await client.database
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

        try await client.database
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

        let response: [ProgressResponse] = try await client.database
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
