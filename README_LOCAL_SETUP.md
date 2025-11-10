# 🚀 Quick Start - Local Setup

**Simple guide to run TweetMoodAI on your local machine**

---

## ✅ Problem Solved: "uvicorn/streamlit is not recognized"

The issue was that **uvicorn was not installed** in your virtual environment. I've installed it for you!

---

## 🎯 Quick Start (3 Steps)

### Step 1: Activate Virtual Environment

```powershell
.\venv\Scripts\Activate.ps1
```

**You should see `(venv)` in your prompt after activation.**

### Step 2: Start Backend (Terminal 1)

**Option A: Use the helper script (Easiest)**
```powershell
.\start_backend.ps1
```

**Option B: Manual command**
```powershell
# Make sure virtual environment is activated first!
python -m uvicorn app.main:app --reload
```

**Backend runs on**: http://localhost:8000  
**API Docs**: http://localhost:8000/docs

### Step 3: Start Frontend (Terminal 2 - NEW terminal)

**Option A: Use the helper script (Easiest)**
```powershell
.\start_frontend.ps1
```

**Option B: Manual command**
```powershell
# Make sure virtual environment is activated first!
python -m streamlit run ui/app.py
```

**Frontend runs on**: http://localhost:8501

---

## 📋 Complete Setup Example

### Terminal 1: Backend
```powershell
# Navigate to project
cd C:\Users\hetul\TweetMoodAI

# Activate virtual environment
.\venv\Scripts\Activate.ps1

# Start backend
python -m uvicorn app.main:app --reload
```

### Terminal 2: Frontend
```powershell
# Navigate to project
cd C:\Users\hetul\TweetMoodAI

# Activate virtual environment
.\venv\Scripts\Activate.ps1

# Start frontend
python -m streamlit run ui/app.py
```

---

## 🔧 Helper Scripts

I've created helper scripts to make it easier:

### `start_backend.ps1`
- Activates virtual environment
- Checks if uvicorn is installed
- Starts the backend server
- Shows URLs and instructions

### `start_frontend.ps1`
- Activates virtual environment
- Checks if streamlit is installed
- Starts the frontend server
- Shows URLs and instructions

### Usage:
```powershell
# Start backend
.\start_backend.ps1

# Start frontend (in another terminal)
.\start_frontend.ps1
```

---

## ✅ Verification

### Check if Virtual Environment is Activated
Look for `(venv)` in your terminal prompt:
```powershell
(venv) PS C:\Users\hetul\TweetMoodAI>
```

### Check if Commands Work
```powershell
# Check uvicorn
python -m uvicorn --version

# Check streamlit
python -m streamlit --version

# Or use the executable directly
.\venv\Scripts\python.exe -m uvicorn --version
.\venv\Scripts\python.exe -m streamlit --version
```

---

## 🐛 Troubleshooting

### Issue: "uvicorn/streamlit is not recognized"

**Solution 1: Use Python module syntax**
```powershell
# Instead of: uvicorn app.main:app --reload
# Use: python -m uvicorn app.main:app --reload

# Instead of: streamlit run ui/app.py
# Use: python -m streamlit run ui/app.py
```

**Solution 2: Activate virtual environment first**
```powershell
.\venv\Scripts\Activate.ps1
```

**Solution 3: Use full path**
```powershell
.\venv\Scripts\python.exe -m uvicorn app.main:app --reload
.\venv\Scripts\python.exe -m streamlit run ui/app.py
```

### Issue: Execution Policy Error

**Error**: "cannot be loaded because running scripts is disabled"

**Solution**:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Issue: Dependencies Not Installed

**Solution**: Install dependencies
```powershell
.\venv\Scripts\python.exe -m pip install -r requirements.txt
```

---

## 📚 More Information

- **Detailed Guide**: See `QUICK_START_LOCAL.md`
- **Deployment Guide**: See `STEP_BY_STEP_DEPLOYMENT.md`
- **Project README**: See `README.md`

---

## 🎉 Success!

Once both servers are running:
- ✅ Backend: http://localhost:8000/docs
- ✅ Frontend: http://localhost:8501

You can now:
1. Test the application locally
2. Verify everything works
3. Deploy to Render.com
4. Show to your professor

---

**Last Updated**: 2025-01-27  
**Version**: 1.0.0

