//
//  BackendConfig.swift
//  TradeFly
//

import Foundation

enum BackendConfig {
    // MARK: - Backend URL Configuration

    /// Backend API base URL - UPDATE THIS after deploying to EC2
    ///
    /// Development: Use localhost or EC2 IP
    /// Production: Use your domain (api.tradefly.ai)
    static let baseURL: String = {
        #if DEBUG
        // For simulator/development
        // Option 1: EC2 IP (uncomment and replace with your IP)
        // return "http://YOUR_EC2_IP:8000"

        // Option 2: Domain (if configured)
        // return "https://api.tradefly.ai"

        // Option 3: Localhost (for testing with local backend)
        return "http://localhost:8000"
        #else
        // Production - MUST be your deployed backend
        return "https://api.tradefly.ai"  // UPDATE THIS
        #endif
    }()

    // MARK: - API Endpoints

    enum Endpoint {
        case health
        case activeSignals
        case scanSignals
        case marketStatus
        case price(ticker: String)
        case news(ticker: String, hoursBack: Int)
        case marketNews(hoursBack: Int)
        case candles(ticker: String, interval: String, limit: Int)
        case stats

        var path: String {
            switch self {
            case .health:
                return "/health"
            case .activeSignals:
                return "/signals/active"
            case .scanSignals:
                return "/signals/scan"
            case .marketStatus:
                return "/market-status"
            case .price(let ticker):
                return "/price/\(ticker)"
            case .news(let ticker, let hoursBack):
                return "/news/\(ticker)?hours_back=\(hoursBack)"
            case .marketNews(let hoursBack):
                return "/news/market/latest?hours_back=\(hoursBack)"
            case .candles(let ticker, let interval, let limit):
                return "/candles/\(ticker)?interval=\(interval)&limit=\(limit)"
            case .stats:
                return "/stats"
            }
        }

        var url: URL? {
            URL(string: baseURL + path)
        }
    }
}
