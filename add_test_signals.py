#!/usr/bin/env python3
"""
Add live trading signals to Supabase database
This will populate the app with actual trading signals
"""

import os
import sys
from datetime import datetime, timedelta
from supabase import create_client, Client

# Supabase credentials
SUPABASE_URL = "https://nplgxhthjwwyywbnvxzt.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5wbGd4aHRoand3eXl3Ym52eHp0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQxOTIxNzEsImV4cCI6MjA3OTc2ODE3MX0.If32Moy6QhAHNXQfvbMLLfa0ssErIzV91qbeylJS8cg"

def main():
    print("Connecting to Supabase...")
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

    # Sample trading signals
    signals = [
        {
            "ticker": "AAPL",
            "signal_type": "VWAP_RECLAIM_LONG",
            "quality": "HIGH",
            "entry_price": 178.50,
            "stop_loss": 176.20,
            "take_profit_1": 182.30,
            "take_profit_2": 185.00,
            "current_price": 179.20,
            "vwap": 177.80,
            "ema_9": 178.90,
            "ema_20": 177.50,
            "volume": 85000000,
            "avg_volume": 60000000,
            "relative_volume": 1.42,
            "market_context": "Strong momentum above VWAP, breaking resistance at 178",
            "catalyst": "AAPL reclaiming VWAP with volume surge, tech sector strength",
            "timeframe": "5min",
            "ai_reasoning": "Price reclaimed VWAP at 177.80 with 142% relative volume. All EMAs aligned bullish. Market showing strength.",
            "confidence_score": 85,
            "risk_factors": ["Market volatility", "Resistance at 182"],
            "is_active": True
        },
        {
            "ticker": "NVDA",
            "signal_type": "ORB_BREAKOUT_LONG",
            "quality": "HIGH",
            "entry_price": 495.20,
            "stop_loss": 492.00,
            "take_profit_1": 502.00,
            "take_profit_2": 508.50,
            "current_price": 496.80,
            "vwap": 494.50,
            "ema_9": 495.00,
            "ema_20": 493.20,
            "volume": 42000000,
            "avg_volume": 28000000,
            "relative_volume": 1.50,
            "market_context": "Breaking opening range high with strong volume",
            "catalyst": "NVDA breaking ORB high, AI sector momentum continues",
            "timeframe": "5min",
            "ai_reasoning": "Clean ORB breakout with 150% relative volume. Price holding above VWAP and all EMAs trending up.",
            "confidence_score": 88,
            "risk_factors": ["Overbought RSI", "Gap fill risk"],
            "is_active": True
        },
        {
            "ticker": "TSLA",
            "signal_type": "EMA_TREND_CONTINUATION_LONG",
            "quality": "MEDIUM",
            "entry_price": 242.80,
            "stop_loss": 240.50,
            "take_profit_1": 247.20,
            "take_profit_2": 250.00,
            "current_price": 243.50,
            "vwap": 241.90,
            "ema_9": 242.60,
            "ema_20": 241.20,
            "volume": 95000000,
            "avg_volume": 75000000,
            "relative_volume": 1.27,
            "market_context": "Bouncing off EMA9 support, continuation setup",
            "catalyst": "TSLA holding EMA9, deliveries data positive sentiment",
            "timeframe": "5min",
            "ai_reasoning": "Price bouncing from EMA9 support. Volume confirms, but approaching resistance at 245.",
            "confidence_score": 72,
            "risk_factors": ["Choppy price action", "Resistance at 245"],
            "is_active": True
        },
        {
            "ticker": "SPY",
            "signal_type": "VWAP_RECLAIM_LONG",
            "quality": "MEDIUM",
            "entry_price": 450.80,
            "stop_loss": 449.20,
            "take_profit_1": 453.50,
            "take_profit_2": 455.00,
            "current_price": 451.40,
            "vwap": 450.30,
            "ema_9": 450.90,
            "ema_20": 449.80,
            "volume": 68000000,
            "avg_volume": 55000000,
            "relative_volume": 1.24,
            "market_context": "SPY reclaiming VWAP, market breadth improving",
            "catalyst": "Market-wide strength, SPY leading indices higher",
            "timeframe": "5min",
            "ai_reasoning": "SPY reclaimed VWAP with decent volume. Market internals improving but watch for overhead resistance.",
            "confidence_score": 75,
            "risk_factors": ["Fed news pending", "Resistance at 453"],
            "is_active": True
        },
        {
            "ticker": "BTC-USD",
            "signal_type": "VWAP_RECLAIM_LONG",
            "quality": "HIGH",
            "entry_price": 42500,
            "stop_loss": 42000,
            "take_profit_1": 43500,
            "take_profit_2": 44200,
            "current_price": 42780,
            "vwap": 42300,
            "ema_9": 42600,
            "ema_20": 42100,
            "volume": 28000,
            "avg_volume": 22000,
            "relative_volume": 1.27,
            "market_context": "Bitcoin breaking above VWAP resistance, crypto strength",
            "catalyst": "BTC reclaiming key level, ETF flows positive",
            "timeframe": "5min",
            "ai_reasoning": "BTC showing strength above VWAP. Volume confirms breakout, targeting 43.5K resistance.",
            "confidence_score": 82,
            "risk_factors": ["Crypto volatility", "Macro uncertainty"],
            "is_active": True
        }
    ]

    print(f"\nInserting {len(signals)} trading signals...")

    try:
        result = supabase.table("trading_signals").insert(signals).execute()
        print(f"✅ Successfully added {len(signals)} signals to database!")
        print("\nSignals added:")
        for signal in signals:
            print(f"  - {signal['ticker']}: {signal['signal_type']} ({signal['quality']})")

    except Exception as e:
        print(f"❌ Error adding signals: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
