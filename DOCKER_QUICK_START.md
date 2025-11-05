# Docker Quick Start Guide

## 🚀 Complete Setup (Once Network is Fixed)

### Automated Setup (Recommended)

Run the complete setup script:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\docker_complete_setup.ps1
```

This script will:
1. ✅ Check Docker is running
2. ✅ Build all images
3. ✅ Start services
4. ✅ Wait for services to be ready
5. ✅ Check service status
6. ✅ Test backend health
7. ✅ Test frontend accessibility

### Manual Setup

#### Step 1: Build Images

```bash
docker-compose build
```

**Expected Output**: Images built successfully for `backend` and `frontend`

#### Step 2: Start Services

```bash
# Start in detached mode (background)
docker-compose up -d

# OR start with logs visible
docker-compose up
```

#### Step 3: Check Status

```bash
docker-compose ps
```

**Expected Output**: Both services showing `Up` status

#### Step 4: View Logs (Optional)

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f frontend
```

#### Step 5: Test Services

```bash
# Automated testing
powershell -ExecutionPolicy Bypass -File scripts\test_docker_services.ps1

# Manual testing
curl http://localhost:8000/healthz
curl http://localhost:8000/
curl http://localhost:8501/
```

---

## 🌐 Access Services

Once services are running:

- **Backend API**: http://localhost:8000
  - Root endpoint with API info
  - Health check: http://localhost:8000/healthz
  - API Documentation: http://localhost:8000/docs
  
- **Frontend UI**: http://localhost:8501
  - Streamlit web interface
  - Connects to backend automatically

---

## 🔍 Verify Everything Works

### Test Backend

```powershell
# Health check
Invoke-WebRequest -Uri "http://localhost:8000/healthz"

# Root endpoint
Invoke-WebRequest -Uri "http://localhost:8000/"

# Test prediction
$body = @{
    tweet_text = "This is amazing!"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8000/predict" `
    -Method POST `
    -ContentType "application/json" `
    -Body $body
```

### Test Frontend

1. Open browser to http://localhost:8501
2. You should see the TweetMoodAI interface
3. Try analyzing a tweet in the "Single Analysis" tab
4. Check that API status shows "✅ API is running"

---

## 🛠️ Common Commands

### Service Management

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# Restart services
docker-compose restart

# Restart specific service
docker-compose restart backend
docker-compose restart frontend

# View logs
docker-compose logs -f

# Check status
docker-compose ps

# View resource usage
docker stats
```

### Image Management

```bash
# Rebuild specific service
docker-compose build backend
docker-compose build frontend

# Rebuild without cache
docker-compose build --no-cache

# Remove all images
docker-compose down --rmi all

# Clean up unused images
docker image prune -a
```

### Troubleshooting

```bash
# Check service logs
docker-compose logs backend
docker-compose logs frontend

# Execute command in container
docker-compose exec backend bash
docker-compose exec frontend bash

# Check container resources
docker stats

# Inspect network
docker network inspect tweetmoodai_tweetmoodai-network
```

---

## ⚠️ Troubleshooting

### Services Not Starting

1. **Check logs**:
   ```bash
   docker-compose logs
   ```

2. **Check ports**:
   ```bash
   netstat -ano | findstr :8000
   netstat -ano | findstr :8501
   ```

3. **Restart Docker Desktop**:
   ```powershell
   .\scripts\start_docker.ps1
   ```

### Network Issues

See `DOCKER_BUILD_ISSUE.md` for detailed network troubleshooting.

Quick fixes:
1. Restart Docker Desktop
2. Check firewall settings
3. Configure DNS in Docker Desktop settings
4. Try different network (WiFi/mobile hotspot)

### Build Fails

1. **Check network connectivity**:
   ```bash
   docker pull python:3.11-slim
   ```

2. **Clear Docker cache**:
   ```bash
   docker system prune -a
   ```

3. **Rebuild without cache**:
   ```bash
   docker-compose build --no-cache
   ```

---

## 📊 Expected Service Status

After successful start:

```
NAME                   STATUS
tweetmoodai-backend    Up (healthy)
tweetmoodai-frontend   Up (healthy)
```

Both services should show:
- Status: `Up`
- Health: `healthy` (after health checks complete)
- Ports: `8000:8000` (backend) and `8501:8501` (frontend)

---

## ✅ Verification Checklist

After setup, verify:

- [ ] `docker-compose ps` shows both services as `Up`
- [ ] Backend health check returns 200: `curl http://localhost:8000/healthz`
- [ ] Frontend accessible: `curl http://localhost:8501/`
- [ ] API docs accessible: http://localhost:8000/docs
- [ ] Frontend UI loads in browser: http://localhost:8501
- [ ] Sentiment prediction works in UI
- [ ] Backend and frontend can communicate (frontend shows API is running)

---

## 🎯 Quick Reference

```bash
# Complete workflow
docker-compose build          # Build images
docker-compose up -d          # Start services
docker-compose ps             # Check status
docker-compose logs -f        # View logs
docker-compose down           # Stop services

# Testing
curl http://localhost:8000/healthz
powershell -ExecutionPolicy Bypass -File scripts\test_docker_services.ps1

# Access
# Backend:  http://localhost:8000
# Frontend: http://localhost:8501
```

---

**Once network is resolved, everything is ready to go!** 🚀

