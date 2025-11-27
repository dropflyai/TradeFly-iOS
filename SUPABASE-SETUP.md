# Supabase Setup Guide - TradeFly AI

Complete guide to setting up Supabase backend for live data.

---

## Step 1: Create Supabase Project (5 minutes)

### 1.1 Sign Up for Supabase
1. Go to https://supabase.com
2. Click "Start your project"
3. Sign in with GitHub (recommended)

### 1.2 Create New Project
1. Click "New Project"
2. Choose your organization (or create one)
3. Project name: **TradeFly-AI**
4. Database password: **Generate a strong password and save it**
5. Region: Choose closest to you (e.g., US West)
6. Click "Create new project"
7. Wait 2-3 minutes for provisioning

---

## Step 2: Set Up Database Schema (3 minutes)

### 2.1 Open SQL Editor
1. In your Supabase dashboard, click **SQL Editor** in the left sidebar
2. Click "+ New query"

### 2.2 Run the Schema
1. Open the file: `supabase-schema.sql`
2. Copy ALL the contents
3. Paste into the SQL Editor
4. Click **Run** (or press Cmd+Enter)
5. You should see "Success. No rows returned"

### 2.3 Verify Tables Created
1. Click **Table Editor** in left sidebar
2. You should see these tables:
   - `user_profiles`
   - `trading_signals`
   - `trades`
   - `learning_progress`

---

## Step 3: Get API Credentials (2 minutes)

### 3.1 Find Your Credentials
1. Click **Settings** (gear icon) in left sidebar
2. Click **API** under "Project Settings"
3. You'll see two important values:

   **Project URL:**
   ```
   https://xxxxxxxxxxxxx.supabase.co
   ```

   **anon public key:**
   ```
   eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6...
   ```

### 3.2 Copy These Values
Keep these handy - you'll need them in the next step.

---

## Step 4: Configure iOS App (5 minutes)

### 4.1 Open Xcode Project
If you haven't created the Xcode project yet:
1. Open Xcode
2. File → New → Project
3. Choose "iOS App"
4. Product Name: **TradeFly**
5. Interface: **SwiftUI**
6. Language: **Swift**
7. Save to: `/Users/rioallen/Documents/DropFly-OS-App-Builder/DropFly-PROJECTS/TradeFly-iOS`

### 4.2 Add Swift Files to Project
1. In Xcode, right-click on "TradeFly" folder
2. Add Files to "TradeFly"
3. Select ALL the Swift files from the `TradeFly` folder
4. Make sure "Copy items if needed" is checked
5. Click "Add"

### 4.3 Add Supabase Swift Package
1. In Xcode, click **File → Add Package Dependencies**
2. Enter this URL:
   ```
   https://github.com/supabase/supabase-swift
   ```
3. Click "Add Package"
4. Select these products:
   - ✅ Supabase
   - ✅ Realtime
   - ✅ PostgREST
   - ✅ Auth
5. Click "Add Package"

### 4.4 Add Your Credentials
1. Open `TradeFly/Config/SupabaseConfig.swift`
2. Replace `YOUR_SUPABASE_PROJECT_URL` with your Project URL
3. Replace `YOUR_SUPABASE_ANON_KEY` with your anon key

**Example:**
```swift
struct SupabaseConfig {
    static let url = "https://abcdefgh.supabase.co"
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### 4.5 Update SupabaseService
1. Open `TradeFly/Services/SupabaseService.swift`
2. Find lines 14-15:
   ```swift
   private let supabaseURL = URL(string: "YOUR_SUPABASE_URL")!
   private let supabaseKey = "YOUR_SUPABASE_ANON_KEY"
   ```
3. Replace with:
   ```swift
   private let supabaseURL = URL(string: SupabaseConfig.url)!
   private let supabaseKey = SupabaseConfig.anonKey
   ```

### 4.6 Enable Supabase in SignalService
1. Open `TradeFly/Services/SignalService.swift`
2. Find line 17:
   ```swift
   private var useSupabase = false
   ```
3. Change to:
   ```swift
   private var useSupabase = true
   ```

---

## Step 5: Update App Entry Point (2 minutes)

### 5.1 Update TradeFlyApp.swift
We need to show the AuthView if user is not logged in.

Open `TradeFly/TradeFlyApp.swift` and update it to handle authentication:

```swift
import SwiftUI

@main
struct TradeFlyApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var signalService = SignalService()
    @StateObject private var userSettings = UserSettings()
    @StateObject private var supabase = SupabaseService.shared

    var body: some Scene {
        WindowGroup {
            if !supabase.isAuthenticated {
                // Show auth screen if not logged in
                AuthView()
            } else if !appState.hasCompletedOnboarding {
                // Show onboarding if first time
                OnboardingFlow(onComplete: {
                    appState.hasCompletedOnboarding = true
                })
                .environmentObject(userSettings)
            } else {
                // Show main app
                ContentView()
                    .environmentObject(appState)
                    .environmentObject(signalService)
                    .environmentObject(userSettings)
            }
        }
    }
}
```

---

## Step 6: Test It! (5 minutes)

### 6.1 Build and Run
1. Select iPhone 15 Pro simulator
2. Press **Cmd+R** to build and run
3. App should launch and show the AuthView

### 6.2 Create an Account
1. Enter an email (can be fake for testing): `test@test.com`
2. Enter a password (at least 6 characters): `password123`
3. Click "Create Account"
4. You should be signed up and logged in automatically

### 6.3 Verify in Supabase
1. Go to Supabase dashboard
2. Click **Authentication** in sidebar
3. You should see your test user listed
4. Click **Table Editor → user_profiles**
5. You should see a profile created for your user

### 6.4 Add a Test Signal
1. In Supabase, click **Table Editor → trading_signals**
2. You should see 1 sample signal already (NVDA)
3. The app should fetch and display it automatically

---

## Step 7: Add More Test Signals (Optional)

To test the real-time functionality, add signals directly in Supabase:

1. Click **Table Editor → trading_signals**
2. Click "Insert row"
3. Fill in the fields:
   - ticker: `TSLA`
   - signal_type: `VWAP_RECLAIM_LONG`
   - quality: `HIGH`
   - entry_price: `242.50`
   - stop_loss: `240.00`
   - take_profit_1: `246.00`
   - current_price: `243.20`
   - timeframe: `5-minute`
   - ai_reasoning: `Strong bounce off VWAP with heavy volume`
   - confidence_score: `82`
   - is_active: `true` ✅
4. Click "Save"

The app should receive this signal in real-time!

---

## Step 8: Enable Push Notifications (Optional, 10 minutes)

### 8.1 Enable Capability in Xcode
1. Select your project in Xcode
2. Go to "Signing & Capabilities"
3. Click "+ Capability"
4. Add "Push Notifications"

### 8.2 Request Permission
The app already has this code in `NotificationManager.swift`. It will ask for permission on first launch.

---

## Troubleshooting

### Build Error: "Cannot find 'Supabase' in scope"
**Solution:** Make sure you added the Supabase Swift package correctly. Go to File → Add Package Dependencies and add it again.

### Error: "Invalid JWT"
**Solution:** Double-check that you copied the correct anon key from Supabase Settings → API.

### Error: "Failed to fetch signals"
**Solution:**
1. Check that you ran the SQL schema in Supabase
2. Verify the `trading_signals` table exists
3. Make sure `is_active = true` for at least one signal

### No signals showing up
**Solution:**
1. Check that `useSupabase = true` in SignalService
2. Verify you have at least one signal with `is_active = true` in the database
3. Check Xcode console for errors

### App crashes on launch
**Solution:**
1. Check that all `@EnvironmentObject` dependencies are provided in TradeFlyApp.swift
2. Make sure all Swift files are added to the Xcode target
3. Clean build folder: Product → Clean Build Folder

---

## Next Steps

Now that your backend is live:

1. **Test the full flow:**
   - Sign up a user
   - Complete onboarding
   - View signals
   - Log a trade

2. **Build a signal generator:**
   - Create a Python script to detect real signals
   - Insert them into Supabase
   - App will receive them in real-time

3. **Deploy to TestFlight:**
   - Archive the app
   - Upload to App Store Connect
   - Invite beta testers

---

## Security Notes

- The **anon key** is safe to use in your app (it's public)
- Row Level Security (RLS) protects user data
- Users can only see/edit their own trades and profile
- All users can see active signals (read-only)

---

## Cost Estimate

Supabase Pricing:
- **Free tier:** Up to 500MB database, 2GB bandwidth/month
- Perfect for testing and early users
- **Pro tier:** $25/month for unlimited projects (upgrade when needed)

---

You're all set! Your TradeFly app now has:
- ✅ User authentication
- ✅ Real-time signal updates
- ✅ Persistent trade journal
- ✅ Cloud-synced user settings
- ✅ Learning progress tracking

🚀 Build and test with live data!
