# Pre-Deployment Checklist - Steps 9-13 Prerequisites

**Date**: 2025-11-03  
**Purpose**: Complete all prerequisites before executing Steps 9-13

---

## 🎯 Overview

Before deploying to cloud, adding monitoring, and finalizing documentation, you need to verify and prepare everything from Steps 1-8.

---

## ✅ STEP 0: Verify All Previous Steps (1-8)

### Step 1-4: Data & Training ✅
- [x] Data collection scripts working
- [x] Data preprocessing complete
- [x] Data labeling complete
- [x] Model trained successfully
- [x] Model saved to `models/sentiment_model/`
- [x] Training metrics acceptable

### Step 5: FastAPI Backend ✅
- [x] Backend API running locally
- [x] `/predict` endpoint working
- [x] `/healthz` endpoint working
- [x] Input validation working
- [x] Error handling implemented

### Step 6: Streamlit UI ✅
- [x] Frontend running locally
- [x] All tabs functional (Single, Batch, File Upload)
- [x] API connection working
- [x] Error messages displayed

### Step 7: Docker Containerization ✅
- [x] Docker images build successfully
- [x] `docker-compose up` works
- [x] Services communicate correctly
- [x] Health checks passing

### Step 8: Testing & CI/CD ✅
- [x] Pytest tests created
- [x] Tests pass locally
- [x] GitHub Actions configured
- [x] CI/CD pipeline working

---

## 🔧 STEP 1: Verify Local Environment

### 1.1 Check Python Environment
```powershell
# Verify Python version (3.11+)
python --version

# Verify virtual environment is activated
.\venv\Scripts\activate

# Verify all dependencies installed
pip list | Select-String "fastapi|streamlit|torch|transformers|pytest"
```

### 1.2 Verify Environment Variables
```powershell
# Check .env file exists and has required variables
# Copy from env.example if needed
Copy-Item env.example .env -ErrorAction SilentlyContinue

# Verify .env file has:
# - API_HOST, API_PORT
# - MODEL_PATH
# - CORS_ORIGINS
# - API_URL, API_TIMEOUT
# - Twitter API keys (if needed)
```

### 1.3 Test Local Services

#### Test Backend
```powershell
# Start backend
.\venv\Scripts\python.exe -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# In another terminal, test health
curl http://localhost:8000/healthz
curl http://localhost:8000/docs
```

#### Test Frontend
```powershell
# Start frontend (in another terminal)
.\venv\Scripts\streamlit.exe run ui/app.py

# Open browser: http://localhost:8501
# Test all three tabs
```

#### Test API Endpoint
```powershell
# Test /predict endpoint
curl -X POST http://localhost:8000/predict `
  -H "Content-Type: application/json" `
  -d '{\"tweet_text\":\"This is amazing!\"}'
```

---

## 🐳 STEP 2: Verify Docker Setup

### 2.1 Check Docker Desktop
```powershell
# Verify Docker is running
docker info

# If not running, start Docker Desktop
# Or run: powershell -ExecutionPolicy Bypass -File scripts\start_docker.ps1
```

### 2.2 Build and Test Docker Images
```powershell
# Build images
docker-compose build

# Start services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f

# Test services
powershell -ExecutionPolicy Bypass -File scripts\test_docker_services.ps1

# Stop services when done testing
docker-compose down
```

### 2.3 Verify Docker Images
```powershell
# List images
docker images | Select-String "tweetmoodai"

# Should see:
# - tweetmoodai-backend:latest
# - tweetmoodai-frontend:latest
```

---

## 🧪 STEP 3: Run All Tests

### 3.1 Run Pytest Tests
```powershell
# Install test dependencies if not already installed
pip install pytest pytest-asyncio pytest-cov httpx

# Run all tests
pytest tests/ -v

# Run with coverage
pytest tests/ -v --cov=app --cov-report=term-missing

# Verify all tests pass (some may fail if model not loaded - that's OK)
```

### 3.2 Verify Code Quality
```powershell
# Check for linter errors (if basedpyright is installed)
# Or check in your IDE
# Should have no errors in ui/app.py, app/main.py, app/sentiment_analyzer.py
```

---

## 📋 STEP 4: Prepare for Cloud Deployment

### 4.1 Choose Cloud Provider
Decide which cloud provider to use:
- [ ] **Render.com** (Easiest, free tier available)
- [ ] **AWS** (ECS/Fargate, ECR)
- [ ] **Azure** (Container Instances, ACR)
- [ ] **Google Cloud** (Cloud Run, GCR)
- [ ] **DigitalOcean** (App Platform)
- [ ] **Heroku** (Container Registry)

### 4.2 Create Cloud Accounts
- [ ] Create account on chosen provider
- [ ] Set up billing (if required)
- [ ] Note down account credentials

### 4.3 Prepare Docker Registry
- [ ] **Docker Hub**: Create account at https://hub.docker.com
- [ ] **AWS ECR**: Set up ECR repository
- [ ] **Azure ACR**: Create container registry
- [ ] **Google GCR**: Set up container registry
- [ ] Note down registry URL and credentials

### 4.4 Prepare Secrets/Environment Variables
Create a list of all environment variables needed for cloud:

```
# API Configuration
API_HOST=0.0.0.0
API_PORT=8000
MODEL_PATH=/app/models/sentiment_model
LOG_LEVEL=INFO
DEBUG=False

# CORS
CORS_ORIGINS=*

# Frontend Configuration
API_URL=https://your-api-domain.com
API_TIMEOUT=60

# Twitter API (if needed)
TWITTER_API_KEY=your_key_here
TWITTER_API_SECRET=your_secret_here
TWITTER_BEARER_TOKEN=your_token_here

# Database (if added later)
DATABASE_URL=your_database_url

# Monitoring (Step 10)
LOGURU_LEVEL=INFO
```

---

## 📝 STEP 5: Prepare Documentation

### 5.1 Current State Documentation
- [ ] Review existing README.md
- [ ] Document current architecture
- [ ] Note all endpoints and their usage
- [ ] List all environment variables

### 5.2 Gather Information for Report (Step 11)
Collect the following:
- [ ] Training metrics (accuracy, F1, etc.)
- [ ] Model architecture details
- [ ] Data sources and dataset size
- [ ] System architecture diagram (if any)
- [ ] Known issues and limitations

---

## 🔐 STEP 6: Security Preparation

### 6.1 Secure Secrets
- [ ] Never commit `.env` file to git
- [ ] Use `.gitignore` to exclude secrets
- [ ] Prepare secrets management for cloud (provider-specific)

### 6.2 Review Security
- [ ] CORS configuration appropriate
- [ ] Input validation in place
- [ ] Error messages don't leak sensitive info
- [ ] API rate limiting (if needed)

---

## 🚀 STEP 7: Quick Verification Script

Run this comprehensive check:

```powershell
# Run pre-deployment verification
powershell -ExecutionPolicy Bypass -File scripts\pre_deployment_check.ps1
```

**If this script doesn't exist, create it with:**

```powershell
# scripts/pre_deployment_check.ps1
Write-Host "Pre-Deployment Verification" -ForegroundColor Green

# Check Python
Write-Host "`n[1/7] Checking Python..." -ForegroundColor Yellow
python --version

# Check .env file
Write-Host "`n[2/7] Checking .env file..." -ForegroundColor Yellow
if (Test-Path .env) {
    Write-Host "  [OK] .env file exists" -ForegroundColor Green
} else {
    Write-Host "  [WARN] .env file missing - copy from env.example" -ForegroundColor Yellow
}

# Check Docker
Write-Host "`n[3/7] Checking Docker..." -ForegroundColor Yellow
docker info | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "  [OK] Docker is running" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] Docker is not running" -ForegroundColor Red
}

# Check model files
Write-Host "`n[4/7] Checking model files..." -ForegroundColor Yellow
if (Test-Path "models/sentiment_model/model.safetensors") {
    Write-Host "  [OK] Model files exist" -ForegroundColor Green
} else {
    Write-Host "  [WARN] Model files missing - train model first" -ForegroundColor Yellow
}

# Check tests
Write-Host "`n[5/7] Checking tests..." -ForegroundColor Yellow
if (Test-Path "tests/test_api.py") {
    Write-Host "  [OK] Test files exist" -ForegroundColor Green
} else {
    Write-Host "  [WARN] Test files missing" -ForegroundColor Yellow
}

# Check Docker images
Write-Host "`n[6/7] Checking Docker images..." -ForegroundColor Yellow
$images = docker images --format "{{.Repository}}" | Select-String "tweetmoodai"
if ($images) {
    Write-Host "  [OK] Docker images found" -ForegroundColor Green
} else {
    Write-Host "  [WARN] Docker images not built - run: docker-compose build" -ForegroundColor Yellow
}

# Summary
Write-Host "`n[7/7] Summary" -ForegroundColor Yellow
Write-Host "  Pre-deployment check complete!" -ForegroundColor Green
Write-Host "  Review warnings above before proceeding to Step 9" -ForegroundColor Cyan
```

---

## ✅ Final Checklist Before Step 9

Before proceeding to **Step 9: Deploy to Cloud**, verify:

- [ ] All local services work (backend + frontend)
- [ ] Docker containers work locally
- [ ] All tests pass (or acceptable failures)
- [ ] No linter errors
- [ ] `.env` file configured
- [ ] Model files present
- [ ] Cloud provider account created
- [ ] Docker registry account created
- [ ] Secrets list prepared
- [ ] Documentation reviewed

---

## 🎯 Next Steps After This Checklist

Once all items above are checked:

1. **Step 9**: Deploy to Cloud Platform
2. **Step 10**: Add Monitoring and Dashboard
3. **Step 11**: Complete Documentation
4. **Step 12**: Local Testing Quick Commands (already done, but verify)
5. **Step 13**: Optional Dataset Expansion

---

## 📌 Important Notes

1. **Model Loading**: Some tests may fail if model isn't loaded - that's OK for local testing
2. **Environment Variables**: Never commit `.env` with real secrets
3. **Docker Images**: Build and test locally before pushing to registry
4. **Cloud Costs**: Monitor costs when deploying to cloud
5. **Backup**: Keep local backups of model and data before cloud deployment

---

**Status**: ⏸️ **Complete this checklist before proceeding to Step 9**

---

**Last Updated**: 2025-11-03


