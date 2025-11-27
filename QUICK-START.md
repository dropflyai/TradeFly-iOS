# Quick Start - Get TradeFly Running with Live Data

**Time:** 15 minutes total

---

## What You'll Do

1. Create Supabase project (cloud database)
2. Set up database tables
3. Create Xcode project
4. Add Supabase credentials
5. Run and test with live data

---

## Step 1: Supabase (5 minutes)

### Create Project
1. Go to https://supabase.com
2. Sign in with GitHub
3. Click "New Project"
4. Name: **TradeFly-AI**
5. Generate strong password (save it)
6. Click "Create"

### Run Database Schema
1. Click **SQL Editor** in left sidebar
2. Click "+ New query"
3. Open file: `supabase-schema.sql` in this folder
4. Copy ALL contents, paste in SQL Editor
5. Click **Run**
6. Should say "Success"

### Get API Keys
1. Click **Settings** (gear icon)
2. Click **API**
3. Copy these two values:
   - **Project URL**: `https://xxxx.supabase.co`
   - **anon public key**: `eyJhbGc...` (long key)

---

## Step 2: Xcode Project (3 minutes)

### Create Project
1. Open Xcode
2. File → New → Project → iOS App
3. Name: **TradeFly**
4. Interface: **SwiftUI**, Language: **Swift**
5. Save to this folder
6. Drag all `.swift` files from `TradeFly/` into project

### Add Supabase Package
1. File → Add Package Dependencies
2. URL: `https://github.com/supabase/supabase-swift`
3. Click "Add Package"
4. Select: Supabase, Realtime, PostgREST, Auth
5. Click "Add Package"

---

## Step 3: Configure (2 minutes)

### Add Your Credentials
1. Open: `TradeFly/Config/SupabaseConfig.swift`
2. Replace:
   ```swift
   static let url = "YOUR_SUPABASE_PROJECT_URL"
   static let anonKey = "YOUR_SUPABASE_ANON_KEY"
   ```
   With your actual values from Step 1

3. Open: `TradeFly/Services/SupabaseService.swift`
4. Lines 14-15, change to:
   ```swift
   private let supabaseURL = URL(string: SupabaseConfig.url)!
   private let supabaseKey = SupabaseConfig.anonKey
   ```

### Enable Live Data
1. Open: `TradeFly/Services/SignalService.swift`
2. Line 17, change to:
   ```swift
   private var useSupabase = true
   ```

---

## Step 4: Run It! (2 minutes)

### Build and Run
1. Select iPhone 15 Pro simulator
2. Press **Cmd+R**
3. Should show AuthView (login screen)

### Create Account
1. Email: `test@test.com`
2. Password: `password123`
3. Click "Create Account"
4. Should log in and show onboarding

### Complete Onboarding
1. Set capital: $10,000
2. Set goal: $300/day
3. Choose experience level
4. Choose trading style
5. Accept disclaimer
6. Should land on home screen

### Verify Live Data
1. You should see 1 sample signal (NVDA)
2. This came from your Supabase database!
3. Click on it to see full details

---

## Step 5: Test Real-Time (3 minutes)

### Add a Signal in Supabase
1. Go to Supabase dashboard
2. Click **Table Editor → trading_signals**
3. Click "Insert row"
4. Fill in:
   - ticker: `TSLA`
   - signal_type: `ORB_BREAKOUT_LONG`
   - quality: `HIGH`
   - entry_price: `242.50`
   - stop_loss: `240.00`
   - take_profit_1: `246.00`
   - current_price: `243.20`
   - timeframe: `5-minute`
   - ai_reasoning: `Strong breakout with volume`
   - confidence_score: `85`
   - is_active: ✅ true
5. Click "Save"

### Watch It Appear in App
Within 30 seconds, the new TSLA signal should appear in your app automatically! 🎉

---

## You're Live!

Your app now:
- ✅ Authenticates users
- ✅ Fetches real signals from Supabase
- ✅ Updates in real-time
- ✅ Stores trades in cloud
- ✅ Syncs user settings

**Next:** Build a Python script to generate real trading signals and insert them into Supabase.

---

## Troubleshooting

**Can't find Supabase package?**
→ File → Add Package Dependencies → Re-add the package

**"Invalid JWT" error?**
→ Double-check you copied the anon key correctly

**No signals showing?**
→ Verify `is_active = true` in the trading_signals table

**Full guide:** See `SUPABASE-SETUP.md` for detailed instructions

---

🚀 You're ready to test with live data!
