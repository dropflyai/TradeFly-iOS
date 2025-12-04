# Automated TestFlight Uploads Setup

## Quick Setup (5 minutes)

### Step 1: Create App Store Connect API Key
1. Go to: https://appstoreconnect.apple.com/access/integrations/api
2. Click the **"+"** button
3. Name: **"FastLane Automation"**
4. Access: **App Manager** or **Admin**
5. Click **"Generate"**
6. **DOWNLOAD** the `.p8` file (you can only download once!)
7. Copy the **Key ID** (e.g., `ABCD123456`)
8. Copy the **Issuer ID** (at top of page, e.g., `12345678-1234-1234-1234-123456789012`)

### Step 2: Install the API Key
```bash
# Create directory
mkdir -p ~/.appstoreconnect/private_keys

# Move downloaded key (replace with your actual filename)
mv ~/Downloads/AuthKey_*.p8 ~/.appstoreconnect/private_keys/AuthKey.p8
```

### Step 3: Set Environment Variables
```bash
# Copy example file
cp .env.example .env

# Edit .env and add your credentials
# Replace with YOUR actual values:
APP_STORE_CONNECT_KEY_ID=ABCD123456
APP_STORE_CONNECT_ISSUER_ID=12345678-1234-1234-1234-123456789012
```

### Step 4: Load Environment Variables
```bash
# Add to your shell profile (~/.zshrc or ~/.bashrc)
export APP_STORE_CONNECT_KEY_ID="YOUR_KEY_ID"
export APP_STORE_CONNECT_ISSUER_ID="YOUR_ISSUER_ID"

# Then reload
source ~/.zshrc  # or source ~/.bashrc
```

### Step 5: Test Automated Upload
```bash
bundle exec fastlane beta
```

It will now automatically upload to TestFlight without any prompts!

## Troubleshooting

**Error: "No API key found"**
- Make sure the .p8 file is at `~/.appstoreconnect/private_keys/AuthKey.p8`
- Check: `ls ~/.appstoreconnect/private_keys/`

**Error: "Invalid API key"**
- Verify KEY_ID and ISSUER_ID are correct
- Check: `echo $APP_STORE_CONNECT_KEY_ID`

**Still opens Transporter?**
- Fallback mode activated - check API key setup
- You can still upload manually via Transporter
