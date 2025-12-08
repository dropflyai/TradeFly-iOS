# TradeFly Backend Integration - Complete Setup Guide

## 🎉 What's Been Completed

### 1. Backend Repository Setup ✅
- Created separate git repository: `dropflyai/TradeFly-Backend`
- Added Docker deployment configuration
- Added GitHub Actions for auto-deployment to EC2
- Backend is ready to deploy alongside your n8n instance

### 2. iOS App Backend Integration ✅
- Created `BackendConfig.swift` for API endpoint management
- Updated `APIClient.swift` with backend methods
- Added response models for all API endpoints
- Created `MarketStatusService` for real-time market updates
- All code pushed to `dropflyai/TradeFly-iOS`

### 3. Communication Architecture ✅

```
┌─────────────────────────────────────────┐
│   TradeFly Backend (Python)             │
│   EC2: port 8000                        │
│   - Scans markets every 60s             │
│   - AI analysis (GPT-5)                 │
│   - Writes signals to Supabase →       │
│   - Provides APIs for:                  │
│     • Market status                     │
│     • Real-time prices                  │
│     • News & sentiment                  │
│     • Chart data                        │
└──────────────┬──────────────────────────┘
               ↓
┌──────────────────────────────────────────┐
│        Supabase                          │
│   - Stores trading signals               │
│   - User authentication                  │
│   - Real-time subscriptions →           │
└──────────────┬───────────────────────────┘
               ↓
┌──────────────────────────────────────────┐
│   TradeFly iOS App (Swift)               │
│   - Reads signals from Supabase          │
│   - Calls backend for market data        │
│   - Real-time updates                    │
└──────────────────────────────────────────┘
```

## 🚀 Next Steps to Complete Deployment

### Step 1: Deploy Backend to EC2 (10 minutes)

```bash
# SSH into your EC2 instance (where n8n is running)
ssh -i your-key.pem ec2-user@your-ec2-ip

# Clone backend repository
cd ~
git clone https://github.com/dropflyai/TradeFly-Backend.git
cd TradeFly-Backend

# Set up environment variables
cp .env.example .env
nano .env
```

**Required environment variables:**
```bash
OPENAI_API_KEY=sk-proj-xxxxx           # Your OpenAI API key
SUPABASE_URL=https://xxxxx.supabase.co # From your Supabase dashboard
SUPABASE_SERVICE_KEY=xxxxx             # Service role key (not anon!)
USE_YAHOO_FINANCE=true                 # Free market data
```

```bash
# Deploy
./deploy.sh
```

Verify it's running:
```bash
curl http://localhost:8000/health
```

### Step 2: Open Port 8000 in EC2 Security Group

1. Go to AWS Console → EC2 → Security Groups
2. Find your instance's security group
3. Add inbound rule:
   - **Type:** Custom TCP
   - **Port:** 8000
   - **Source:** 0.0.0.0/0 (or your IP for security)

### Step 3: Update iOS App with Backend URL

Open `TradeFly/Config/BackendConfig.swift` and update:

```swift
static let baseURL: String = {
    #if DEBUG
    return "http://YOUR_EC2_IP:8000"  // Use your EC2 public IP
    #else
    return "https://api.tradefly.ai"   // Production domain
    #endif
}()
```

Test from simulator:
```bash
# In Xcode, run the app
# Market status should load from your backend
```

### Step 4: Set Up GitHub Actions Auto-Deployment (Optional)

Add these secrets to your backend repository:

**GitHub → Settings → Secrets and variables → Actions**

| Secret Name | Value |
|------------|-------|
| `EC2_SSH_PRIVATE_KEY` | Contents of your `.pem` file |
| `EC2_HOST` | Your EC2 IP (e.g., `54.123.45.67`) |
| `EC2_USER` | `ec2-user` (Amazon Linux) or `ubuntu` |

Now every push to `main` auto-deploys!

### Step 5: Configure Domain (Optional but Recommended)

**Option A: Direct Access**
- Use `http://your-ec2-ip:8000`
- Works immediately, no setup needed

**Option B: Custom Domain** (Recommended for production)

1. Point domain `api.tradefly.ai` to your EC2 IP
2. Set up nginx reverse proxy on EC2:

```nginx
server {
    listen 80;
    server_name api.tradefly.ai;

    location / {
        proxy_pass http://localhost:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
    }
}
```

3. Add SSL with Let's Encrypt:
```bash
sudo certbot --nginx -d api.tradefly.ai
```

## 📊 API Endpoints Available

Once deployed, these endpoints will be available:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/health` | GET | Health check & system status |
| `/market-status` | GET | Market hours + SPY/QQQ/BTC prices |
| `/signals/active` | GET | All active trading signals |
| `/signals/scan` | POST | Manually trigger signal scan |
| `/price/{ticker}` | GET | Real-time price + indicators |
| `/news/{ticker}` | GET | Stock-specific news |
| `/news/market/latest` | GET | Market-wide news (Fed, CPI, etc.) |
| `/candles/{ticker}` | GET | Chart candlestick data |
| `/stats` | GET | Backend statistics |

## 🧪 Testing the Integration

### Test Backend Health
```bash
curl http://your-ec2-ip:8000/health
```

Expected response:
```json
{
  "status": "healthy",
  "supabase": "connected",
  "market_data": "connected",
  "scheduler": "running"
}
```

### Test Market Status
```bash
curl http://your-ec2-ip:8000/market-status
```

### Test Real-time Price
```bash
curl http://your-ec2-ip:8000/price/AAPL
```

### Test from iOS App
1. Open Xcode
2. Run app in simulator
3. Market status banner should show live data
4. Signals should appear from backend scans

## 💰 Cost Estimate

**Current Setup:**
- EC2 t3.small: ~$15/month (shared with n8n)
- Data transfer: ~$1-5/month
- **Total: ~$16-20/month**

**Plus APIs:**
- OpenAI (GPT-5): Pay per use (~$10-50/month depending on usage)
- Supabase: Free tier (up to 500MB database)
- Yahoo Finance: Free

## 🔒 Security Checklist

- [ ] EC2 Security Group configured (port 8000)
- [ ] `.env` file contains real API keys
- [ ] GitHub secrets configured for auto-deploy
- [ ] Supabase RLS policies enabled
- [ ] Consider adding SSL/HTTPS for production
- [ ] Restrict port 22 (SSH) to your IP only

## 📱 iOS App Features Using Backend

### Currently Integrated:
- ✅ Market status (open/closed, pre-market, after-hours)
- ✅ Real-time indices (SPY, QQQ, BTC)
- ✅ API client with all endpoints
- ✅ Market status service with auto-refresh

### Ready to Integrate (code exists, just wire up views):
- 📊 Real-time price updates
- 📰 News in signal detail views
- 📈 Advanced charting with backend candle data
- 🔔 Manual signal scan trigger

## 🐛 Troubleshooting

### Backend won't start
```bash
# Check logs
cd ~/TradeFly-Backend
docker-compose logs -f
```

### Can't connect from iOS
- Verify EC2 security group allows port 8000
- Check `BackendConfig.swift` has correct IP
- Test with curl from your Mac:
  ```bash
  curl http://your-ec2-ip:8000/health
  ```

### Signals not appearing
- Check backend logs: `docker-compose logs -f`
- Verify Supabase credentials in `.env`
- Trigger manual scan:
  ```bash
  curl -X POST http://your-ec2-ip:8000/signals/scan
  ```

## 📚 Documentation

- **Backend Deployment:** `TradeFly-Backend/DEPLOYMENT.md`
- **GitHub Actions:** `TradeFly-Backend/.github/GITHUB_ACTIONS_SETUP.md`
- **Backend README:** `TradeFly-Backend/README.md`
- **iOS README:** `TradeFly-iOS/README.md`

## 🎯 Quick Start Summary

1. **Deploy backend** (10 min):
   ```bash
   ssh into EC2 → clone repo → setup .env → ./deploy.sh
   ```

2. **Open port 8000** in AWS Security Group (2 min)

3. **Update iOS app** with your EC2 IP (1 min)

4. **Test** both separately, then together (5 min)

5. **Set up auto-deploy** with GitHub secrets (5 min)

**Total setup time: ~25 minutes**

## ✅ What You Have Now

1. ✅ Separate git repos for backend and iOS
2. ✅ Docker deployment for backend
3. ✅ GitHub Actions for auto-deployment
4. ✅ iOS app integrated with backend APIs
5. ✅ Real-time signals via Supabase
6. ✅ Market data, news, and charting ready
7. ✅ Scalable architecture
8. ✅ Production-ready code

## 🚀 Future Enhancements

- [ ] Add Nginx reverse proxy with SSL
- [ ] Custom domain (api.tradefly.ai)
- [ ] CloudWatch monitoring
- [ ] Auto-scaling with ECS
- [ ] Redis caching for faster responses
- [ ] WebSocket for even faster updates

---

**You're ready to deploy!** 🎉

Follow Step 1 above to get started.
