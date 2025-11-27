-- TradeFly AI Database Schema
-- Execute this in your Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table (extends Supabase auth.users)
CREATE TABLE public.user_profiles (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    capital DECIMAL(12,2) NOT NULL DEFAULT 10000,
    daily_profit_goal DECIMAL(10,2) NOT NULL DEFAULT 300,
    experience_level TEXT NOT NULL DEFAULT 'beginner',
    trading_style TEXT NOT NULL DEFAULT 'scalper',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Trading Signals table
CREATE TABLE public.trading_signals (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    ticker TEXT NOT NULL,
    signal_type TEXT NOT NULL,
    quality TEXT NOT NULL CHECK (quality IN ('HIGH', 'MEDIUM', 'LOW')),

    -- Price data
    entry_price DECIMAL(10,2) NOT NULL,
    stop_loss DECIMAL(10,2) NOT NULL,
    take_profit_1 DECIMAL(10,2) NOT NULL,
    take_profit_2 DECIMAL(10,2),
    take_profit_3 DECIMAL(10,2),
    current_price DECIMAL(10,2) NOT NULL,

    -- Indicators
    vwap DECIMAL(10,2),
    ema_9 DECIMAL(10,2),
    ema_20 DECIMAL(10,2),
    volume INTEGER,
    avg_volume INTEGER,
    relative_volume DECIMAL(5,2),

    -- Context
    market_context TEXT,
    catalyst TEXT,
    timeframe TEXT NOT NULL,

    -- AI Analysis
    ai_reasoning TEXT NOT NULL,
    confidence_score INTEGER CHECK (confidence_score BETWEEN 1 AND 100),
    risk_factors TEXT[],

    -- Metadata
    is_active BOOLEAN DEFAULT TRUE,
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Trades table (user's trade journal)
CREATE TABLE public.trades (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    signal_id UUID REFERENCES public.trading_signals(id),

    -- Trade details
    ticker TEXT NOT NULL,
    signal_type TEXT NOT NULL,
    entry_price DECIMAL(10,2) NOT NULL,
    exit_price DECIMAL(10,2),
    shares INTEGER NOT NULL,

    -- Results
    profit_loss DECIMAL(10,2),
    profit_loss_percentage DECIMAL(5,2),

    -- Status
    is_open BOOLEAN DEFAULT TRUE,
    opened_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    closed_at TIMESTAMP WITH TIME ZONE,

    -- Notes
    notes TEXT
);

-- Learning progress table
CREATE TABLE public.learning_progress (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    module_id TEXT NOT NULL,
    completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP WITH TIME ZONE,

    UNIQUE(user_id, module_id)
);

-- Create Indexes for Performance
CREATE INDEX idx_signals_ticker ON public.trading_signals(ticker);
CREATE INDEX idx_signals_quality ON public.trading_signals(quality);
CREATE INDEX idx_signals_active ON public.trading_signals(is_active);
CREATE INDEX idx_signals_created ON public.trading_signals(created_at DESC);

CREATE INDEX idx_trades_user ON public.trades(user_id, opened_at DESC);
CREATE INDEX idx_trades_open ON public.trades(user_id, is_open);

-- Row Level Security (RLS) Policies

-- Enable RLS on all tables
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trading_signals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trades ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.learning_progress ENABLE ROW LEVEL SECURITY;

-- User Profiles: Users can only read/update their own profile
CREATE POLICY "Users can view own profile" ON public.user_profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.user_profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.user_profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Trading Signals: All authenticated users can read active signals
CREATE POLICY "Authenticated users can view active signals" ON public.trading_signals
    FOR SELECT USING (is_active = TRUE AND auth.role() = 'authenticated');

-- Trades: Users can only access their own trades
CREATE POLICY "Users can view own trades" ON public.trades
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own trades" ON public.trades
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own trades" ON public.trades
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own trades" ON public.trades
    FOR DELETE USING (auth.uid() = user_id);

-- Learning Progress: Users can only access their own progress
CREATE POLICY "Users can view own learning progress" ON public.learning_progress
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own learning progress" ON public.learning_progress
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own learning progress" ON public.learning_progress
    FOR UPDATE USING (auth.uid() = user_id);

-- Functions

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for user_profiles
CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to expire old signals automatically
CREATE OR REPLACE FUNCTION expire_old_signals()
RETURNS void AS $$
BEGIN
    UPDATE public.trading_signals
    SET is_active = FALSE
    WHERE expires_at < NOW() AND is_active = TRUE;
END;
$$ LANGUAGE plpgsql;

-- Sample data for testing
INSERT INTO public.trading_signals (
    ticker, signal_type, quality,
    entry_price, stop_loss, take_profit_1, take_profit_2, current_price,
    vwap, ema_9, ema_20, volume, avg_volume, relative_volume,
    market_context, catalyst, timeframe,
    ai_reasoning, confidence_score, risk_factors,
    expires_at
) VALUES (
    'NVDA',
    'ORB_BREAKOUT_LONG',
    'HIGH',
    475.20, 473.50, 478.00, 480.50, 475.80,
    474.30, 475.10, 473.80, 5200000, 3800000, 1.37,
    'Strong uptrend, holding above VWAP',
    'AI chip demand surge, positive analyst upgrade',
    '5-minute',
    'This signal shows strong institutional buying with volume 37% above average. Price is holding above all key EMAs and VWAP, indicating bullish momentum. The opening range breakout at $475.20 aligns with the previous resistance level.',
    87,
    ARRAY['Market-wide selloff could invalidate setup', 'Earnings in 2 weeks'],
    NOW() + INTERVAL '4 hours'
);

-- Grant permissions
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;
