fiel# 🚀 Quick Start: Get TradeFly on TestFlight (5 minutes)

## Step 1: Create App in App Store Connect (2 min)

**App Store Connect is now open in your browser.**

1. Click **"My Apps"** → **"+"** button → **"New App"**

2. Fill in the form:
   - **Platforms**: ✅ iOS
   - **Name**: `TradeFly AI`
   - **Primary Language**: `English (U.S.)`
   - **Bundle ID**: Select → `com.tradefly.TradeFly` (should appear in dropdown)
   - **SKU**: `tradefly-ios-001`
   - **User Access**: `Full Access`

3. Click **"Create"**

---

## Step 2: Archive & Upload in Xcode (3 min)

**Xcode is already open with the project.**

### 2.1 Select Device
1. At the top of Xcode, click the device selector (currently shows "TradeFly")
2. Change to: **"Any iOS Device (arm64)"**

### 2.2 Archive
1. Menu Bar → **Product** → **Archive** (or press Cmd+B then wait)
2. Wait for build to complete (~1-2 minutes)
3. The **Organizer** window will open automatically

### 2.3 Distribute
1. In Organizer, click **"Distribute App"**
2. Select **"App Store Connect"** → **Next**
3. Select **"Upload"** → **Next**
4. Check **"Upload your app's symbols"** → **Next**
5. Select **"Automatically manage signing"** → **Next**
6. Review summary → Click **"Upload"**
7. Wait for upload to complete (~30 seconds - 2 minutes)

---

## Step 3: Add to TestFlight (1 min)

1. Back in **App Store Connect** (browser)
2. Go to your app → **TestFlight** tab (top navigation)
3. Under **"iOS"** → Click on **Build 2** (or latest build number)
4. Click **"Select Version to Test"** or **"Start Testing"**
5. **Export Compliance**:
   - "Does your app use encryption?" → **NO** (we're just using HTTPS)
   - Save
6. Click **"External Testing"** → **"+"** → **"Add Group"**
   - Name: `Public Beta`
   - Enable **"Public Link"**
   - Save

7. **Copy the Public Link** - Share this to test on your iPhone!

---

## Step 4: Test on Your iPhone (30 seconds)

1. On your iPhone, open the public link from Step 3
2. Install **TestFlight** app if you don't have it
3. Click **"Accept"** → **"Install"**
4. Open TradeFly from your home screen
5. Sign up with your email
6. Complete onboarding
7. See the NVDA signal! 🎉

---

## 🎯 Current Build Info

- **App Name**: TradeFly AI
- **Bundle ID**: com.tradefly.TradeFly
- **Version**: 1.0
- **Build**: 2
- **Team**: G46B7YC46C
- **Backend**: Running on http://localhost:8000
- **Active Signals**: 1 HIGH quality NVDA signal ready to test

---

## ⚠️ Common Issues

### "No profiles found"
**Solution**: In Xcode → Signing & Capabilities → Make sure:
- ✅ "Automatically manage signing" is checked
- ✅ Team is selected: `Rio Allen (G46B7YC46C)`

### "Archive is not showing in Organizer"
**Solution**:
- Make sure you selected **"Any iOS Device (arm64)"** not a simulator
- Re-archive: Product → Clean Build Folder → Product → Archive

### "Upload failed - Invalid Bundle ID"
**Solution**: The Bundle ID in Xcode must match App Store Connect exactly:
- App Store Connect: `com.tradefly.TradeFly`
- Xcode: `com.tradefly.TradeFly` ✅

---

## 📱 What Happens After Upload?

1. **Processing** (~5-10 min): Apple processes your build
2. **Available in TestFlight** (~10-15 min): Build appears in TestFlight section
3. **Beta Testing**: Share public link with anyone (up to 10,000 testers)
4. **Feedback**: Collect feedback via TestFlight
5. **Submit for Review**: When ready, submit to App Store

---

## 🎉 Success Checklist

- [ ] App created in App Store Connect
- [ ] Xcode archive created successfully
- [ ] Build uploaded to App Store Connect
- [ ] Build appears in TestFlight (wait ~10 min)
- [ ] Public link created
- [ ] Installed on iPhone via TestFlight
- [ ] Signed up and saw the signal

---

## 📞 Need Help?

**If Xcode Archive fails:**
```bash
# Run this in terminal to see detailed errors:
xcodebuild -scheme TradeFly -sdk iphoneos \
  -configuration Release archive \
  -archivePath ./build/TradeFly.xcarchive \
  -allowProvisioningUpdates
```

**Current working directory:**
`/Users/rioallen/Documents/DropFly-OS-App-Builder/DropFly-PROJECTS/TradeFly-iOS`

---

**Ready? Let's do this!** 🚀

Start with **Step 1** in App Store Connect (already open in your browser).
