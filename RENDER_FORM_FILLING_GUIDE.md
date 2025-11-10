# 📝 Render.com Form Filling Guide

**Step-by-step guide for filling out Render.com web service form**

---

## ⚠️ Important: Use Docker Deployment Instead!

**Your project uses Docker**, so you have two options:

### Option 1: Use Blueprint (Recommended - Easiest) ✅
- Uses `render.yaml` automatically
- Deploys both services at once
- No manual form filling needed

### Option 2: Manual Docker Deployment
- More control over settings
- Need to configure Docker settings

**💡 Recommendation:** Use **Blueprint** method (see `DEPLOY_WITH_REPO_URL.md`)

---

## If You Must Fill the Form Manually

If you need to fill the form manually, here's what to enter:

---

## 📋 Form Fields - Step by Step

### 1. Source Code Section

**Repository:**
```
hetulpandya44 / TweetMoodAI
```
- ✅ Already selected
- This is your GitHub repository

---

### 2. Service Type

**Select:**
```
Web Service
```
- ✅ Already selected
- This is correct for your application

---

### 3. Name

**Enter:**
```
tweetmoodai-backend
```
**Or for frontend:**
```
tweetmoodai-frontend
```

- ✅ Must be unique
- Use lowercase, hyphens only
- Backend and frontend need separate services

---

### 4. Language

**⚠️ Important:** Your project uses **Docker**, not Python runtime!

**You have two options:**

#### Option A: Use Docker (Recommended) ✅

**Change Language to:**
```
Docker
```

**Then configure:**
- **Dockerfile Path:** `Dockerfile.backend` (for backend)
- **Dockerfile Path:** `Dockerfile.frontend` (for frontend)
- **Docker Context:** `.` (current directory)

#### Option B: Use Python (Not Recommended - Requires Changes)

If you select Python 3, you'll need to:
- Change build command
- Change start command
- But your project is designed for Docker!

**💡 Recommendation:** Use **Docker** option

---

### 5. Branch

**Enter:**
```
main
```
- ✅ This is your main branch
- Render will deploy from this branch

---

### 6. Region

**Select:**
```
Oregon (US West)
```
- ✅ Good default choice
- Or choose closest to you
- Backend and frontend should be in same region

---

### 7. Root Directory

**Leave Empty** (or enter `.`)
```
(empty)
```
- ✅ Your application is in the root directory
- Only needed if your app is in a subdirectory

---

### 8. Build Command

**⚠️ Important:** This depends on your deployment method!

#### If Using Docker:
**Leave Empty** (Docker handles building)
```
(empty)
```

#### If Using Python (Not Recommended):
**Enter:**
```
pip install -r requirements.txt
```
- But your project uses Docker, so this won't work correctly!

---

### 9. Start Command

**⚠️ Important:** This depends on your deployment method!

#### If Using Docker:
**Leave Empty** (Docker handles starting)
```
(empty)
```

#### If Using Python (Not Recommended):
**Backend:**
```
uvicorn app.main:app --host 0.0.0.0 --port $PORT
```

**Frontend:**
```
streamlit run ui/app.py --server.port $PORT --server.address 0.0.0.0 --server.headless=true
```

**💡 But your project uses Docker, so use Docker method!**

---

### 10. Instance Type

**Select:**
```
Free
```
- ✅ Free tier is sufficient
- ✅ $0/month
- ✅ Perfect for demonstrations
- ✅ Limitations are acceptable (see `FREE_TIER_LIMITATIONS.md`)

---

### 11. Environment Variables

**Add these environment variables:**

#### For Backend:
```
API_HOST=0.0.0.0
API_PORT=8000
MODEL_PATH=/app/models/sentiment_model
LOG_LEVEL=INFO
DEBUG=False
CORS_ORIGINS=*
```

#### For Frontend:
```
API_URL=https://tweetmoodai-backend.onrender.com
FASTAPI_URL=https://tweetmoodai-backend.onrender.com
API_TIMEOUT=60
```

**⚠️ Important:** Update `API_URL` and `FASTAPI_URL` with your actual backend URL after backend deploys!

**Your existing environment variables:**
- `X_API_KEY` - Keep if needed
- `X_API_SECRET` - Keep if needed
- `X_ACCESS_TOKEN` - Keep if needed
- `X_ACCESS_TOKEN_SECRET` - Keep if needed
- `X_BEARER_TOKEN` - Keep if needed
- `API_URL` - Update to backend URL (for frontend)
- `API_TIMEOUT` - Keep as `60`
- `DEBUG` - Set to `False`
- `LOG_LEVEL` - Set to `INFO`

---

### 12. Health Check Path

**Enter:**
```
/healthz
```
- ✅ This is your health check endpoint
- ✅ Render will check this to monitor your service

---

### 13. Pre-Deploy Command

**Leave Empty**
```
(empty)
```
- ✅ Not needed for your application
- Only needed for database migrations, etc.

---

### 14. Auto-Deploy

**Select:**
```
On Commit
```
- ✅ Automatically deploys when you push to GitHub
- ✅ Recommended for development

---

### 15. Build Filters

**Leave Empty** (Default)
```
(empty)
```
- ✅ Deploy on all changes
- Only customize if you need to exclude certain files

---

## 🎯 Recommended: Use Blueprint Instead!

**Instead of filling this form manually, use Blueprint:**

### Step 1: Go to Blueprint
1. Click **"New +"** → **"Blueprint"**
2. Enter repository URL: `https://github.com/hetulpandya44/TweetMoodAI.git`
3. Render detects `render.yaml` automatically
4. Click **"Apply"**
5. Done! Both services deploy automatically

### Step 2: Configure Environment Variables
1. Go to frontend service → **"Environment"** tab
2. Update `API_URL` to your backend URL
3. Update `FASTAPI_URL` to your backend URL
4. Save changes

**💡 This is much easier than filling the form manually!**

---

## 📋 Complete Form Example (If Using Docker)

### Backend Service:

```
Source Code: hetulpandya44 / TweetMoodAI
Service Type: Web Service
Name: tweetmoodai-backend
Language: Docker
Branch: main
Region: Oregon (US West)
Root Directory: (empty)
Build Command: (empty)
Start Command: (empty)
Instance Type: Free
Environment Variables:
  - API_HOST=0.0.0.0
  - API_PORT=8000
  - MODEL_PATH=/app/models/sentiment_model
  - LOG_LEVEL=INFO
  - DEBUG=False
  - CORS_ORIGINS=*
Health Check Path: /healthz
Pre-Deploy Command: (empty)
Auto-Deploy: On Commit
Build Filters: (empty)
```

### Frontend Service:

```
Source Code: hetulpandya44 / TweetMoodAI
Service Type: Web Service
Name: tweetmoodai-frontend
Language: Docker
Branch: main
Region: Oregon (US West)
Root Directory: (empty)
Build Command: (empty)
Start Command: (empty)
Instance Type: Free
Environment Variables:
  - API_URL=https://tweetmoodai-backend.onrender.com
  - FASTAPI_URL=https://tweetmoodai-backend.onrender.com
  - API_TIMEOUT=60
Health Check Path: (empty or /)
Pre-Deploy Command: (empty)
Auto-Deploy: On Commit
Build Filters: (empty)
```

---

## ⚠️ Important Notes

### 1. Use Docker, Not Python Runtime
- Your project uses Docker (`Dockerfile.backend` and `Dockerfile.frontend`)
- Don't use Python runtime - use Docker runtime
- Docker handles building and starting automatically

### 2. Build and Start Commands
- **If using Docker:** Leave empty (Docker handles it)
- **If using Python:** Need to specify commands (not recommended)

### 3. Environment Variables
- Backend needs: `API_HOST`, `API_PORT`, `MODEL_PATH`, etc.
- Frontend needs: `API_URL`, `FASTAPI_URL` (pointing to backend)
- Update `API_URL` after backend deploys!

### 4. Health Check
- Backend: `/healthz`
- Frontend: Leave empty or use `/`

### 5. Two Separate Services
- Backend and frontend are separate services
- Deploy backend first
- Then deploy frontend
- Update frontend environment variables with backend URL

---

## 🚀 Quick Start: Use Blueprint (Easiest)

**Instead of filling the form, use Blueprint:**

1. **Go to Blueprint:**
   - Click **"New +"** → **"Blueprint"**
   - Enter repository URL: `https://github.com/hetulpandya44/TweetMoodAI.git`

2. **Render detects `render.yaml`:**
   - Automatically configures both services
   - Sets all environment variables
   - Configures Docker settings

3. **Click "Apply":**
   - Both services deploy automatically
   - Much easier than filling forms!

4. **Update Environment Variables:**
   - Go to frontend service → **"Environment"** tab
   - Update `API_URL` to your backend URL
   - Update `FASTAPI_URL` to your backend URL

**💡 This is the recommended method!**

---

## 📚 Related Documentation

- **Blueprint Deployment**: `DEPLOY_WITH_REPO_URL.md` - Step-by-step Blueprint guide
- **Step-by-Step Guide**: `STEP_BY_STEP_DEPLOYMENT.md` - Complete deployment guide
- **Quick Launch**: `QUICK_LAUNCH.md` - Quick deployment guide
- **Free Tier Limitations**: `FREE_TIER_LIMITATIONS.md` - Free tier information

---

## ✅ Summary

### Recommended Method:
1. ✅ Use **Blueprint** deployment (easiest)
2. ✅ Render detects `render.yaml` automatically
3. ✅ Both services deploy at once
4. ✅ Update environment variables after deployment

### Manual Method (If Needed):
1. ⚠️ Use **Docker** runtime (not Python)
2. ⚠️ Leave build/start commands empty (Docker handles it)
3. ⚠️ Set environment variables manually
4. ⚠️ Deploy backend first, then frontend

---

**Last Updated**: 2025-01-27  
**Version**: 1.0.0

