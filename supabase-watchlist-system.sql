-- TradeFly Custom Watchlist System
-- Allows users to create multiple watchlists and track any ticker

-- 1. Watchlists table - Users can create multiple watchlists
CREATE TABLE IF NOT EXISTS watchlists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    is_default BOOLEAN DEFAULT false,
    icon TEXT, -- emoji or icon name
    color TEXT, -- hex color for UI
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Watchlist items - Tickers in each watchlist
CREATE TABLE IF NOT EXISTS watchlist_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    watchlist_id UUID NOT NULL REFERENCES watchlists(id) ON DELETE CASCADE,
    ticker TEXT NOT NULL,
    asset_type TEXT NOT NULL CHECK (asset_type IN ('stock', 'crypto')),
    notes TEXT, -- User's personal notes on this ticker
    alert_enabled BOOLEAN DEFAULT false,
    alert_price_above DECIMAL,
    alert_price_below DECIMAL,
    sort_order INTEGER DEFAULT 0,
    added_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(watchlist_id, ticker)
);

-- 3. Featured tickers - Curated list of popular tickers
CREATE TABLE IF NOT EXISTS featured_tickers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ticker TEXT NOT NULL UNIQUE,
    asset_type TEXT NOT NULL CHECK (asset_type IN ('stock', 'crypto')),
    name TEXT NOT NULL,
    description TEXT,
    category TEXT, -- 'tech', 'finance', 'crypto-major', 'meme', etc.
    market_cap TEXT, -- 'large', 'mid', 'small', 'micro'
    is_featured BOOLEAN DEFAULT true,
    popularity_score INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Ticker analytics cache - Store computed analytics
CREATE TABLE IF NOT EXISTS ticker_analytics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ticker TEXT NOT NULL,
    asset_type TEXT NOT NULL,

    -- Price data
    current_price DECIMAL,
    price_change_24h DECIMAL,
    price_change_percent_24h DECIMAL,
    volume_24h BIGINT,

    -- Technical indicators
    rsi_14 DECIMAL,
    macd DECIMAL,
    macd_signal DECIMAL,
    bollinger_upper DECIMAL,
    bollinger_lower DECIMAL,

    -- AI insights
    ai_sentiment TEXT, -- 'bullish', 'bearish', 'neutral'
    ai_confidence_score INTEGER,
    ai_analysis TEXT,
    ai_key_levels JSONB, -- Support/resistance levels

    -- Social metrics
    mentions_count INTEGER DEFAULT 0,
    sentiment_score DECIMAL,
    trending_score INTEGER DEFAULT 0,

    -- Metadata
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(ticker, asset_type)
);

-- 5. Trading tips - AI-generated educational tips
CREATE TABLE IF NOT EXISTS trading_tips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ticker TEXT, -- NULL for general tips
    asset_type TEXT,
    category TEXT NOT NULL, -- 'strategy', 'risk-management', 'indicators', 'psychology'
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    difficulty TEXT NOT NULL CHECK (difficulty IN ('beginner', 'intermediate', 'advanced')),
    ai_generated BOOLEAN DEFAULT true,
    likes_count INTEGER DEFAULT 0,
    views_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. User activity feed - StockTwits-like social feed
CREATE TABLE IF NOT EXISTS activity_feed (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    ticker TEXT NOT NULL,
    asset_type TEXT NOT NULL,
    activity_type TEXT NOT NULL, -- 'signal', 'entry', 'exit', 'watchlist_add', 'tip'
    content TEXT,
    sentiment TEXT, -- 'bullish', 'bearish', 'neutral'
    metadata JSONB, -- Additional data like prices, indicators, etc.
    likes_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. AI market insights - Daily/hourly insights
CREATE TABLE IF NOT EXISTS market_insights (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    insight_type TEXT NOT NULL, -- 'daily_summary', 'sector_rotation', 'opportunity', 'risk_alert'
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    affected_tickers TEXT[], -- Array of tickers related to this insight
    severity TEXT, -- 'info', 'warning', 'opportunity', 'alert'
    ai_confidence INTEGER,
    expires_at TIMESTAMPTZ, -- When this insight becomes stale
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_watchlists_user_id ON watchlists(user_id);
CREATE INDEX IF NOT EXISTS idx_watchlist_items_watchlist_id ON watchlist_items(watchlist_id);
CREATE INDEX IF NOT EXISTS idx_watchlist_items_ticker ON watchlist_items(ticker);
CREATE INDEX IF NOT EXISTS idx_featured_tickers_category ON featured_tickers(category);
CREATE INDEX IF NOT EXISTS idx_featured_tickers_asset_type ON featured_tickers(asset_type);
CREATE INDEX IF NOT EXISTS idx_ticker_analytics_ticker ON ticker_analytics(ticker);
CREATE INDEX IF NOT EXISTS idx_ticker_analytics_updated_at ON ticker_analytics(updated_at);
CREATE INDEX IF NOT EXISTS idx_trading_tips_category ON trading_tips(category);
CREATE INDEX IF NOT EXISTS idx_trading_tips_difficulty ON trading_tips(difficulty);
CREATE INDEX IF NOT EXISTS idx_activity_feed_ticker ON activity_feed(ticker);
CREATE INDEX IF NOT EXISTS idx_activity_feed_created_at ON activity_feed(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_market_insights_created_at ON market_insights(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_market_insights_expires_at ON market_insights(expires_at);

-- Row Level Security (RLS)
ALTER TABLE watchlists ENABLE ROW LEVEL SECURITY;
ALTER TABLE watchlist_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_feed ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view their own watchlists"
    ON watchlists FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own watchlists"
    ON watchlists FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own watchlists"
    ON watchlists FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own watchlists"
    ON watchlists FOR DELETE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can view their watchlist items"
    ON watchlist_items FOR SELECT
    USING (EXISTS (
        SELECT 1 FROM watchlists
        WHERE watchlists.id = watchlist_items.watchlist_id
        AND watchlists.user_id = auth.uid()
    ));

CREATE POLICY "Users can add items to their watchlists"
    ON watchlist_items FOR INSERT
    WITH CHECK (EXISTS (
        SELECT 1 FROM watchlists
        WHERE watchlists.id = watchlist_items.watchlist_id
        AND watchlists.user_id = auth.uid()
    ));

CREATE POLICY "Users can update their watchlist items"
    ON watchlist_items FOR UPDATE
    USING (EXISTS (
        SELECT 1 FROM watchlists
        WHERE watchlists.id = watchlist_items.watchlist_id
        AND watchlists.user_id = auth.uid()
    ));

CREATE POLICY "Users can delete their watchlist items"
    ON watchlist_items FOR DELETE
    USING (EXISTS (
        SELECT 1 FROM watchlists
        WHERE watchlists.id = watchlist_items.watchlist_id
        AND watchlists.user_id = auth.uid()
    ));

-- Activity feed - users can view all, but only modify their own
CREATE POLICY "Anyone can view activity feed"
    ON activity_feed FOR SELECT
    USING (true);

CREATE POLICY "Users can create their own activity"
    ON activity_feed FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own activity"
    ON activity_feed FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own activity"
    ON activity_feed FOR DELETE
    USING (auth.uid() = user_id);

-- Insert featured tickers (stocks)
INSERT INTO featured_tickers (ticker, asset_type, name, description, category, market_cap) VALUES
-- Tech Giants
('AAPL', 'stock', 'Apple Inc.', 'Consumer electronics and software', 'tech', 'large'),
('MSFT', 'stock', 'Microsoft', 'Software and cloud computing', 'tech', 'large'),
('GOOGL', 'stock', 'Alphabet (Google)', 'Search, advertising, cloud', 'tech', 'large'),
('AMZN', 'stock', 'Amazon', 'E-commerce and cloud computing', 'tech', 'large'),
('META', 'stock', 'Meta Platforms', 'Social media and VR', 'tech', 'large'),
('NVDA', 'stock', 'NVIDIA', 'Graphics chips and AI', 'tech', 'large'),
('TSLA', 'stock', 'Tesla', 'Electric vehicles and energy', 'tech', 'large'),
('AMD', 'stock', 'AMD', 'Semiconductors', 'tech', 'large'),

-- Finance
('JPM', 'stock', 'JPMorgan Chase', 'Banking and financial services', 'finance', 'large'),
('BAC', 'stock', 'Bank of America', 'Banking and financial services', 'finance', 'large'),
('GS', 'stock', 'Goldman Sachs', 'Investment banking', 'finance', 'large'),
('V', 'stock', 'Visa', 'Payment processing', 'finance', 'large'),
('MA', 'stock', 'Mastercard', 'Payment processing', 'finance', 'large'),

-- ETFs
('SPY', 'stock', 'S&P 500 ETF', 'Tracks S&P 500 index', 'etf', 'large'),
('QQQ', 'stock', 'Nasdaq 100 ETF', 'Tracks Nasdaq 100', 'etf', 'large'),
('IWM', 'stock', 'Russell 2000 ETF', 'Small-cap stocks', 'etf', 'large'),
('DIA', 'stock', 'Dow Jones ETF', 'Tracks Dow Jones', 'etf', 'large'),

-- Meme Stocks
('GME', 'stock', 'GameStop', 'Video game retailer', 'meme', 'mid'),
('AMC', 'stock', 'AMC Entertainment', 'Movie theater chain', 'meme', 'mid'),

-- Crypto
('BTC-USD', 'crypto', 'Bitcoin', 'Digital gold, store of value', 'crypto-major', 'large'),
('ETH-USD', 'crypto', 'Ethereum', 'Smart contracts platform', 'crypto-major', 'large'),
('SOL-USD', 'crypto', 'Solana', 'High-speed blockchain', 'crypto-major', 'large'),
('BNB-USD', 'crypto', 'Binance Coin', 'Exchange token', 'crypto-major', 'large'),
('XRP-USD', 'crypto', 'Ripple', 'Payment network', 'crypto-major', 'mid'),
('ADA-USD', 'crypto', 'Cardano', 'Proof of stake blockchain', 'crypto-major', 'mid'),
('AVAX-USD', 'crypto', 'Avalanche', 'DeFi platform', 'crypto-alt', 'mid'),
('DOT-USD', 'crypto', 'Polkadot', 'Multi-chain protocol', 'crypto-alt', 'mid'),
('MATIC-USD', 'crypto', 'Polygon', 'Ethereum scaling', 'crypto-alt', 'mid'),
('LINK-USD', 'crypto', 'Chainlink', 'Oracle network', 'crypto-alt', 'mid'),
('UNI-USD', 'crypto', 'Uniswap', 'DEX protocol', 'crypto-defi', 'mid'),
('DOGE-USD', 'crypto', 'Dogecoin', 'Meme cryptocurrency', 'crypto-meme', 'mid'),
('SHIB-USD', 'crypto', 'Shiba Inu', 'Meme cryptocurrency', 'crypto-meme', 'mid')
ON CONFLICT (ticker) DO NOTHING;
