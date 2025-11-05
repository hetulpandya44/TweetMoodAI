# Render Deployment Checklist

Use this checklist to ensure everything is ready before deploying to Render.

---

## ✅ Pre-Deployment Checklist

### Code Preparation
- [ ] All code committed to git
- [ ] Code pushed to GitHub
- [ ] `.env` file is in `.gitignore` (NEVER commit secrets)
- [ ] Model files are in `models/sentiment_model/` directory
- [ ] All required files exist:
  - [ ] `Dockerfile.backend`
  - [ ] `Dockerfile.frontend`
  - [ ] `requirements.txt`
  - [ ] `render.yaml` (or separate yaml files)
  - [ ] `app/main.py`
  - [ ] `ui/app.py`

### Local Testing
- [ ] Backend runs locally: `uvicorn app.main:app --reload`
- [ ] Frontend runs locally: `streamlit run ui/app.py`
- [ ] Docker images build: `docker-compose build`
- [ ] Docker services work: `docker-compose up -d`
- [ ] Tests pass: `pytest tests/ -v`

### GitHub Repository
- [ ] Repository created on GitHub
- [ ] Code pushed to `main` branch
- [ ] Repository is public (required for free tier)
- [ ] All files committed and pushed

---

## 🚀 Deployment Checklist

### Render Account
- [ ] Render account created
- [ ] GitHub account connected to Render
- [ ] Email verified

### Backend Deployment
- [ ] Backend service created
- [ ] Repository connected
- [ ] Dockerfile path: `Dockerfile.backend`
- [ ] Environment variables set:
  - [ ] `API_HOST=0.0.0.0`
  - [ ] `MODEL_PATH=/app/models/sentiment_model`
  - [ ] `LOG_LEVEL=INFO`
  - [ ] `CORS_ORIGINS=*`
- [ ] Health check path: `/healthz`
- [ ] Instance type: `Free`
- [ ] Deployment successful
- [ ] Backend URL noted: `https://______________.onrender.com`

### Frontend Deployment
- [ ] Frontend service created
- [ ] Repository connected
- [ ] Dockerfile path: `Dockerfile.frontend`
- [ ] Environment variables set:
  - [ ] `API_URL=https://YOUR-BACKEND-URL.onrender.com` ⚠️
  - [ ] `FASTAPI_URL=https://YOUR-BACKEND-URL.onrender.com` ⚠️
  - [ ] `API_TIMEOUT=60`
- [ ] Instance type: `Free`
- [ ] Deployment successful
- [ ] Frontend URL noted: `https://______________.onrender.com`

---

## ✅ Post-Deployment Checklist

### Testing
- [ ] Backend health check works: `/healthz`
- [ ] Backend API docs accessible: `/docs`
- [ ] Frontend loads: Opens in browser
- [ ] Frontend connects to backend (check sidebar)
- [ ] Single tweet analysis works
- [ ] Batch analysis works
- [ ] File upload works
- [ ] Results display correctly

### Configuration
- [ ] CORS updated (if needed)
- [ ] Frontend API_URL matches backend URL
- [ ] Both services running
- [ ] Logs checked for errors

---

## 📊 Monitoring Checklist

### Daily (First Week)
- [ ] Check service status
- [ ] Review logs for errors
- [ ] Test main features
- [ ] Monitor usage hours

### Weekly
- [ ] Check usage hours (free tier: 750/month)
- [ ] Review error logs
- [ ] Test all features
- [ ] Update documentation if needed

---

## 🎯 Success Criteria

Deployment is successful when:
- ✅ Backend is accessible at `/healthz`
- ✅ Frontend loads without errors
- ✅ Frontend can connect to backend
- ✅ Sentiment analysis works end-to-end
- ✅ All three tabs function correctly
- ✅ No critical errors in logs

---

## 🚨 Troubleshooting

### If deployment fails:
1. Check Render logs
2. Verify Dockerfiles are correct
3. Ensure all files are in repository
4. Check environment variables

### If frontend can't connect:
1. Verify `API_URL` is correct
2. Check CORS settings in backend
3. Ensure backend is running
4. Check backend logs

### If backend returns 503:
1. Check model files are in repository
2. Verify `MODEL_PATH` is correct
3. Check backend logs for errors
4. Ensure model files are committed

---

## 📝 Notes

- **Free Tier**: 750 hours/month, spins down after 15 min
- **Cold Start**: ~1 minute after spin-down
- **Updates**: Push to GitHub = auto-deploy
- **Cost**: FREE for both services

---

**Last Updated**: 2025-11-03


