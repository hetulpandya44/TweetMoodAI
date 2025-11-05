# Quick Setup Checklist - Twitter API

Follow these steps in order to set up your Twitter API access:

## ✅ Step-by-Step Checklist

### Step 1: Go to Developer Portal
- [ ] Open browser and go to: **https://developer.twitter.com/en/portal/dashboard**
- [ ] Sign in with your Twitter account
- [ ] If prompted, apply for developer access (usually instant approval)

### Step 2: Create a Project
- [ ] Click **"+ Create Project"** button (top right or in sidebar)
- [ ] Enter project name: `TweetMoodAI`
- [ ] Select use case: **"Making a bot"** (or similar)
- [ ] Complete project creation wizard
- [ ] ✅ Verify: Project appears in dashboard

### Step 3: Check/Create App
- [ ] Check if you already have an app in your project
- [ ] If no app: Click **"Create App"** or **"Add App"**
- [ ] Name it: `TweetMoodAI-App`
- [ ] ✅ Verify: App appears under your project

### Step 4: Attach App to Project
- [ ] Check app status:
  - If shows "Attached" ✅ → Skip to Step 5
  - If shows "Standalone" ❌ → Continue below
- [ ] **If standalone**: Click **"Add existing app"** or **"Attach to Project"**
- [ ] Select your app and click **"Attach"**
- [ ] ✅ Verify: App now shows as "Attached" to project

### Step 5: Generate Bearer Token
- [ ] Go to your **App** → **"Keys and tokens"** tab
- [ ] Scroll to **"Bearer Token"** section
- [ ] Click **"Generate"** or **"Regenerate Bearer Token"**
- [ ] ⚠️ **IMMEDIATELY COPY THE TOKEN** (starts with `AAAA...`)
- [ ] ✅ Verify: Token is copied (you won't see it again!)

### Step 6: Update .env File
- [ ] Navigate to project folder: `C:\Users\hetul\TweetMoodAI`
- [ ] Open `.env` file (VS Code or Notepad)
- [ ] Find these lines:
  ```env
  X_BEARER_TOKEN=your_bearer_token_here
  TWITTER_BEARER_TOKEN=your_bearer_token_here
  ```
- [ ] Replace `your_bearer_token_here` with your actual token
- [ ] ⚠️ **Make sure**:
  - No spaces around `=`
  - Token on one line (no breaks)
  - No quotes around token
  - Token starts with `AAAA...`
- [ ] Save the file (`Ctrl+S`)

### Step 7: Verify Setup
- [ ] Open PowerShell in project folder
- [ ] Run verification:
  ```powershell
  .\venv\Scripts\python.exe scripts/verify_env.py
  ```
- [ ] ✅ Should show: "All Twitter API credentials are configured!"
- [ ] Test tweet collection:
  ```powershell
  .\venv\Scripts\python.exe scripts/fetch_twitter_api.py --query "#test" --max_tweets 5
  ```
- [ ] ✅ Should successfully fetch tweets (no 403/401 errors)

---

## 🎯 Quick Commands Reference

### Verify Environment
```powershell
.\venv\Scripts\python.exe scripts/verify_env.py
```

### Test Tweet Collection
```powershell
.\venv\Scripts\python.exe scripts/fetch_twitter_api.py --query "#AI" --max_tweets 10
```

### Collect 300 Tweets
```powershell
.\venv\Scripts\python.exe scripts/fetch_twitter_api.py --query "#AI" --max_tweets 300
```

---

## ❗ Common Issues

| Error | Solution |
|-------|----------|
| "client-not-enrolled" | Make sure app is attached to project (Step 4) |
| "Invalid Bearer Token" | Regenerate token and update .env (Step 5-6) |
| "Rate limit exceeded" | Wait 15 minutes and try again |
| Token disappears | Normal - regenerate new one (Step 5) |

---

## 📚 Need More Help?

- **Detailed Guide**: See `TWITTER_API_SETUP.md`
- **Twitter Portal**: https://developer.twitter.com/en/portal/dashboard
- **API Docs**: https://developer.twitter.com/en/docs/twitter-api

---

**Once all steps are checked ✅, you're ready to collect tweets!**

