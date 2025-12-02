# TradeFly - App Store Connect Setup Guide

## 📋 App Information

### Basic Info
- **App Name**: TradeFly AI
- **Bundle ID**: `com.tradefly.TradeFly`
- **SKU**: `tradefly-ios-001`
- **Primary Language**: English (U.S.)
- **Category**: Finance
- **Secondary Category**: Education

### App Description

**Subtitle (30 chars max):**
Learn Day Trading with AI

**Promotional Text (170 chars max):**
Master day trading with AI-powered signals. Get real-time alerts for high-quality setups with detailed analysis, entry/exit points, and educational content.

**Description:**
TradeFly AI is your intelligent day trading companion that helps you learn and execute profitable trades with confidence.

🎯 **What You Get:**
• Real-time AI-powered trading signals
• High, Medium, and Low quality ratings for every setup
• Clear entry, stop loss, and target prices
• Educational content explaining each signal
• Risk management guidance
• Trade journal to track your progress

📊 **Smart Signal Detection:**
Our AI analyzes:
- VWAP (Volume Weighted Average Price)
- EMA trends (9, 20, 50 periods)
- Volume patterns and breakouts
- Opening Range Breakouts (ORB)
- High of Day (HOD) / Low of Day (LOD) levels

🧠 **Learn While You Trade:**
TradeFly doesn't just give you signals - it teaches you WHY each setup works:
- Detailed explanations of technical indicators
- Risk factors for each trade
- Historical performance data
- Video lessons on trading concepts

💰 **Position Sizing Calculator:**
Based on your capital and risk tolerance, TradeFly calculates:
- Optimal position sizes
- Recommended trades per day
- Daily profit targets
- Achievability scores

🔔 **Smart Notifications:**
Get instant alerts for high-quality setups during market hours (9:30 AM - 4:00 PM ET)

📈 **Track Your Progress:**
- Trade journal with profit/loss tracking
- Win rate statistics
- Performance analytics
- Learning progress

⚠️ **Important Disclaimer:**
TradeFly is educational software designed to help you learn day trading concepts and strategies. This is NOT investment advice. All trading involves risk. Never trade with money you cannot afford to lose. Past performance does not guarantee future results.

**What's New in Version 1.0:**
- Initial release
- AI-powered signal detection
- Real-time market data integration
- Educational content library
- Trade journaling

### Keywords (100 chars max, comma-separated)
day trading,stock trading,AI trading,trading signals,stock alerts,options trading,learn trading,VWAP,technical analysis,day trader

### Support URL
https://tradefly.ai/support

### Marketing URL
https://tradefly.ai

### Privacy Policy URL
https://tradefly.ai/privacy

---

## 📱 App Preview Requirements

### iPhone Screenshots (6.7" display - iPhone 15 Pro Max)
**Required: 3-10 screenshots**

Recommended screenshots:
1. **Signal List View** - Show active HIGH quality signals
2. **Signal Detail** - Detailed analysis with entry/target/stop
3. **Chart View** - TradingView chart with indicators
4. **Learning Module** - Educational content screen
5. **Trade Journal** - Performance tracking
6. **Onboarding** - Capital and goal setting

### iPad Screenshots (12.9" display - iPad Pro)
**Optional but recommended**

---

## 🎬 App Preview Video (Optional)
- **Length**: 15-30 seconds
- **Orientation**: Portrait
- **Show**: Signal appearing → Detail view → Educational content
- **No audio required** (subtitles recommended)

---

## 📝 App Review Information

### Contact Information
- **First Name**: Rio
- **Last Name**: Allen
- **Phone Number**: [Your phone]
- **Email**: [Your email]

### Demo Account (for App Review)
**Username**: demo@tradefly.ai
**Password**: DemoAccount2024!

**Notes for Reviewer:**
"TradeFly AI is an educational day trading platform. The app shows real-time trading signals analyzed by AI during market hours (9:30 AM - 4:00 PM ET Monday-Friday).

For review purposes:
1. Use the demo account provided above
2. Signals will only appear during market hours
3. Sample signals are shown in the app for demonstration
4. All trading signals are for educational purposes only

The app does NOT execute trades - it only provides educational analysis and signals. Users must execute trades through their own brokerage accounts."

---

## 💰 Pricing

### App Price Tier
**Free** (with optional future in-app purchases)

### Future In-App Purchase Ideas
- Premium signals (real-time vs 15-min delay)
- Advanced analytics
- Unlimited trade journal entries
- Priority support

---

## 🔐 App Privacy

### Data Collection
**Account Information:**
- Email address (for authentication)
- Name (optional)

**Usage Data:**
- App interactions
- Signal views
- Trading preferences

**Not Collected:**
- Financial information
- Precise location
- Browsing history

### Data Use
- **Account Info**: User authentication, app functionality
- **Usage Data**: App analytics, improve user experience

### Privacy Policy
Must create and host at: https://tradefly.ai/privacy

---

## 📅 Release Strategy

### Version 1.0 (TestFlight Beta)
1. Upload build to App Store Connect
2. Add to TestFlight
3. Invite beta testers (up to 10,000 via public link)
4. Collect feedback for 1-2 weeks
5. Fix any bugs
6. Submit for App Store review

### Version 1.0.1 (App Store Release)
- Based on TestFlight feedback
- Full App Store release
- Marketing campaign

---

## ✅ Pre-Submission Checklist

### Required Assets
- [ ] App Icon (1024x1024px)
- [ ] iPhone 6.7" screenshots (3-10)
- [ ] iPad 12.9" screenshots (optional)
- [ ] Privacy Policy hosted online
- [ ] Support URL working
- [ ] Demo account created

### App Store Connect Setup
- [ ] Create app record in App Store Connect
- [ ] Fill in app description
- [ ] Add keywords
- [ ] Set pricing (Free)
- [ ] Configure privacy settings
- [ ] Add screenshots
- [ ] Submit for review

### Build Upload
- [ ] Archive app in Xcode
- [ ] Upload to App Store Connect
- [ ] Select build for TestFlight
- [ ] Create TestFlight public link
- [ ] Test on real device

---

## 🚀 Next Steps

1. **In App Store Connect** (already open):
   - Click "My Apps" → "+" → "New App"
   - Select iOS
   - Name: TradeFly AI
   - Bundle ID: com.tradefly.TradeFly
   - SKU: tradefly-ios-001
   - Full Access

2. **Fill in the metadata** using the information above

3. **Create Privacy Policy** (quick template):
   - Use https://www.privacypolicygenerator.info/
   - Host at Vercel or your domain

4. **Archive in Xcode**:
   - Product → Destination → Any iOS Device
   - Product → Archive
   - Distribute App → App Store Connect → Upload

5. **Add to TestFlight**:
   - Select the uploaded build
   - Add to TestFlight
   - Get public link to share

---

## 📞 Support

If you encounter issues:
- **Xcode Archive Issues**: Check code signing settings
- **Upload Failed**: Verify bundle ID matches App Store Connect
- **App Rejected**: Review App Review Guidelines
- **Privacy Policy**: Must be hosted and accessible

---

**Current Status:**
✅ Backend running (http://localhost:8000)
✅ iOS app built and running in simulator
✅ Build number: 2
✅ Version: 1.0
✅ Code signing team: G46B7YC46C

**Ready for:**
📤 Archive → Upload to App Store Connect → TestFlight
