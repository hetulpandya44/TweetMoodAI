# Render Quick Start Guide

**Quick deployment to Render.com in 5 steps**

---

## ⚡ Quick Steps

### 1. Push to GitHub (5 min)
```powershell
git add .
git commit -m "Ready for Render"
git push
```

### 2. Create Render Account (2 min)
- Go to https://render.com
- Sign up with GitHub
- Verify email

### 3. Deploy Backend (5 min)
- Click "New +" → "Blueprint"
- Select repository: `tweetmoodai`
- Render detects `render.yaml`
- Click "Apply"
- Wait 5-10 minutes
- **Copy backend URL**: `https://tweetmoodai-backend.onrender.com`

### 4. Update Frontend API URL (2 min)
- Go to frontend service in Render
- Environment → Update `API_URL` to backend URL
- Save (auto-redeploys)

### 5. Test! (2 min)
- Open frontend: `https://tweetmoodai-frontend.onrender.com`
- Test sentiment analysis

---

## 📝 Files Created

✅ `render.yaml` - Blueprint for both services  
✅ `render-backend.yaml` - Backend only  
✅ `render-frontend.yaml` - Frontend only  
✅ `RENDER_DEPLOYMENT_GUIDE.md` - Complete guide  

---

## ⚙️ Important Notes

1. **PORT Variable**: Render sets `PORT` automatically - Dockerfiles updated to use it
2. **CORS**: Backend allows all origins (`*`) - update after frontend deploys
3. **Cold Starts**: Free tier spins down after 15 min - first request takes ~1 min
4. **Model Files**: Ensure `models/sentiment_model/` is in repository

---

## 🎯 Environment Variables

**Backend:**
- `PORT` (auto-set by Render)
- `API_HOST=0.0.0.0`
- `MODEL_PATH=/app/models/sentiment_model`

**Frontend:**
- `PORT` (auto-set by Render)
- `API_URL=https://YOUR-BACKEND-URL.onrender.com` ⚠️ UPDATE THIS!

---

## 🚨 Common Issues

**Frontend can't connect?**
→ Update `API_URL` in frontend environment variables

**Backend 503?**
→ Check model files are in repository

**Build fails?**
→ Check logs in Render dashboard

---

## 📚 Full Guide

See `RENDER_DEPLOYMENT_GUIDE.md` for complete step-by-step instructions.

---

**Time to deploy: ~15 minutes**  
**Cost: FREE**  
**Status: ✅ Ready!**


