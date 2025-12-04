#!/usr/bin/env python3
"""
Add signals using SERVICE KEY to bypass RLS
"""
import requests
import json
from datetime import datetime

# Supabase credentials - using SERVICE KEY
SUPABASE_URL = "https://nplgxhthjwwyywbnvxzt.supabase.co"
# This is the anon key - we need the service role key for this to work
# Get it from: https://app.supabase.com/project/nplgxhthjwwyywbnvxzt/settings/api
SERVICE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5wbGd4aHRoand3eXl3Ym52eHp0Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NDE5MjE3MSwiZXhwIjoyMDc5NzY4MTcxfQ.0aTEH7LhS5O3o7xh3W_cGhgWWlbzPRHEPRNWd7EMCgg"

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
        "market_context": "Strong momentum above VWAP",
        "catalyst": "AAPL reclaiming VWAP with volume",
        "timeframe": "5min",
        "ai_reasoning": "Price reclaimed VWAP with volume surge",
        "confidence_score": 85,
        "risk_factors": ["Market volatility"],
        "is_active": True
    },
    {
        "ticker": "NVDA",
        "signal_type": "ORB_BREAKOUT_LONG",
        "quality": "HIGH",
        "entry_price": 495.20,
        "stop_loss": 492.00,
        "take_profit_1": 502.00,
        "current_price": 496.80,
        "vwap": 494.50,
        "ema_9": 495.00,
        "ema_20": 493.20,
        "volume": 42000000,
        "avg_volume": 28000000,
        "relative_volume": 1.50,
        "market_context": "Breaking ORB high with volume",
        "catalyst": "NVDA AI sector momentum",
        "timeframe": "5min",
        "ai_reasoning": "Clean ORB breakout confirmed",
        "confidence_score": 88,
        "risk_factors": ["Overbought"],
        "is_active": True
    },
    {
        "ticker": "TSLA",
        "signal_type": "EMA_TREND_CONTINUATION_LONG",
        "quality": "MEDIUM",
        "entry_price": 242.80,
        "stop_loss": 240.50,
        "take_profit_1": 247.20,
        "current_price": 243.50,
        "vwap": 241.90,
        "ema_9": 242.60,
        "ema_20": 241.20,
        "volume": 95000000,
        "avg_volume": 75000000,
        "relative_volume": 1.27,
        "market_context": "Bouncing off EMA9 support",
        "catalyst": "TSLA deliveries positive",
        "timeframe": "5min",
        "ai_reasoning": "EMA9 bounce confirmed",
        "confidence_score": 72,
        "risk_factors": ["Resistance at 245"],
        "is_active": True
    }
]

headers = {
    "apikey": SERVICE_KEY,
    "Authorization": f"Bearer {SERVICE_KEY}",
    "Content-Type": "application/json",
    "Prefer": "return=representation"
}

url = f"{SUPABASE_URL}/rest/v1/trading_signals"

print("Adding signals with SERVICE KEY...")
response = requests.post(url, headers=headers, json=signals)

if response.status_code in [200, 201]:
    print(f"✅ SUCCESS! Added {len(signals)} signals")
    print("\nSignals added:")
    for signal in signals:
        print(f"  - {signal['ticker']}: {signal['signal_type']} ({signal['quality']})")
else:
    print(f"❌ FAILED: {response.status_code}")
    print(f"Error: {response.text}")
