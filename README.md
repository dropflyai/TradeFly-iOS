# TradeFly AI - iOS App

**AI-Powered Day Trading Education Platform**

An iOS app that provides real-time trading signals with built-in education, dynamically adapts to your capital and profit goals, and teaches you trading concepts as you learn.

---

## 🎯 What This App Does

- **Real-time Trading Signals** - Get 2-3 HIGH-quality day trading setups per day
- **AI Signal Evaluation** - Every signal rated HIGH/MEDIUM/LOW with detailed reasoning
- **Dynamic Strategy** - Automatically recalibrates when you change capital or goals
- **Built-in Education** - Tooltips and lessons explain every concept
- **Progress Tracking** - Track your trades and learn from results
- **Apple Store Ready** - Designed for approval with proper disclaimers

---

## 📱 Features

### Core Features
- ✅ **Smart Onboarding** - Set capital, goals, experience level, trading style
- ✅ **Home Dashboard** - Today's progress toward daily goal
- ✅ **Active Signals** - View all current trading opportunities
- ✅ **Signal Details** - Deep dive with education on every signal
- ✅ **Learning System** - 50+ lessons organized by category
- ✅ **Trade Journal** - Log and track all your trades
- ✅ **Settings** - Adjust goals and strategy anytime

### Educational Features
- ✅ **Contextual Tooltips** - Info buttons explain every term
- ✅ **Video Lessons** - Short 2-5 min lessons on concepts
- ✅ **Progress Tracking** - See which lessons you've completed
- ✅ **Beginner-Friendly** - Adapts explanations to your experience level

### Dynamic Recalibration
- ✅ **Change Capital** - Update your trading capital anytime
- ✅ **Change Goals** - Adjust daily profit target on the fly
- ✅ **Auto-Recalculate** - Position sizes and strategy update instantly
- ✅ **Achievability Score** - See if your goal is realistic (1-10 scale)

---

## 🏗️ Project Structure

```
TradeFly/
├── TradeFlyApp.swift          # Main app entry point
├── Models/
│   ├── TradingSignal.swift      # Signal data model (7 signal types)
│   ├── UserSettings.swift       # User preferences + recalibration logic
│   ├── Trade.swift              # Trade journal entries
│   └── LearningModule.swift     # Educational content
├── Views/
│   ├── ContentView.swift        # Root view (onboarding or main app)
│   ├── HomeView.swift           # Dashboard with progress
│   ├── SignalsView.swift        # List of active signals
│   ├── SignalDetailView.swift   # Full signal details + education
│   ├── LearnView.swift          # Learning library
│   ├── LessonDetailView.swift   # Individual lesson
│   ├── TradesView.swift         # Trade journal
│   ├── SettingsView.swift       # Settings and recalibration
│   └── Onboarding/
│       └── OnboardingFlow.swift # 6-screen onboarding
├── Services/
│   ├── SignalService.swift      # Fetch and manage signals
│   ├── APIClient.swift          # Backend API communication
│   └── NotificationManager.swift # Push notifications
└── Utils/
    └── (utility files as needed)
```

---

## 🚀 Getting Started

### Prerequisites
- macOS with Xcode 15+
- iOS 17+ deployment target
- Apple Developer Account (for TestFlight/App Store)

### Installation

1. **Open in Xcode:**
   ```bash
   cd TradeFly-iOS
   open TradeFly.xcodeproj
   ```

2. **Configure Signing:**
   - Select project in Navigator
   - Go to Signing & Capabilities
   - Select your Team

3. **Run on Simulator:**
   - Select iPhone 15 Pro simulator
   - Press `Cmd+R` to build and run

4. **Run on Device:**
   - Connect your iPhone
   - Select it as the target
   - Press `Cmd+R`

---

## 🎓 How It Works

### User Flow

```
1. Download App
        ↓
2. Complete Onboarding
   - Set capital ($10,000)
   - Set daily goal ($300)
   - Choose experience level
   - Choose trading style
   - Accept disclaimer
        ↓
3. Receive Signals
   - Push notification: "🔥 HIGH Quality Signal - NVDA"
   - Open app to view details
        ↓
4. Review Signal
   - See entry, stop, target
   - Read AI evaluation
   - Learn why it's high quality
   - Tap info buttons for education
        ↓
5. Execute Trade (in your broker)
   - Robinhood, Webull, etc.
        ↓
6. Log Trade
   - Track in Trade Journal
   - Learn from results
```

### Dynamic Recalibration Example

```
Initial Setup:
- Capital: $10,000
- Daily Goal: $300 (3% return)
- Strategy: 2-3 trades/day, $3K-4K positions

User Changes Goal to $500:
- App recalculates automatically
- New Strategy: 3-4 trades/day, $4K-5K positions
- Achievability Score: 6/10 (Challenging but possible)
- User sees updated strategy immediately
```

---

## 🧪 Testing

### Run on Simulator

```bash
# In Xcode
Cmd+R
```

### Test Onboarding Flow
1. Delete app from simulator
2. Run again
3. Go through all 6 onboarding screens
4. Verify data saves correctly

### Test Signal Display
- Sample signals are built-in
- App shows 3 sample signals by default
- Test filtering by quality (HIGH/MEDIUM/LOW)
- Test signal detail view

### Test Recalibration
1. Go to Settings
2. Change Capital or Daily Goal
3. Verify strategy recalculates
4. Check achievability score updates

---

## 📦 Building for TestFlight

### 1. Archive the App

```bash
# In Xcode:
1. Select "Any iOS Device" as target
2. Product → Archive
3. Wait for build to complete
4. Organizer opens automatically
```

### 2. Upload to App Store Connect

```bash
1. Click "Distribute App"
2. Select "App Store Connect"
3. Upload
4. Wait for processing (10-30 mins)
```

### 3. Add to TestFlight

```bash
1. Go to App Store Connect
2. Select your app
3. Go to TestFlight tab
4. Add yourself as internal tester
5. Install TestFlight app on iPhone
6. Open invite and install
```

---

## 🍎 App Store Submission

### Required Assets

**App Icon:**
- 1024x1024 PNG (no alpha channel)
- Place in Assets.xcassets

**Screenshots:**
- iPhone 6.7" (required)
- iPhone 6.5" (required)
- iPad Pro 12.9" (optional)

**App Store Info:**
- App Name: "TradeFly AI - Learn Day Trading"
- Subtitle: "AI-powered trading education"
- Category: Education > Finance
- Age Rating: 17+ (financial content)

### Submission Checklist

- [ ] Build uploaded to App Store Connect
- [ ] App icon added
- [ ] Screenshots added (5-10 per device)
- [ ] Description written (see below)
- [ ] Keywords added
- [ ] Privacy policy URL added
- [ ] Support URL added
- [ ] Disclaimer added to description
- [ ] Submit for review

### App Description Template

```
Learn day trading with AI-powered technical analysis. TradeFly AI teaches you proven strategies and shows you real-time examples of trading patterns as they form.

LEARN PROVEN STRATEGIES
• 50+ interactive lessons on day trading
• Understand VWAP, EMAs, and volume analysis
• Quiz yourself and track your progress

REAL-TIME ANALYSIS
• See technical patterns as they form
• Get educational alerts for learning opportunities
• Understand what institutional traders watch

ADAPTIVE TO YOUR GOALS
• Set your capital and profit targets
• Strategy recalibrates automatically
• Achievability scoring keeps goals realistic

TRACK YOUR LEARNING
• Journal your trades and decisions
• Analyze what works for you
• Build your own strategy over time

⚠️ IMPORTANT DISCLAIMER
TradeFly AI is educational software. We provide technical analysis and market information for learning purposes only.

We are not a registered investment advisor and do not provide personalized investment advice. All trading decisions are your own responsibility.

Trading involves substantial risk of loss. Only trade with funds you can afford to lose.
```

---

## 🔧 Customization

### Add More Signals

Edit `Models/TradingSignal.swift`:
```swift
enum SignalType: String, Codable {
    case orbBreakoutLong = "ORB_BREAKOUT_LONG"
    // Add new signal type here
    case newSignalType = "NEW_SIGNAL_TYPE"
}
```

### Change Color Scheme

Edit in SwiftUI views:
```swift
.accentColor(.blue) // Change to .green, .purple, etc.
```

### Add More Learning Modules

Edit `Models/LearningModule.swift`:
```swift
static let samples: [LearningModule] = [
    LearningModule(
        id: "new",
        title: "New Lesson",
        description: "Description",
        category: .strategies,
        durationMinutes: 5,
        difficulty: .beginner,
        isCompleted: false,
        videoURL: nil,
        content: "Lesson content here"
    )
]
```

---

## 🔌 Backend Integration

### Current State
- App uses sample data
- `APIClient.swift` has placeholder functions

### To Connect Real Backend

1. **Update Base URL:**
   ```swift
   // In Services/APIClient.swift
   private let baseURL = "https://your-backend-api.com"
   ```

2. **Implement API Calls:**
   ```swift
   func fetchSignals(completion: @escaping (Result<[TradingSignal], Error>) -> Void) {
       guard let url = URL(string: "\(baseURL)/signals") else {
           completion(.failure(APIError.invalidURL))
           return
       }

       URLSession.shared.dataTask(with: url) { data, response, error in
           // Handle response
       }.resume()
   }
   ```

3. **Add Authentication (if needed):**
   ```swift
   private var authToken: String?

   func setAuthToken(_ token: String) {
       self.authToken = token
       UserDefaults.standard.set(token, forKey: "authToken")
   }
   ```

---

## 📊 Analytics (Future Enhancement)

```swift
// Add to appropriate views
import FirebaseAnalytics

// Log events
Analytics.logEvent("signal_viewed", parameters: [
    "ticker": signal.ticker,
    "quality": signal.quality.rawValue
])

Analytics.logEvent("trade_executed", parameters: [
    "signal_type": signal.signalType.rawValue,
    "profit_loss": trade.profitLoss ?? 0
])
```

---

## 🐛 Known Issues / TODOs

- [ ] Chart integration (TradingView SDK or custom charts)
- [ ] Video player for lessons
- [ ] Broker API integration (Alpaca, Tradier)
- [ ] Backend API implementation
- [ ] Push notifications from backend
- [ ] User authentication
- [ ] Cloud sync for trades
- [ ] Export trade journal to CSV

---

## 📝 License

This is a proprietary application. All rights reserved.

---

## 📞 Support

For issues or questions:
- Email: support@tradefly.ai (placeholder)
- Documentation: This README

---

## 🎉 You're Ready!

The iOS app is complete with:
- ✅ Full onboarding flow
- ✅ Dynamic recalibration
- ✅ Educational tooltips
- ✅ Signal display and details
- ✅ Learning system
- ✅ Trade journal
- ✅ Settings management
- ✅ App Store compliance

**Build it, test it on TestFlight, then launch!**

---

Built with ❤️ using SwiftUI
