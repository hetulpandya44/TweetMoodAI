# Twitter API Setup Guide - Step by Step

This guide will walk you through setting up your Twitter Developer account, creating a project, and configuring your Bearer Token for the TweetMoodAI application.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Step 1: Access Developer Portal](#step-1-access-developer-portal)
3. [Step 2: Create a Project](#step-2-create-a-project)
4. [Step 3: Create an App (if needed)](#step-3-create-an-app-if-needed)
5. [Step 4: Attach App to Project](#step-4-attach-app-to-project)
6. [Step 5: Generate Bearer Token](#step-5-generate-bearer-token)
7. [Step 6: Update .env File](#step-6-update-env-file)
8. [Step 7: Verify Setup](#step-7-verify-setup)
9. [Troubleshooting](#troubleshooting)

---

## Prerequisites

- A Twitter account (regular account, not developer account)
- Email address verified with Twitter
- Access to create projects and apps (requires developer account approval)

---

## Step 1: Access Developer Portal

### 1.1. Navigate to Developer Portal

1. **Open your web browser** and go to:
   ```
   https://developer.twitter.com/en/portal/dashboard
   ```

2. **Sign in** with your Twitter account credentials
   - If you're not signed in, you'll be prompted to log in
   - If you don't have a developer account, you'll need to apply first

### 1.2. Apply for Developer Access (if needed)

If you see a message about applying for developer access:

1. Click **"Apply for a Developer Account"** or **"Get Started"**
2. Fill out the application form:
   - **Account use case**: Select "Making a bot" or "Exploring the API"
   - **Describe your use case**: Explain you're building a sentiment analysis tool for tweets
   - **Will you make Twitter content available to a government entity?**: Select "No"
3. Accept the terms and conditions
4. Submit the application
5. Wait for approval (usually instant or within a few hours)

### 1.3. Access Your Dashboard

Once approved, you'll see the **Developer Portal Dashboard**. It should show:
- Your projects (if any)
- Your apps (if any)
- API keys and tokens section

---

## Step 2: Create a Project

### 2.1. Navigate to Projects

1. In the **Developer Portal Dashboard**, look for:
   - A **"Projects"** section on the left sidebar, OR
   - A **"Create Project"** button at the top

2. If you don't see a Projects section, click **"Projects & Apps"** or **"Developer Portal"** menu

### 2.2. Create New Project

1. Click the **"+ Create Project"** button (usually a blue button with a plus icon)

2. **Enter Project Details**:
   - **Project name**: Enter `TweetMoodAI` (or any name you prefer)
   - **Use case**: Select one that fits:
     - "Making a bot" (recommended)
     - "Exploring the API"
     - "Academic research"
   - Click **"Next"**

3. **Project description** (optional):
   - Describe your project briefly
   - Example: "AI-powered sentiment analysis tool for Twitter data"
   - Click **"Next"**

4. **Review and Create**:
   - Review your project details
   - Accept terms and conditions
   - Click **"Create Project"**

### 2.3. Verify Project Creation

- You should see your new project listed in the dashboard
- The project will show as "Active" or "In Use"

---

## Step 3: Create an App (if needed)

### 3.1. Check if You Have an App

1. In your **Project dashboard**, check if there's already an **App** listed
2. If you see an app (even if it says "Standalone"), proceed to Step 4
3. If you don't have an app, continue below

### 3.2. Create New App

1. Inside your **Project**, look for:
   - **"Add App"** or **"Create App"** button
   - Or click **"Settings"** tab → **"Apps"** section

2. Click **"Create App"** or **"Add App"**

3. **Enter App Details**:
   - **App name**: Enter `TweetMoodAI-App` (or any unique name)
   - **App environment**: Usually just one environment is available

4. **Fill Required URLs** (Twitter requires these, but they're not actively used for Bearer Token):
   - **Callback URI / Redirect URL**: Enter `http://localhost:8000/callback`
   - **Website URL**: Enter `http://localhost:8000`
   - ⚠️ **Note**: These are placeholders for API-only apps. See [TWITTER_APP_CONFIG.md](TWITTER_APP_CONFIG.md) for details.
   - Click **"Save"** or **"Create"**

5. **App Created**: You should see your app listed under the project

---

## Step 4: Attach App to Project

### 4.1. Check App Status

1. Go to your **Project dashboard**
2. Look at your **Apps** list
3. Check if the app shows:
   - ✅ **"Attached"** or **"In Project"** → Skip to Step 5
   - ❌ **"Standalone"** or **"Not attached"** → Continue below

### 4.2. Attach Standalone App to Project

If your app is standalone:

1. **Option A: From Project Dashboard**
   - In your project, click **"Settings"** tab
   - Go to **"Apps"** section
   - Click **"Add existing app"** or **"Import app"**
   - Select your standalone app from the list
   - Click **"Add"** or **"Attach"**

2. **Option B: From App Settings**
   - Go to **Developer Portal** → **"Apps"** (in sidebar)
   - Click on your standalone app
   - Look for **"Project"** or **"Attach to Project"** option
   - Select your project from the dropdown
   - Click **"Save"** or **"Attach"**

3. **Option C: Migrate Standalone App**
   - Twitter sometimes requires migration of old standalone apps
   - If you see **"Migrate"** or **"Upgrade"** option, click it
   - Follow the migration wizard to attach to a project

### 4.3. Verify Attachment

- Your app should now show as **"Attached"** or be listed under your project
- The app name should appear in your project's Apps section

---

## Step 5: Generate Bearer Token

### 5.1. Navigate to Keys and Tokens

1. Go to your **Project dashboard**
2. Click on your **App** (or go to Apps section)
3. Click on the **"Keys and tokens"** tab
   - This is usually in the top navigation or sidebar

**Note**: You might see **OAuth 2.0 Client ID and Client Secret** first - that's normal! The Bearer Token is in a different section below. See [OAUTH_AND_BEARER_TOKEN.md](OAUTH_AND_BEARER_TOKEN.md) for details.

### 5.2. Find Bearer Token Section

1. Scroll down to find **"Bearer Token"** section
2. You should see either:
   - **"Bearer Token"** with a value (if already generated)
   - **"Generate"** or **"Regenerate"** button

### 5.3. Generate or Regenerate Bearer Token

1. If you see **"Generate Bearer Token"**:
   - Click the button
   - Confirm the action if prompted

2. If you see **"Regenerate Bearer Token"**:
   - ⚠️ **Warning**: This will invalidate your old token
   - Click **"Regenerate"**
   - Confirm the action

3. **Copy the Bearer Token**:
   - The token will appear (starts with `AAAA...`)
   - Click the **copy icon** or **"Copy"** button
   - ⚠️ **Important**: Copy it immediately - you might not see it again!
   - The token format looks like: `AAAAAABBBBBBCCCCCCDDDDDD...`

### 5.4. Save Token Securely

- ✅ **Save the token** in a secure location temporarily
- ⚠️ **Never share** this token publicly or commit it to Git
- The token is used for authentication with Twitter API

---

## Step 6: Update .env File

### 6.1. Locate Your .env File

1. Navigate to your project directory:
   ```powershell
   cd C:\Users\hetul\TweetMoodAI
   ```

2. Verify the `.env` file exists:
   ```powershell
   Test-Path .env
   ```
   Should return: `True`

### 6.2. Open .env File

**Option A: Using VS Code** (Recommended)
1. Open VS Code
2. Open the folder: `C:\Users\hetul\TweetMoodAI`
3. Click on `.env` file in the file explorer
4. If you don't see it, press `Ctrl+P` and type `.env`

**Option B: Using Notepad**
1. Open PowerShell
2. Run:
   ```powershell
   notepad .env
   ```

### 6.3. Add or Update Bearer Token

Find these lines in your `.env` file:

```env
TWITTER_BEARER_TOKEN=your_bearer_token_here
X_BEARER_TOKEN=your_bearer_token_here
```

**Update both lines** with your actual Bearer Token:

```env
TWITTER_BEARER_TOKEN=AAAAAABBBBBBCCCCCCDDDDDD...your_actual_token
X_BEARER_TOKEN=AAAAAABBBBBBCCCCCCDDDDDD...your_actual_token
```

**Or just update one** (the script checks both):
```env
X_BEARER_TOKEN=AAAAAABBBBBBCCCCCCDDDDDD...your_actual_token
```

### 6.4. Save the File

1. Press `Ctrl+S` to save (VS Code/Notepad)
2. Make sure the file is saved in the project root directory

### 6.5. Verify .env File Format

Your `.env` file should look something like this:

```env
# Twitter API Credentials
TWITTER_API_KEY=your_api_key_here
TWITTER_API_SECRET=your_api_secret_here
TWITTER_ACCESS_TOKEN=your_access_token_here
TWITTER_ACCESS_TOKEN_SECRET=your_access_token_secret_here
TWITTER_BEARER_TOKEN=AAAAAABBBBBBCCCCCCDDDDDD...actual_token_here
X_BEARER_TOKEN=AAAAAABBBBBBCCCCCCDDDDDD...actual_token_here

# Optional: Application Settings
DEBUG=False
LOG_LEVEL=INFO
```

⚠️ **Important Notes**:
- Make sure there are **no spaces** around the `=` sign
- Make sure the token is on **one line** (no line breaks)
- Make sure there are **no quotes** around the token value
- The token should start with `AAAA...` (new format) or `Bearer` (older format)

---

## Step 7: Verify Setup

### 7.1. Verify Environment Variables

Run the verification script:

```powershell
.\venv\Scripts\python.exe scripts/verify_env.py
```

**Expected Output**:
```
==================================================
Environment Variables Verification
==================================================
✅ TWITTER_API_KEY: JjMp*****************Ivrf
✅ TWITTER_API_SECRET: NOw5******************************************OtkC
✅ TWITTER_ACCESS_TOKEN: 1984******************************************ShJ7
✅ TWITTER_ACCESS_TOKEN_SECRET: YRzC*************************************8ow1
✅ Bearer Token (X_BEARER_TOKEN or TWITTER_BEARER_TOKEN): AAAA*****************8Rwu
==================================================
✅ All Twitter API credentials are configured!
==================================================
```

### 7.2. Test Tweet Collection

Test with a small query:

```powershell
.\venv\Scripts\python.exe scripts/fetch_twitter_api.py --query "#test" --max_tweets 5
```

**Success Indicators**:
- ✅ No authentication errors
- ✅ Fetches tweets successfully
- ✅ Creates `data/tweets.json` file
- ✅ Shows "Successfully collected X tweets"

**If you see errors**, check the [Troubleshooting](#troubleshooting) section below.

---

## Troubleshooting

### Error: "client-not-enrolled" or "Client Forbidden (403)"

**Problem**: App is not attached to a project.

**Solution**:
1. Go back to Step 4 and ensure your app is attached to a project
2. Regenerate Bearer Token after attaching (Step 5)
3. Update `.env` with new token (Step 6)
4. Try again

### Error: "Invalid Bearer Token (401)"

**Problem**: Token is incorrect or expired.

**Solutions**:
1. **Check token format**:
   - Should start with `AAAA...`
   - Should be one long string (no spaces)
   - Should be in one line in `.env` file

2. **Regenerate token**:
   - Go to Developer Portal → Your App → Keys and tokens
   - Click "Regenerate Bearer Token"
   - Copy the new token
   - Update `.env` file

3. **Verify .env file**:
   - Make sure there are no extra spaces
   - Make sure token is not wrapped in quotes
   - Make sure you saved the file

4. **Check file encoding**:
   - `.env` file should be UTF-8 encoded
   - No special characters that might corrupt the token

### Error: "Rate limit exceeded (429)"

**Problem**: Too many API requests.

**Solution**:
- Wait 15 minutes before trying again
- Twitter API v2 Basic tier: 300 requests per 15 minutes
- The script handles this automatically, just wait and retry

### Error: "No tweets found"

**Problem**: Query doesn't match any tweets.

**Solutions**:
1. Try a different, more common hashtag: `#AI`, `#tech`, `#python`
2. Remove language filter (if you added one)
3. Check if the query syntax is correct
4. Try without hashtag: `--query "artificial intelligence"`

### Can't Find "Create Project" Button

**Problem**: Interface might be different or account not fully approved.

**Solutions**:
1. **Refresh the page** (Ctrl+F5)
2. **Check account status**:
   - Go to https://developer.twitter.com/en/portal/products
   - Ensure you have access to Twitter API v2
3. **Contact Twitter Support**:
   - Go to https://help.twitter.com/en/forms/developer
   - Report the issue

### Token Disappears After Generation

**Problem**: Twitter only shows token once for security.

**Solution**:
- Regenerate a new token (Step 5)
- Copy it immediately this time
- Make sure to save it in `.env` file

### .env File Not Found

**Problem**: File might not exist or in wrong location.

**Solution**:
1. Create from template:
   ```powershell
   Copy-Item env.example .env
   ```
2. Verify location: Should be in `C:\Users\hetul\TweetMoodAI\.env`
3. Open and edit with VS Code or Notepad

---

## Quick Reference

### Command to Test Setup
```powershell
.\venv\Scripts\python.exe scripts/fetch_twitter_api.py --query "#AI" --max_tweets 10
```

### Important URLs
- Developer Portal: https://developer.twitter.com/en/portal/dashboard
- API Documentation: https://developer.twitter.com/en/docs/twitter-api
- Support: https://help.twitter.com/en/forms/developer

### Environment Variables Needed
```env
X_BEARER_TOKEN=your_token_here
# OR
TWITTER_BEARER_TOKEN=your_token_here
```

---

## Next Steps

Once your setup is verified:

1. ✅ Collect tweets: `python scripts/fetch_twitter_api.py --query "#AI" --max_tweets 300`
2. ✅ Tweets saved to: `data/tweets.json`
3. ✅ Ready for sentiment analysis!

---

**Need Help?**
- Check error messages carefully - they usually indicate the specific problem
- Verify each step was completed successfully
- Ensure your Developer account is approved and active
- Twitter API documentation: https://developer.twitter.com/en/docs/twitter-api
