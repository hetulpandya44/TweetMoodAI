# 🚀 Deploy to Render.com Using Repository URL

**Deploy without GitHub login - Use repository URL instead**

---

## 📋 Prerequisites

- ✅ Public GitHub repository: `https://github.com/hetulpandya44/TweetMoodAI`
- ✅ Repository URL: `https://github.com/hetulpandya44/TweetMoodAI.git`
- ✅ Render.com account (can sign up with email)
- ✅ 30-40 minutes

---

## Step 1: Create Render.com Account (5 minutes)

### Option A: Sign Up with Email (No GitHub Required)

1. Go to **https://render.com**
2. Click **"Get Started for Free"**
3. Choose **"Sign up with Email"** (instead of GitHub)
4. Enter your email address
5. Create a password
6. Verify your email address
7. Complete your profile (optional)

**✅ Checklist:**
- [ ] Render.com account created with email
- [ ] Email verified
- [ ] Logged into Render.com dashboard

---

## Step 2: Deploy Backend Service (10-15 minutes)

### Step 2.1: Create New Web Service

1. In Render.com dashboard, click **"New +"** button (top right)
2. Select **"Web Service"** from the dropdown menu
3. You'll see the service creation page

### Step 2.2: Connect Repository Using URL

1. **Choose "Public Git repository"** option
2. **Enter repository URL:**
   ```
   https://github.com/hetulpandya44/TweetMoodAI.git
   ```
3. Click **"Continue"** or **"Connect"**
4. Render will connect to your repository

### Step 2.3: Configure Backend Service

**Service Settings:**
- **Name**: `tweetmoodai-backend`
- **Region**: `Oregon` (or closest to you)
- **Branch**: `main` (or `master`)
- **Root Directory**: `.` (root of repository)
- **Runtime**: `Docker`
- **Dockerfile Path**: `Dockerfile.backend`
- **Docker Context**: `.` (current directory)
- **Plan**: `Free`

### Step 2.4: Configure Build & Deploy

**Build Command:**
```
# Leave empty - Docker handles building
```

**Start Command:**
```
# Leave empty - Docker handles starting
# Or use: uvicorn app.main:app --host 0.0.0.0 --port $PORT
```

**Docker Settings:**
- **Dockerfile Path**: `Dockerfile.backend`
- **Docker Context**: `.`

### Step 2.5: Set Environment Variables

Click **"Advanced"** → **"Environment Variables"** and add:

```
API_HOST=0.0.0.0
API_PORT=8000
MODEL_PATH=/app/models/sentiment_model
LOG_LEVEL=INFO
DEBUG=False
CORS_ORIGINS=*
```

### Step 2.6: Configure Health Check

**Health Check Path:**
```
/healthz
```

### Step 2.7: Deploy Backend

1. Review all settings
2. Click **"Create Web Service"** button
3. Render will start deploying your backend
4. **Wait 5-10 minutes** for deployment

### Step 2.8: Monitor Deployment

1. You'll see the deployment progress
2. Status will show: "Building..." → "Deploying..." → "Live"
3. Watch the logs in real-time
4. Once deployment is complete, status will show **"Live"**

### Step 2.9: Get Backend URL

1. Once deployment is complete, you'll see a URL like:
   ```
   https://tweetmoodai-backend.onrender.com
   ```
2. **Copy this URL** - you'll need it for the frontend!

### Step 2.10: Test Backend

1. Test health check:
   - Open: `https://tweetmoodai-backend.onrender.com/healthz`
   - Should return: `{"status":"ok"}` or `{"status":"unhealthy"}` (if model not loaded yet)

2. Test API docs:
   - Open: `https://tweetmoodai-backend.onrender.com/docs`
   - Should show Swagger UI documentation

**✅ Checklist:**
- [ ] Backend service created
- [ ] Repository connected via URL
- [ ] Deployment completed successfully
- [ ] Backend URL copied: `https://tweetmoodai-backend.onrender.com`
- [ ] Health check works
- [ ] API docs accessible

---

## Step 3: Deploy Frontend Service (10-15 minutes)

### Step 3.1: Create New Web Service (Again)

1. In Render.com dashboard, click **"New +"** button again
2. Select **"Web Service"** from the dropdown menu

### Step 3.2: Connect Repository Using URL (Again)

1. **Choose "Public Git repository"** option
2. **Enter the same repository URL:**
   ```
   https://github.com/hetulpandya44/TweetMoodAI.git
   ```
3. Click **"Continue"** or **"Connect"**

### Step 3.3: Configure Frontend Service

**Service Settings:**
- **Name**: `tweetmoodai-frontend`
- **Region**: `Oregon` (should match backend)
- **Branch**: `main` (or `master`)
- **Root Directory**: `.` (root of repository)
- **Runtime**: `Docker`
- **Dockerfile Path**: `Dockerfile.frontend`
- **Docker Context**: `.` (current directory)
- **Plan**: `Free`

### Step 3.4: Configure Build & Deploy

**Build Command:**
```
# Leave empty - Docker handles building
```

**Start Command:**
```
# Leave empty - Docker handles starting
# Or use: streamlit run ui/app.py --server.port $PORT --server.address 0.0.0.0
```

**Docker Settings:**
- **Dockerfile Path**: `Dockerfile.frontend`
- **Docker Context**: `.`

### Step 3.5: Set Environment Variables

Click **"Advanced"** → **"Environment Variables"** and add:

```
API_URL=https://tweetmoodai-backend.onrender.com
FASTAPI_URL=https://tweetmoodai-backend.onrender.com
API_TIMEOUT=60
```

**⚠️ Important:** Replace `https://tweetmoodai-backend.onrender.com` with your actual backend URL!

### Step 3.6: Deploy Frontend

1. Review all settings
2. Click **"Create Web Service"** button
3. Render will start deploying your frontend
4. **Wait 5-10 minutes** for deployment

### Step 3.7: Get Frontend URL

1. Once deployment is complete, you'll see a URL like:
   ```
   https://tweetmoodai-frontend.onrender.com
   ```
2. **Copy this URL** for later use

**✅ Checklist:**
- [ ] Frontend service created
- [ ] Repository connected via URL
- [ ] Environment variables configured
- [ ] Deployment completed successfully
- [ ] Frontend URL copied: `https://tweetmoodai-frontend.onrender.com`

---

## Step 4: Update Environment Variables (If Needed)

### Step 4.1: Verify Frontend Environment Variables

1. Go to Render.com dashboard
2. Click on **"tweetmoodai-frontend"** service
3. Go to **"Environment"** tab
4. Verify environment variables:
   - `API_URL` = `https://tweetmoodai-backend.onrender.com`
   - `FASTAPI_URL` = `https://tweetmoodai-backend.onrender.com`
   - `API_TIMEOUT` = `60`

### Step 4.2: Update if Needed

If environment variables are incorrect:
1. Click on the variable to edit
2. Update the value
3. Click **"Save Changes"**
4. Render will automatically redeploy (2-3 minutes)

### Step 4.3: Update Backend CORS (If Needed)

If frontend can't connect to backend:
1. Go to **"tweetmoodai-backend"** service
2. Go to **"Environment"** tab
3. Find `CORS_ORIGINS` variable
4. Update to your frontend URL:
   ```
   https://tweetmoodai-frontend.onrender.com
   ```
5. Or keep it as `*` for development
6. Click **"Save Changes"**
7. Backend will automatically redeploy

**✅ Checklist:**
- [ ] Environment variables verified
- [ ] API_URL points to backend URL
- [ ] FASTAPI_URL points to backend URL
- [ ] CORS settings updated (if needed)

---

## Step 5: Test Deployment (5 minutes)

### Step 5.1: Test Frontend

1. Open your frontend URL: `https://tweetmoodai-frontend.onrender.com`
2. The page should load
3. Check the sidebar - it should show:
   - ✅ API is running (if connected)
   - Or ❌ API is not running (if not connected)

### Step 5.2: Test Single Tweet Analysis

1. Go to **"Single Tweet Analysis"** tab
2. Enter a test tweet: "I love this project!"
3. Click **"Analyze Sentiment"**
4. You should see:
   - Sentiment: Positive/Negative/Neutral
   - Confidence score
   - Processing time

### Step 5.3: Test Batch Analysis

1. Go to **"Batch Analysis"** tab
2. Enter multiple tweets (one per line)
3. Click **"Analyze All"**
4. You should see results for all tweets

### Step 5.4: Test File Upload

1. Go to **"File Upload"** tab
2. Upload a CSV or JSON file with tweets
3. Click **"Analyze File"**
4. You should see results

### Step 5.5: Test API Docs

1. Open: `https://tweetmoodai-backend.onrender.com/docs`
2. You should see Swagger UI documentation
3. Test the `/predict` endpoint

**✅ Checklist:**
- [ ] Frontend loads correctly
- [ ] Single tweet analysis works
- [ ] Batch analysis works
- [ ] File upload works
- [ ] API docs accessible
- [ ] All features working

---

## 📊 Deployment URLs (Save These)

After deployment, you'll have:

- **Frontend URL**: `https://tweetmoodai-frontend.onrender.com`
- **Backend API**: `https://tweetmoodai-backend.onrender.com`
- **API Docs**: `https://tweetmoodai-backend.onrender.com/docs`
- **Health Check**: `https://tweetmoodai-backend.onrender.com/healthz`

---

## 🔧 Alternative: Using Blueprint (Easier Method)

If Render.com supports Blueprint deployment with repository URL:

### Step 1: Deploy Using Blueprint

1. Go to Render.com dashboard
2. Click **"New +"** → **"Blueprint"**
3. Select **"Public Git repository"**
4. Enter repository URL:
   ```
   https://github.com/hetulpandya44/TweetMoodAI.git
   ```
5. Render will detect `render.yaml` automatically
6. Review configuration
7. Click **"Apply"**
8. Wait for deployment (10-15 minutes)

### Step 2: Configure Environment Variables

1. Go to frontend service → **"Environment"** tab
2. Update `API_URL` to your backend URL
3. Update `FASTAPI_URL` to your backend URL
4. Save changes

---

## ⚠️ Important Notes

### Repository Must Be Public

- ✅ Your repository must be **public** for Render.com to access it
- ✅ Repository URL: `https://github.com/hetulpandya44/TweetMoodAI.git`
- ✅ Verify repository is accessible without authentication

### Free Tier Limitations

**What You Get:**
- ✅ Free hosting for your application
- ✅ 750 instance hours/month (about 31 days continuous)
- ✅ Automatic deployments from GitHub
- ✅ HTTPS/SSL certificates
- ✅ No credit card required

**Limitations (Accepted for Free Tier):**
- ⚠️ **Services spin down after 15 minutes of inactivity** - First request after spin-down takes ~1 minute (cold start)
- ⚠️ **No SSH access** - Cannot access server via SSH
- ⚠️ **No scaling** - Cannot scale instances up or down
- ⚠️ **No one-off jobs** - Cannot run one-time tasks or scheduled jobs
- ⚠️ **No persistent disks** - No persistent storage between deployments
- ⚠️ Cold start delay - First request after spin-down takes ~1 minute

**✅ These limitations are acceptable for:**
- Project demonstrations
- Professor submissions
- Testing and development
- Low-traffic applications
- Educational purposes

**💡 Note:** If you need SSH access, scaling, persistent disks, or always-on services, you can upgrade to a paid plan. For demonstration and submission purposes, the free tier is perfectly adequate.

### Model Files

- ⚠️ Large model files (255 MB) may take time to load
- ⚠️ Check Render.com logs for model loading status
- ⚠️ First request after deployment may take longer

---

## 🐛 Troubleshooting

### Issue 1: Repository Not Found

**Error**: "Repository not found" or "Cannot access repository"

**Solutions:**
1. Verify repository is **public**
2. Check repository URL is correct
3. Verify repository exists: https://github.com/hetulpandya44/TweetMoodAI
4. Try accessing repository URL in browser

### Issue 2: Docker Build Fails

**Error**: "Docker build failed"

**Solutions:**
1. Check Dockerfile paths are correct
2. Verify `Dockerfile.backend` and `Dockerfile.frontend` exist
3. Check Render.com logs for specific errors
4. Verify all required files are in repository

### Issue 3: Frontend Can't Connect to Backend

**Error**: "API is not running" or CORS errors

**Solutions:**
1. Verify `API_URL` environment variable is correct
2. Check backend URL is accessible
3. Update `CORS_ORIGINS` in backend environment variables
4. Verify backend is "Live" status

### Issue 4: Service Spins Down

**Error**: Service not accessible or slow response

**This is Normal for Free Tier:**
1. ✅ Services spin down after 15 minutes of inactivity (this is expected)
2. ✅ First request after spin-down takes ~1 minute (cold start)
3. ✅ This is a free tier limitation and is acceptable for demonstrations
4. ✅ Subsequent requests are fast (until next spin-down)

**Solutions:**
1. Wait ~1 minute for the service to wake up (cold start)
2. First request will be slower, but it's normal
3. For demonstrations, you can "wake up" the service by making a request a few minutes before your demo
4. If you need always-on service, consider upgrading to a paid plan (not required for demonstrations)

---

## ✅ Deployment Checklist

### Prerequisites
- [x] Public GitHub repository
- [x] Repository URL ready
- [x] Render.com account created
- [x] Email verified

### Backend Deployment
- [ ] Backend service created
- [ ] Repository connected via URL
- [ ] Environment variables configured
- [ ] Deployment completed
- [ ] Backend URL obtained
- [ ] Health check works
- [ ] API docs accessible

### Frontend Deployment
- [ ] Frontend service created
- [ ] Repository connected via URL
- [ ] Environment variables configured
- [ ] Deployment completed
- [ ] Frontend URL obtained
- [ ] Frontend loads correctly

### Testing
- [ ] Single tweet analysis works
- [ ] Batch analysis works
- [ ] File upload works
- [ ] API docs accessible
- [ ] All features working

---

## 🎉 Success!

Your TweetMoodAI application is now deployed and live on Render.com!

**You can now:**
- Share your application with others
- Show it to your professor
- Use it for demonstrations
- Submit it as part of your project

---

## 📚 Related Documentation

- **Step-by-Step Guide**: `STEP_BY_STEP_DEPLOYMENT.md`
- **Quick Launch**: `QUICK_LAUNCH.md`
- **Deployment Checklist**: `DEPLOYMENT_CHECKLIST.md`
- **Free Tier Limitations**: `FREE_TIER_LIMITATIONS.md` - Detailed information about free tier limitations
- **Troubleshooting**: See troubleshooting section above

---

**Last Updated**: 2025-01-27  
**Version**: 1.0.0

