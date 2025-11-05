# Local Testing Quick Commands Guide

**Quick reference for testing TweetMoodAI locally**

---

## 🚀 Quick Start

### 1. Run FastAPI Backend

```powershell
# Activate virtual environment (if not already)
.\venv\Scripts\Activate.ps1

# Run backend server
.\venv\Scripts\python.exe -m uvicorn app.main:app --reload --port 8000
```

**Backend will be available at:** `http://localhost:8000`

**API Docs:** `http://localhost:8000/docs`

---

### 2. Run Streamlit Frontend

```powershell
# In a new terminal, activate virtual environment
.\venv\Scripts\Activate.ps1

# Run Streamlit UI
.\venv\Scripts\streamlit.exe run ui/app.py
```

**Frontend will be available at:** `http://localhost:8501`

---

## 🧪 Test API Endpoints

### Test Health Endpoint

```powershell
# PowerShell
Invoke-WebRequest -Uri http://localhost:8000/healthz -Method GET

# Or using curl
curl http://localhost:8000/healthz
```

### Test Sentiment Analysis Endpoint

```powershell
# PowerShell
$body = @{
    tweet_text = "This is amazing!"
} | ConvertTo-Json

Invoke-WebRequest -Uri http://localhost:8000/predict -Method POST -Body $body -ContentType "application/json"

# Or using curl
curl -X POST http://localhost:8000/predict `
  -H "Content-Type: application/json" `
  -d "{\"tweet_text\":\"This is amazing!\"}"
```

### Test Batch Analysis Endpoint

```powershell
# PowerShell
$body = @{
    tweets = @("This is great!", "I hate this.", "The weather is okay.")
} | ConvertTo-Json

Invoke-WebRequest -Uri http://localhost:8000/predict/batch -Method POST -Body $body -ContentType "application/json"

# Or using curl
curl -X POST http://localhost:8000/predict/batch `
  -H "Content-Type: application/json" `
  -d "{\"tweets\":[\"This is great!\",\"I hate this.\",\"The weather is okay.\"]}"
```

### Test Metrics Endpoint

```powershell
# PowerShell
Invoke-WebRequest -Uri http://localhost:8000/metrics -Method GET

# Or using curl
curl http://localhost:8000/metrics
```

---

## 🐳 Docker Testing

### Build and Start Services

```powershell
# Build images
docker-compose build

# Start services in detached mode
docker-compose up -d

# Or start with logs visible
docker-compose up
```

### Check Service Status

```powershell
# Check running containers
docker-compose ps

# View logs
docker-compose logs -f

# View backend logs only
docker-compose logs -f backend

# View frontend logs only
docker-compose logs -f frontend
```

### Stop Services

```powershell
# Stop services
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

### Test Docker Services

```powershell
# Run test script
powershell -ExecutionPolicy Bypass -File scripts\test_docker_services.ps1
```

---

## 🧪 Run Tests

### Run All Tests

```powershell
# Activate virtual environment
.\venv\Scripts\Activate.ps1

# Run all tests
pytest tests/ -v

# Run with coverage
pytest tests/ -v --cov=app --cov-report=term-missing

# Run specific test file
pytest tests/test_api.py -v

# Run specific test
pytest tests/test_api.py::TestHealthzEndpoint::test_healthz_success -v
```

---

## 📊 Access Services

### Backend API
- **URL**: http://localhost:8000
- **Docs**: http://localhost:8000/docs
- **Health**: http://localhost:8000/healthz
- **Metrics**: http://localhost:8000/metrics

### Frontend UI
- **URL**: http://localhost:8501
- **Features**: Single analysis, batch analysis, file upload, monitoring dashboard

---

## 🔍 Troubleshooting

### Backend Not Starting

```powershell
# Check if port 8000 is in use
netstat -ano | findstr :8000

# Kill process using port 8000 (replace PID)
taskkill /PID <PID> /F

# Check logs
# Backend logs will show in terminal or check logs/app_*.log
```

### Frontend Not Starting

```powershell
# Check if port 8501 is in use
netstat -ano | findstr :8501

# Kill process using port 8501 (replace PID)
taskkill /PID <PID> /F

# Check Streamlit logs
```

### Model Not Loading

```powershell
# Check if model files exist
dir models\sentiment_model

# Check MODEL_PATH environment variable
echo $env:MODEL_PATH

# Verify model files are complete
# Should have: config.json, model.safetensors, tokenizer files, etc.
```

### API Connection Issues

```powershell
# Test API health
Invoke-WebRequest -Uri http://localhost:8000/healthz

# Check API_URL in frontend
# Should be: http://localhost:8000
```

---

## 📝 Environment Variables

### Backend (.env)

```env
API_HOST=0.0.0.0
API_PORT=8000
MODEL_PATH=models/sentiment_model
LOG_LEVEL=INFO
DEBUG=False
CORS_ORIGINS=*
```

### Frontend (.env)

```env
API_URL=http://localhost:8000
FASTAPI_URL=http://localhost:8000
API_TIMEOUT=60
```

---

## 🎯 Quick Test Checklist

- [ ] Backend starts on port 8000
- [ ] Frontend starts on port 8501
- [ ] Health endpoint returns 200
- [ ] Single sentiment analysis works
- [ ] Batch sentiment analysis works
- [ ] File upload works
- [ ] Monitoring dashboard displays metrics
- [ ] All tests pass
- [ ] Docker containers work

---

**Last Updated**: 2025-11-03

