# GitHub Actions - Automated TestFlight Uploads

## How It Works

Every time you push to `main` branch, GitHub Actions will automatically:
1. Build the iOS app
2. Increment build number
3. Upload to TestFlight
4. Save IPA as artifact (backup)

**Just like the PDF editor!**

## One-Time Setup (10 minutes)

### Step 1: Get App-Specific Password

1. Go to: https://appleid.apple.com/account/manage
2. Click **"App-Specific Passwords"**
3. Click **"+"** to generate new password
4. Name it: **"GitHub Actions TradeFly"**
5. Copy the password (looks like: `xxxx-xxxx-xxxx-xxxx`)

### Step 2: Export iOS Certificates

```bash
# Export your development certificate from Keychain
# 1. Open Keychain Access
# 2. Find "iPhone Developer: Your Name"
# 3. Right-click → Export
# 4. Save as: ~/Desktop/Certificates.p12
# 5. Set a password when prompted

# Convert to base64
base64 -i ~/Desktop/Certificates.p12 | pbcopy
# Now the base64 string is in your clipboard
```

### Step 3: Get Provisioning Profile

```bash
# Download from Xcode or manually:
# 1. Go to: https://developer.apple.com/account/resources/profiles/list
# 2. Download your App Store provisioning profile
# 3. Convert to base64:

base64 -i ~/Downloads/YourProfile.mobileprovision | pbcopy
```

### Step 4: Add GitHub Secrets

Go to your repo: `https://github.com/YOUR_USERNAME/TradeFly-iOS/settings/secrets/actions`

Add these secrets:

| Secret Name | Value | How to Get |
|------------|-------|-----------|
| `APPLE_ID` | `dropflyai@gmail.com` | Your Apple ID email |
| `APP_SPECIFIC_PASSWORD` | `xxxx-xxxx-xxxx-xxxx` | From Step 1 |
| `IOS_CERTIFICATE_P12` | `MIIKoQIBAz...` | From Step 2 (base64) |
| `IOS_CERTIFICATE_PASSWORD` | `yourpassword` | Password you set in Step 2 |
| `IOS_PROVISIONING_PROFILE` | `MIIMoQ...` | From Step 3 (base64) |

### Step 5: Push to GitHub

```bash
git add -A
git commit -m "Add GitHub Actions for automated TestFlight uploads"
git push origin main
```

That's it! Check the **Actions** tab on GitHub to see the build progress.

## Usage

### Automatic Upload (After Setup)
```bash
git add -A
git commit -m "Your changes"
git push
```
→ GitHub Actions automatically uploads to TestFlight in ~5 minutes

### Manual Trigger
1. Go to GitHub repo → **Actions** tab
2. Click **"Build and Upload to TestFlight"**
3. Click **"Run workflow"**
4. Select branch → **"Run workflow"**

## Checking Build Status

- Go to: `https://github.com/YOUR_USERNAME/TradeFly-iOS/actions`
- See real-time build progress
- Download IPA from artifacts if needed

## Benefits

✅ No more manual uploads
✅ No more Transporter
✅ No more Xcode archiving
✅ Build from anywhere (even your phone!)
✅ Full CI/CD pipeline
✅ Version history tracked
✅ Team can trigger builds

## Troubleshooting

**Error: "Certificate not found"**
- Re-export certificate and re-encode to base64
- Make sure password is correct

**Error: "Provisioning profile expired"**
- Download new provisioning profile
- Re-encode and update secret

**Error: "App-specific password invalid"**
- Generate new password at appleid.apple.com
- Update `APP_SPECIFIC_PASSWORD` secret
