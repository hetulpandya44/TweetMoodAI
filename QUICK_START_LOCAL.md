# 🚀 Quick Start - Running Locally

**How to run TweetMoodAI on your local machine**

---

## ⚠️ Important: Activate Virtual Environment First!

Before running any commands, you **must** activate your virtual environment.

---

## Step 1: Activate Virtual Environment

### Option 1: PowerShell (Recommended for Windows)

```powershell
# Navigate to project directory
cd C:\Users\hetul\TweetMoodAI

# Activate virtual environment
.\venv\Scripts\Activate.ps1
```

**If you get an execution policy error**, run this first:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Option 2: Command Prompt (CMD)

```cmd
# Navigate to project directory
cd C:\Users\hetul\TweetMoodAI

# Activate virtual environment
venv\Scripts\activate.bat
```

### Option 3: Using Python Directly

```powershell
# Use Python from virtual environment directly
.\venv\Scripts\python.exe -m uvicorn app.main:app --reload
.\venv\Scripts\python.exe -m streamlit run ui/app.py
```

---

## Step 2: Verify Virtual Environment is Activated

After activation, you should see `(venv)` in your terminal prompt:

```powershell
(venv) PS C:\Users\hetul\TweetMoodAI>
```

If you don't see `(venv)`, the virtual environment is not activated!

---

## Step 3: Run Backend (FastAPI)

### Terminal 1: Start Backend

```powershell
# Make sure virtual environment is activated
# You should see (venv) in your prompt

# Run backend
uvicorn app.main:app --reload

# Or if uvicorn is not found, use:
python -m uvicorn app.main:app --reload

# Or use full path:
.\venv\Scripts\python.exe -m uvicorn app.main:app --reload
```

**Backend will run on**: http://localhost:8000

**API Docs**: http://localhost:8000/docs

---

## Step 4: Run Frontend (Streamlit)

### Terminal 2: Start Frontend (Open a NEW terminal)

```powershell
# Navigate to project directory
cd C:\Users\hetul\TweetMoodAI

# Activate virtual environment
.\venv\Scripts\Activate.ps1

# Run frontend
streamlit run ui/app.py

# Or if streamlit is not found, use:
python -m streamlit run ui/app.py

# Or use full path:
.\venv\Scripts\python.exe -m streamlit run ui/app.py
```

**Frontend will run on**: http://localhost:8501

---

## Step 5: Access Application

1. **Backend API**: http://localhost:8000
2. **API Docs**: http://localhost:8000/docs
3. **Frontend**: http://localhost:8501

---

## 🔧 Troubleshooting

### Issue 1: "uvicorn/streamlit is not recognized"

**Solution**: Virtual environment is not activated!

1. Make sure you activated the virtual environment:
   ```powershell
   .\venv\Scripts\Activate.ps1
   ```

2. Verify activation:
   - You should see `(venv)` in your prompt
   - Check if commands are available:
     ```powershell
     Get-Command uvicorn
     Get-Command streamlit
     ```

3. If still not working, use Python module directly:
   ```powershell
   python -m uvicorn app.main:app --reload
   python -m streamlit run ui/app.py
   ```

### Issue 2: Execution Policy Error in PowerShell

**Error**: "cannot be loaded because running scripts is disabled on this system"

**Solution**:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Then try activating again:
```powershell
.\venv\Scripts\Activate.ps1
```

### Issue 3: Dependencies Not Installed

**Solution**: Install dependencies:

```powershell
# Activate virtual environment first
.\venv\Scripts\Activate.ps1

# Install dependencies
pip install -r requirements.txt
```

### Issue 4: Port Already in Use

**Error**: "Address already in use"

**Solution**: 
1. Find and stop the process using the port:
   ```powershell
   # For port 8000 (backend)
   netstat -ano | findstr :8000
   taskkill /PID <PID> /F
   
   # For port 8501 (frontend)
   netstat -ano | findstr :8501
   taskkill /PID <PID> /F
   ```

2. Or use a different port:
   ```powershell
   # Backend on different port
   uvicorn app.main:app --reload --port 8001
   
   # Frontend on different port
   streamlit run ui/app.py --server.port 8502
   ```

### Issue 5: Model Not Found

**Error**: "Model not loaded" or "File not found"

**Solution**: 
1. Verify model files exist:
   ```powershell
   Test-Path models\sentiment_model\model.safetensors
   ```

2. Check model path in environment variables:
   ```powershell
   # Check .env file (if exists)
   Get-Content .env
   ```

3. Model files should be in: `models/sentiment_model/`

---

## 📋 Quick Reference

### Activate Virtual Environment
```powershell
.\venv\Scripts\Activate.ps1
```

### Run Backend
```powershell
uvicorn app.main:app --reload
# Or
python -m uvicorn app.main:app --reload
```

### Run Frontend
```powershell
streamlit run ui/app.py
# Or
python -m streamlit run ui/app.py
```

### Deactivate Virtual Environment
```powershell
deactivate
```

### Check if Virtual Environment is Activated
- Look for `(venv)` in your terminal prompt
- Or run: `python --version` (should show Python from venv)

---

## ✅ Verification Checklist

Before running, verify:

- [ ] Virtual environment exists: `Test-Path venv`
- [ ] Virtual environment is activated: See `(venv)` in prompt
- [ ] Dependencies installed: `pip list | Select-String "uvicorn|streamlit"`
- [ ] Model files exist: `Test-Path models\sentiment_model\config.json`
- [ ] Ports available: 8000 (backend), 8501 (frontend)

---

## 🎯 Complete Setup Example

```powershell
# 1. Navigate to project
cd C:\Users\hetul\TweetMoodAI

# 2. Activate virtual environment
.\venv\Scripts\Activate.ps1

# 3. Verify activation (should see (venv) in prompt)
# (venv) PS C:\Users\hetul\TweetMoodAI>

# 4. Check if commands are available
uvicorn --version
streamlit --version

# 5. Run backend (Terminal 1)
uvicorn app.main:app --reload

# 6. Run frontend (Terminal 2 - NEW terminal)
# Activate venv again in new terminal
.\venv\Scripts\Activate.ps1
streamlit run ui/app.py

# 7. Open browser
# Backend: http://localhost:8000/docs
# Frontend: http://localhost:8501
```

---

## 🆘 Still Having Issues?

1. **Check Python version**:
   ```powershell
   python --version
   # Should be Python 3.10 or higher
   ```

2. **Recreate virtual environment** (if needed):
   ```powershell
   # Remove old venv
   Remove-Item -Recurse -Force venv
   
   # Create new venv
   python -m venv venv
   
   # Activate
   .\venv\Scripts\Activate.ps1
   
   # Install dependencies
   pip install -r requirements.txt
   ```

3. **Check requirements.txt**:
   ```powershell
   Get-Content requirements.txt
   ```

4. **Verify file structure**:
   ```powershell
   Test-Path app\main.py
   Test-Path ui\app.py
   Test-Path requirements.txt
   ```

---

## 📚 Next Steps

After running locally:
1. Test all features
2. Verify everything works
3. Deploy to Render.com (see `STEP_BY_STEP_DEPLOYMENT.md`)
4. Show to professor
5. Submit source code

---

**Last Updated**: 2025-01-27  
**Version**: 1.0.0

