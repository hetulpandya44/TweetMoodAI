# 🚀 Step-by-Step Deployment Guide - TweetMoodAI

**Complete walkthrough for deploying to Render.com**

---

## 📋 Table of Contents

1. [Prerequisites Check](#1-prerequisites-check)
2. [Create Render.com Account](#2-create-rendercom-account)
3. [Deploy Backend Service](#3-deploy-backend-service)
4. [Deploy Frontend Service](#4-deploy-frontend-service)
5. [Configure Environment Variables](#5-configure-environment-variables)
6. [Test Deployment](#6-test-deployment)
7. [Troubleshooting](#7-troubleshooting)

---

## 1. Prerequisites Check ✅

Before deploying, verify these requirements:

### 1.1 Check GitHub Repository
```powershell
# Verify your code is on GitHub
git remote -v
# Should show: https://github.com/hetulpandya44/TweetMoodAI

# Check if all files are committed
git status
# Should show: "nothing to commit, working tree clean"

# If you have uncommitted changes, commit them:
git add .
git commit -m "Ready for deployment"
git push
```

**✅ Checklist:**
- [ ] Code is pushed to GitHub
- [ ] All changes are committed
- [ ] Repository is accessible at: https://github.com/hetulpandya44/TweetMoodAI

### 1.2 Verify Required Files
Check that these files exist in your repository:
- [ ] `render.yaml` - Deployment configuration
- [ ] `Dockerfile.backend` - Backend Dockerfile
- [ ] `Dockerfile.frontend` - Frontend Dockerfile
- [ ] `requirements.txt` - Python dependencies
- [ ] `app/main.py` - Backend application
- [ ] `ui/app.py` - Frontend application
- [ ] `models/sentiment_model/` - Model files (at least config files)

### 1.3 Test Locally (Optional but Recommended)
```powershell
# Test backend locally
uvicorn app.main:app --reload
# Should run on http://localhost:8000

# Test frontend locally (in another terminal)
streamlit run ui/app.py
# Should run on http://localhost:8501
```

**✅ Checklist:**
- [ ] Backend runs locally
- [ ] Frontend runs locally
- [ ] Features work correctly

---

## 2. Create Render.com Account 🆕

### Step 2.1: Go to Render.com
1. Open your web browser
2. Go to: **https://render.com**
3. You'll see the Render.com homepage

### Step 2.2: Sign Up
1. Click the **"Get Started for Free"** button (usually in the top right)
2. You'll see sign-up options:
   - **GitHub** (Recommended - easiest)
   - **Google**
   - **Email**

### Step 2.3: Sign Up with GitHub (Recommended)
1. Click **"Sign up with GitHub"**
2. You'll be redirected to GitHub
3. Click **"Authorize Render"** to allow Render access to your GitHub account
4. You'll be redirected back to Render.com

### Step 2.4: Verify Email
1. Check your email inbox
2. Look for an email from Render.com
3. Click the verification link
4. Your account is now verified!

**✅ Checklist:**
- [ ] Render.com account created
- [ ] GitHub connected (if using GitHub sign-up)
- [ ] Email verified
- [ ] Logged into Render.com dashboard

---

## 3. Deploy Backend Service 🖥️

### Step 3.1: Create New Blueprint
1. In Render.com dashboard, click **"New +"** button (top right)
2. Select **"Blueprint"** from the dropdown menu
3. You'll see the Blueprint creation page

### Step 3.2: Connect GitHub Repository
1. Render will show your GitHub repositories
2. Find and select **"hetulpandya44/TweetMoodAI"**
3. Click on the repository name
4. Render will detect the `render.yaml` file automatically

### Step 3.3: Review Backend Configuration
Render will show the backend service configuration from `render.yaml`:
- **Name**: `tweetmoodai-backend`
- **Type**: Web Service
- **Environment**: Docker
- **Dockerfile**: `Dockerfile.backend`
- **Plan**: Free
- **Region**: Oregon (or your selected region)

**Review these settings:**
- ✅ Service name: `tweetmoodai-backend`
- ✅ Plan: `Free` (for free tier)
- ✅ Region: Choose closest to you (Oregon is default)
- ✅ Health check path: `/healthz`

### Step 3.4: Environment Variables (Backend)
Render will automatically set these from `render.yaml`:
- `API_HOST` = `0.0.0.0`
- `API_PORT` = `8000`
- `MODEL_PATH` = `/app/models/sentiment_model`
- `LOG_LEVEL` = `INFO`
- `DEBUG` = `False`
- `CORS_ORIGINS` = `*` (we'll update this later)

**You can verify these in the Environment Variables section.**

### Step 3.5: Apply Configuration
1. Review all settings
2. Click **"Apply"** button at the bottom
3. Render will start deploying your backend

### Step 3.6: Wait for Deployment
1. You'll see the deployment progress
2. Status will show: "Building..." → "Deploying..." → "Live"
3. **This takes 5-10 minutes** (first deployment is slower)
4. You can watch the logs in real-time

**What's happening:**
- Render is building the Docker image
- Installing dependencies from `requirements.txt`
- Copying your application code
- Starting the FastAPI server

### Step 3.7: Get Backend URL
1. Once deployment is complete, status will show **"Live"**
2. You'll see a URL like: `https://tweetmoodai-backend.onrender.com`
3. **Copy this URL** - you'll need it for the frontend!

### Step 3.8: Test Backend
1. Click on the backend service name
2. Go to **"Logs"** tab to see application logs
3. Test the health check:
   - Open: `https://tweetmoodai-backend.onrender.com/healthz`
   - Should return: `{"status":"ok"}` or `{"status":"unhealthy"}` (if model not loaded yet)
4. Test API docs:
   - Open: `https://tweetmoodai-backend.onrender.com/docs`
   - Should show Swagger UI documentation

**✅ Checklist:**
- [ ] Backend service created
- [ ] Deployment completed successfully
- [ ] Backend URL copied: `https://tweetmoodai-backend.onrender.com`
- [ ] Health check works
- [ ] API docs accessible

**⚠️ Note:** If health check shows "unhealthy", the model might be loading. Check logs for details.

---

## 4. Deploy Frontend Service 🎨

### Step 4.1: Create New Blueprint (Again)
1. In Render.com dashboard, click **"New +"** button again
2. Select **"Blueprint"** from the dropdown
3. Select the same repository: **"hetulpandya44/TweetMoodAI"**

### Step 4.2: Review Frontend Configuration
Render will detect the frontend service from `render.yaml`:
- **Name**: `tweetmoodai-frontend`
- **Type**: Web Service
- **Environment**: Docker
- **Dockerfile**: `Dockerfile.frontend`
- **Plan**: Free
- **Region**: Oregon (should match backend)

### Step 4.3: Apply Frontend Configuration
1. Review the settings
2. Click **"Apply"** button
3. Render will start deploying your frontend
4. **Wait 5-10 minutes** for deployment

### Step 4.4: Get Frontend URL
1. Once deployment is complete, status will show **"Live"**
2. You'll see a URL like: `https://tweetmoodai-frontend.onrender.com`
3. **Copy this URL** for later use

**✅ Checklist:**
- [ ] Frontend service created
- [ ] Deployment completed successfully
- [ ] Frontend URL copied: `https://tweetmoodai-frontend.onrender.com`

---

## 5. Configure Environment Variables 🔧

### Step 5.1: Update Frontend Environment Variables
The frontend needs to know where the backend is located.

1. Go to Render.com dashboard
2. Click on **"tweetmoodai-frontend"** service
3. Go to **"Environment"** tab
4. You'll see environment variables

### Step 5.2: Update API_URL
1. Find the `API_URL` variable
2. Click on it to edit
3. Set the value to your backend URL:
   ```
   https://tweetmoodai-backend.onrender.com
   ```
4. Click **"Save Changes"**

### Step 5.3: Update FASTAPI_URL
1. Find the `FASTAPI_URL` variable
2. Click on it to edit
3. Set the value to the same backend URL:
   ```
   https://tweetmoodai-backend.onrender.com
   ```
4. Click **"Save Changes"**

### Step 5.4: Verify Environment Variables
Your frontend environment variables should be:
- `API_URL` = `https://tweetmoodai-backend.onrender.com`
- `FASTAPI_URL` = `https://tweetmoodai-backend.onrender.com`
- `API_TIMEOUT` = `60`

### Step 5.5: Redeploy Frontend
1. After updating environment variables, Render will automatically redeploy
2. Wait for redeployment to complete (2-3 minutes)
3. Status will show **"Live"** when ready

**✅ Checklist:**
- [ ] `API_URL` updated to backend URL
- [ ] `FASTAPI_URL` updated to backend URL
- [ ] Frontend redeployed successfully

### Step 5.6: Update Backend CORS (Optional)
If frontend can't connect to backend, update CORS settings:

1. Go to **"tweetmoodai-backend"** service
2. Go to **"Environment"** tab
3. Find `CORS_ORIGINS` variable
4. Update to your frontend URL:
   ```
   https://tweetmoodai-frontend.onrender.com
   ```
5. Or keep it as `*` for development (allows all origins)
6. Click **"Save Changes"**
7. Backend will automatically redeploy

**✅ Checklist:**
- [ ] CORS settings updated (if needed)
- [ ] Backend redeployed (if CORS was updated)

---

## 6. Test Deployment 🧪

### Step 6.1: Test Frontend
1. Open your frontend URL: `https://tweetmoodai-frontend.onrender.com`
2. The page should load
3. Check the sidebar - it should show:
   - ✅ API is running (if connected)
   - Or ❌ API is not running (if not connected)

### Step 6.2: Test Single Tweet Analysis
1. Go to **"Single Tweet Analysis"** tab
2. Enter a test tweet: "I love this project!"
3. Click **"Analyze Sentiment"**
4. You should see:
   - Sentiment: Positive/Negative/Neutral
   - Confidence score
   - Processing time

**✅ Checklist:**
- [ ] Frontend loads correctly
- [ ] Single tweet analysis works
- [ ] Results are displayed

### Step 6.3: Test Batch Analysis
1. Go to **"Batch Analysis"** tab
2. Enter multiple tweets (one per line):
   ```
   I love this project!
   This is terrible
   It's okay, nothing special
   ```
3. Click **"Analyze All"**
4. You should see results for all tweets

**✅ Checklist:**
- [ ] Batch analysis works
- [ ] All tweets are analyzed
- [ ] Results are displayed in a table

### Step 6.4: Test File Upload
1. Go to **"File Upload"** tab
2. Upload a CSV or JSON file with tweets
3. Click **"Analyze File"**
4. You should see:
   - Processing progress
   - Results for all tweets
   - Option to download results

**✅ Checklist:**
- [ ] File upload works
- [ ] File is processed correctly
- [ ] Results can be downloaded

### Step 6.5: Test API Docs
1. Open: `https://tweetmoodai-backend.onrender.com/docs`
2. You should see Swagger UI documentation
3. Test the `/predict` endpoint:
   - Click on **"POST /predict"**
   - Click **"Try it out"**
   - Enter test data:
     ```json
     {
       "text": "I love this project!"
     }
     ```
   - Click **"Execute"**
   - You should see the response with sentiment

**✅ Checklist:**
- [ ] API docs accessible
- [ ] API endpoints work
- [ ] Responses are correct

### Step 6.6: Test Health Check
1. Open: `https://tweetmoodai-backend.onrender.com/healthz`
2. You should see:
   ```json
   {
     "status": "ok",
     "model_loaded": true,
     "version": "1.0.0"
   }
   ```

**✅ Checklist:**
- [ ] Health check works
- [ ] Status shows "ok"
- [ ] Model is loaded

---

## 7. Troubleshooting 🔧

### Issue 1: Frontend Can't Connect to Backend

**Symptoms:**
- Frontend shows "API is not running"
- Errors in browser console
- CORS errors

**Solutions:**
1. **Check Environment Variables:**
   - Go to frontend service → Environment tab
   - Verify `API_URL` is set to backend URL
   - Verify `FASTAPI_URL` is set to backend URL
   - Make sure URLs include `https://`

2. **Check Backend CORS:**
   - Go to backend service → Environment tab
   - Verify `CORS_ORIGINS` includes frontend URL
   - Or set to `*` for development

3. **Check Backend Status:**
   - Verify backend is "Live"
   - Check backend logs for errors
   - Test backend URL directly: `https://tweetmoodai-backend.onrender.com/healthz`

4. **Redeploy Services:**
   - Update environment variables
   - Wait for automatic redeployment
   - Test again

### Issue 2: Backend Shows "Unhealthy"

**Symptoms:**
- Health check returns "unhealthy"
- Model not loaded

**Solutions:**
1. **Check Logs:**
   - Go to backend service → Logs tab
   - Look for error messages
   - Check if model is loading

2. **Check Model Files:**
   - Verify model files are in repository
   - Check `models/sentiment_model/` directory
   - Verify model config files exist

3. **Check Model Path:**
   - Verify `MODEL_PATH` environment variable
   - Should be: `/app/models/sentiment_model`

4. **Wait for Model to Load:**
   - Large models take time to load
   - Wait 2-3 minutes after deployment
   - Check logs for "Model loaded" message

### Issue 3: Deployment Fails

**Symptoms:**
- Deployment status shows "Failed"
- Build errors in logs

**Solutions:**
1. **Check Logs:**
   - Go to service → Logs tab
   - Look for error messages
   - Common issues:
     - Missing files
     - Docker build errors
     - Dependency installation errors

2. **Check Dockerfile:**
   - Verify `Dockerfile.backend` is correct
   - Verify `Dockerfile.frontend` is correct
   - Check file paths

3. **Check Requirements:**
   - Verify `requirements.txt` is correct
   - Check for version conflicts
   - Test locally first

4. **Check Repository:**
   - Verify all files are committed
   - Verify files are pushed to GitHub
   - Check repository is accessible

### Issue 4: Services Spin Down (Free Tier)

**Symptoms:**
- Services are not accessible
- First request is slow (~1 minute)

**Solutions:**
1. **This is Normal:**
   - Free tier services spin down after 15 min inactivity
   - First request after spin-down takes ~1 minute (cold start)
   - Subsequent requests are fast

2. **Keep Services Alive:**
   - Make requests periodically
   - Use a monitoring service to ping your services
   - Or upgrade to paid plan for always-on

### Issue 5: Model File Too Large

**Symptoms:**
- Deployment fails
- Build timeout
- Model file not found

**Solutions:**
1. **Check Model Size:**
   - Model file (`model.safetensors`) is 255 MB
   - GitHub has file size limits
   - Render has build time limits

2. **Options:**
   - Use model hosting (Hugging Face)
   - Download model during build
   - Use smaller model
   - Exclude model from repo, download on first startup

3. **Update Dockerfile:**
   - Add model download step
   - Or use model from Hugging Face Hub

---

## ✅ Deployment Complete!

### Your Deployment URLs

**Frontend:**
```
https://tweetmoodai-frontend.onrender.com
```

**Backend API:**
```
https://tweetmoodai-backend.onrender.com
```

**API Docs:**
```
https://tweetmoodai-backend.onrender.com/docs
```

**Health Check:**
```
https://tweetmoodai-backend.onrender.com/healthz
```

### Next Steps

1. **Save Your URLs:**
   - Save all URLs for future reference
   - Share with your professor
   - Add to documentation

2. **Test Thoroughly:**
   - Test all features
   - Test on different devices
   - Test with different data

3. **Monitor Deployment:**
   - Check logs regularly
   - Monitor service status
   - Watch for errors

4. **Prepare for Demo:**
   - See `DEMONSTRATION_SCRIPT.md`
   - Prepare sample data
   - Test demo scenarios

5. **Prepare Submission:**
   - See `PROJECT_SUBMISSION_GUIDE.md`
   - Prepare source code submission
   - Document deployment process

---

## 📋 Final Checklist

### Deployment
- [ ] Render.com account created
- [ ] Backend deployed successfully
- [ ] Frontend deployed successfully
- [ ] Environment variables configured
- [ ] Services are "Live"

### Testing
- [ ] Frontend loads correctly
- [ ] Backend API works
- [ ] Single tweet analysis works
- [ ] Batch analysis works
- [ ] File upload works
- [ ] API docs accessible
- [ ] Health check works

### Documentation
- [ ] URLs saved
- [ ] Deployment documented
- [ ] Ready for professor demo
- [ ] Ready for submission

---

## 🎉 Congratulations!

Your TweetMoodAI application is now deployed and live on Render.com!

**You can now:**
- Share your application with others
- Show it to your professor
- Use it for demonstrations
- Submit it as part of your project

**Good luck with your project! 🚀**

---

**Last Updated**: 2025-01-27  
**Version**: 1.0.0

