# Render Deployment Guide - Step by Step

**Date**: 2025-11-03  
**Platform**: Render.com (Free Tier)  
**Project**: TweetMoodAI

---

## 🎯 Overview

This guide will help you deploy both FastAPI backend and Streamlit frontend to Render.com using Docker containers.

**Render Free Tier:**
- ✅ FREE for both services
- ✅ 750 instance hours/month (enough for demos)
- ⚠️ Services spin down after 15 min inactivity (cold start ~1 min)
- ⚠️ Good for demos and low-traffic apps

---

## 📋 Prerequisites

Before starting, ensure you have:

- [x] GitHub account
- [x] Code pushed to GitHub repository
- [x] Model files in `models/sentiment_model/`
- [x] Docker images build successfully locally
- [x] Services work locally

---

## 🚀 Phase 1: Preparation (30 minutes)

### Step 1: Verify Local Setup

```powershell
# 1.1 Run pre-deployment check
powershell -ExecutionPolicy Bypass -File scripts\pre_deployment_check.ps1

# 1.2 Test backend locally
.\venv\Scripts\python.exe -m uvicorn app.main:app --reload --port 8000

# 1.3 Test frontend locally (in another terminal)
.\venv\Scripts\streamlit.exe run ui/app.py

# 1.4 Test Docker (recommended)
docker-compose up --build -d
docker-compose ps
docker-compose down
```

### Step 2: Prepare GitHub Repository

```powershell
# 2.1 Check .gitignore (ensure .env is ignored)
# .env should be in .gitignore - NEVER commit secrets!

# 2.2 Initialize git (if not already done)
git init

# 2.3 Add and commit files
git add .
git commit -m "Ready for Render deployment"

# 2.4 Create GitHub repository
# Go to https://github.com/new
# Repository name: tweetmoodai
# Description: TweetMoodAI - Sentiment Analysis App
# Visibility: Public (required for free tier)
# DON'T initialize with README (you already have files)

# 2.5 Push to GitHub
git remote add origin https://github.com/YOUR_USERNAME/tweetmoodai.git
git branch -M main
git push -u origin main
```

### Step 3: Verify Files Are Ready

Ensure these files exist:
- ✅ `Dockerfile.backend`
- ✅ `Dockerfile.frontend`
- ✅ `render.yaml` (or separate yaml files)
- ✅ `requirements.txt`
- ✅ `models/sentiment_model/` (with all model files)
- ✅ `.dockerignore` (optimizes build)

---

## 🌐 Phase 2: Render Account Setup (10 minutes)

### Step 4: Create Render Account

1. Go to https://render.com
2. Click **"Get Started for Free"**
3. Sign up with **GitHub** (recommended - easiest)
4. Authorize Render to access your GitHub account
5. Verify your email address

### Step 5: Connect GitHub Repository

1. In Render dashboard, click **"New +"** button
2. Select **"Blueprint"** (if using `render.yaml`)
   - OR select **"Web Service"** for manual deployment
3. Connect your GitHub account (if not already)
4. Select your repository: `tweetmoodai`
5. Render will detect `render.yaml` automatically

---

## 🔧 Phase 3: Deploy Backend (20 minutes)

### Option A: Using Blueprint (render.yaml) - Recommended

1. In Render dashboard, click **"New +"** → **"Blueprint"**
2. Select repository: `tweetmoodai`
3. Render will detect `render.yaml`
4. Review the configuration:
   - Service name: `tweetmoodai-backend`
   - Plan: `Free`
   - Region: Choose closest (e.g., `oregon`)
5. Click **"Apply"**
6. Wait for deployment (5-10 minutes)
7. **Note the URL**: `https://tweetmoodai-backend.onrender.com`

### Option B: Manual Deployment

1. In Render dashboard, click **"New +"** → **"Web Service"**
2. Connect repository: Select `tweetmoodai`
3. Configure:
   - **Name**: `tweetmoodai-backend`
   - **Region**: Choose closest (e.g., Oregon)
   - **Branch**: `main`
   - **Root Directory**: (leave empty)
   - **Runtime**: `Docker`
   - **Dockerfile Path**: `Dockerfile.backend`
   - **Docker Context**: `.`
   - **Instance Type**: `Free`
4. **Environment Variables** (click "Advanced"):
   ```
   API_HOST=0.0.0.0
   API_PORT=8000
   MODEL_PATH=/app/models/sentiment_model
   LOG_LEVEL=INFO
   DEBUG=False
   CORS_ORIGINS=*
   ```
5. **Health Check Path**: `/healthz`
6. Click **"Create Web Service"**
7. Wait for deployment (5-10 minutes)
8. **Note the URL**: `https://tweetmoodai-backend.onrender.com` (or similar)

### Step 6: Verify Backend Deployment

```powershell
# Test health endpoint
curl https://YOUR-BACKEND-URL.onrender.com/healthz

# Test API docs (open in browser)
# https://YOUR-BACKEND-URL.onrender.com/docs

# Test predict endpoint
curl -X POST https://YOUR-BACKEND-URL.onrender.com/predict `
  -H "Content-Type: application/json" `
  -d '{\"tweet_text\":\"This is amazing!\"}'
```

**Expected Response:**
```json
{
  "tweet_text": "This is amazing!",
  "sentiment": "positive",
  "confidence": 0.95,
  "label": "POS",
  "processing_time_ms": 45.2
}
```

---

## 🎨 Phase 4: Deploy Frontend (15 minutes)

### Option A: Using Blueprint (render.yaml)

1. In Render dashboard, click **"New +"** → **"Blueprint"**
2. Select repository: `tweetmoodai`
3. Render will detect `render.yaml` (both services)
4. **IMPORTANT**: Update `API_URL` in the frontend service:
   - Go to frontend service settings
   - Environment Variables
   - Update `API_URL` to your backend URL: `https://tweetmoodai-backend.onrender.com`
5. Click **"Apply"**
6. Wait for deployment (5-10 minutes)

### Option B: Manual Deployment

1. In Render dashboard, click **"New +"** → **"Web Service"**
2. Connect repository: Select `tweetmoodai`
3. Configure:
   - **Name**: `tweetmoodai-frontend`
   - **Region**: Same as backend
   - **Branch**: `main`
   - **Root Directory**: (leave empty)
   - **Runtime**: `Docker`
   - **Dockerfile Path**: `Dockerfile.frontend`
   - **Docker Context**: `.`
   - **Instance Type**: `Free`
4. **Environment Variables**:
   ```
   API_URL=https://YOUR-BACKEND-URL.onrender.com
   FASTAPI_URL=https://YOUR-BACKEND-URL.onrender.com
   API_TIMEOUT=60
   ```
   **IMPORTANT**: Replace `YOUR-BACKEND-URL` with your actual backend URL from Step 6
5. Click **"Create Web Service"**
6. Wait for deployment (5-10 minutes)
7. **Note the URL**: `https://tweetmoodai-frontend.onrender.com`

### Step 7: Verify Frontend Deployment

1. Open frontend URL in browser: `https://tweetmoodai-frontend.onrender.com`
2. Test all three tabs:
   - ✅ Single Analysis - Enter a tweet and analyze
   - ✅ Batch Analysis - Enter multiple tweets
   - ✅ File Upload - Upload CSV/JSON file
3. Check API connection in sidebar (should show "✅ API is running")

---

## 🔐 Phase 5: Update CORS (If Needed)

If frontend can't connect to backend:

1. Go to **backend service** in Render dashboard
2. Click **"Environment"** tab
3. Update `CORS_ORIGINS`:
   ```
   CORS_ORIGINS=https://tweetmoodai-frontend.onrender.com
   ```
   Or keep it as `*` for development (less secure)
4. Click **"Save Changes"** (auto-redeploys)

---

## ✅ Phase 6: Final Testing (10 minutes)

### Test Complete Workflow

1. **Frontend**: Open `https://tweetmoodai-frontend.onrender.com`
2. **Backend API Docs**: Open `https://tweetmoodai-backend.onrender.com/docs`
3. **Test from Frontend**:
   - Single tweet analysis
   - Batch analysis
   - File upload
4. **Verify Results**: Check that sentiment analysis works correctly

### Common Issues & Solutions

#### Issue: Frontend can't connect to backend
**Solution**: 
- Check `API_URL` environment variable in frontend service
- Verify backend URL is correct (include `https://`)
- Check CORS settings in backend

#### Issue: Backend returns 503 (Model not loaded)
**Solution**:
- Check logs in Render dashboard
- Verify model files are in repository
- Check `MODEL_PATH` environment variable

#### Issue: Service spins down after 15 minutes
**Solution**:
- This is normal for free tier
- First request after spin-down takes ~1 minute (cold start)
- Consider upgrading to paid plan for always-on

#### Issue: Build fails
**Solution**:
- Check logs in Render dashboard
- Verify Dockerfile paths are correct
- Ensure all required files are in repository
- Check `.dockerignore` isn't excluding needed files

---

## 📊 Monitoring & Maintenance

### View Logs

1. Go to Render dashboard
2. Select your service
3. Click **"Logs"** tab
4. View real-time logs

### Update Deployment

1. Make changes to your code
2. Commit and push to GitHub:
   ```powershell
   git add .
   git commit -m "Update code"
   git push
   ```
3. Render automatically detects and redeploys

### Monitor Usage

1. Go to Render dashboard
2. Check **"Usage"** tab
3. Monitor hours used (free tier: 750 hours/month)

---

## 💰 Cost Information

### Free Tier Limits

- **750 instance hours/month** (about 31 days continuous)
- **Services spin down** after 15 minutes inactivity
- **Cold start**: ~1 minute after spin-down
- **No credit card required**

### If You Exceed Limits

- Service pauses until next month
- OR upgrade to paid plan ($7/month per service)

---

## 🎯 Quick Reference

### Backend URL
```
https://tweetmoodai-backend.onrender.com
```

### Frontend URL
```
https://tweetmoodai-frontend.onrender.com
```

### API Endpoints
- Health: `https://tweetmoodai-backend.onrender.com/healthz`
- Docs: `https://tweetmoodai-backend.onrender.com/docs`
- Predict: `https://tweetmoodai-backend.onrender.com/predict`

### Environment Variables

**Backend:**
```
API_HOST=0.0.0.0
API_PORT=8000
MODEL_PATH=/app/models/sentiment_model
LOG_LEVEL=INFO
DEBUG=False
CORS_ORIGINS=*
```

**Frontend:**
```
API_URL=https://tweetmoodai-backend.onrender.com
FASTAPI_URL=https://tweetmoodai-backend.onrender.com
API_TIMEOUT=60
```

---

## 📝 Checklist

### Before Deployment
- [ ] Code pushed to GitHub
- [ ] `.env` in `.gitignore` (never commit secrets)
- [ ] Model files in repository
- [ ] Docker images build locally
- [ ] Services work locally
- [ ] Render account created

### Deployment
- [ ] Backend deployed
- [ ] Backend URL noted
- [ ] Frontend deployed with correct `API_URL`
- [ ] CORS configured
- [ ] Both services tested

### After Deployment
- [ ] Frontend connects to backend
- [ ] Sentiment analysis works
- [ ] All tabs functional
- [ ] Logs checked for errors

---

## 🚀 Next Steps

After successful deployment:

1. **Step 9**: ✅ Deployed to cloud (DONE!)
2. **Step 10**: Add monitoring and dashboard
3. **Step 11**: Complete documentation
4. **Step 12**: Local testing (already done)
5. **Step 13**: Optional dataset expansion

---

## 📞 Support

### Render Documentation
- https://render.com/docs
- https://render.com/docs/free

### Common Issues
- Check Render status: https://status.render.com
- Community: https://community.render.com

---

## ✅ Summary

**Render is FREE** for both services with:
- ✅ 750 hours/month (enough for demos)
- ✅ Automatic HTTPS
- ✅ Auto-deploy on git push
- ✅ Easy setup with Docker

**Limitations:**
- ⚠️ Services spin down after 15 min
- ⚠️ Cold start ~1 minute
- ⚠️ 750 hours/month limit

**Perfect for:**
- ✅ Demos and portfolios
- ✅ Low-traffic applications
- ✅ Learning and experimentation

---

**Last Updated**: 2025-11-03  
**Status**: ✅ Ready for Deployment


