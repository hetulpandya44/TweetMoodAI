# 🚀 Quick Launch Guide - TweetMoodAI

**Deploy to Render.com in 30 minutes!**

---

## Prerequisites
- ✅ GitHub repository: https://github.com/hetulpandya44/TweetMoodAI
- ✅ Render.com account (free)
- ✅ 30 minutes

---

## Step 1: Create Render Account (5 min)

1. Go to **https://render.com**
2. Click **"Get Started for Free"**
3. Sign up with **GitHub** (easiest)
4. Authorize Render access
5. Verify email

---

## Step 2: Deploy Backend (10 min)

1. Click **"New +"** → **"Blueprint"**
2. Select repository: **TweetMoodAI**
3. Render detects `render.yaml` automatically
4. Review:
   - Name: `tweetmoodai-backend`
   - Plan: `Free`
   - Region: `oregon` (or closest)
5. Click **"Apply"**
6. Wait 5-10 minutes
7. **Copy backend URL**: `https://tweetmoodai-backend.onrender.com`

---

## Step 3: Deploy Frontend (10 min)

1. Click **"New +"** → **"Blueprint"**
2. Select repository: **TweetMoodAI**
3. **Update Environment Variables**:
   - Go to frontend service → **Environment** tab
   - Set `API_URL` = `https://tweetmoodai-backend.onrender.com`
   - Set `FASTAPI_URL` = `https://tweetmoodai-backend.onrender.com`
4. Click **"Save Changes"**
5. Wait 5-10 minutes
6. **Copy frontend URL**: `https://tweetmoodai-frontend.onrender.com`

---

## Step 4: Test (5 min)

1. Open frontend: `https://tweetmoodai-frontend.onrender.com`
2. Test:
   - ✅ Single tweet analysis
   - ✅ Batch analysis
   - ✅ File upload
3. Check API docs: `https://tweetmoodai-backend.onrender.com/docs`

---

## ✅ Done!

Your app is live and ready for public use!

**Frontend**: `https://tweetmoodai-frontend.onrender.com`  
**Backend API**: `https://tweetmoodai-backend.onrender.com`  
**API Docs**: `https://tweetmoodai-backend.onrender.com/docs`

---

## ⚠️ Important Notes

- **Free tier**: Services spin down after 15 min inactivity (cold start ~1 min)
- **Model files**: May need to download on first startup (check logs)
- **CORS**: If frontend can't connect, update `CORS_ORIGINS` in backend env vars

---

## 🐛 Issues?

See `RENDER_DEPLOYMENT_GUIDE.md` for detailed troubleshooting.

---

**Ready to launch!** 🚀

