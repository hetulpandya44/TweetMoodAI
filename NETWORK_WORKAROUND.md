# Network Issue Workaround Guide

## Current Issue

Docker cannot pull the base image `python:3.11-slim` due to DNS/network connectivity issues. The error indicates DNS resolution failure for Docker registry.

## ✅ Solution Options

### Option 1: Test Locally (Immediate)

You can run and test the application **without Docker** while fixing the network issue:

#### Start Backend Locally

```powershell
# Activate virtual environment
.\venv\Scripts\Activate.ps1

# Start FastAPI backend
uvicorn app.main:app --host 127.0.0.1 --port 8000
```

#### Start Frontend Locally

In a new terminal:

```powershell
# Activate virtual environment (if not already)
.\venv\Scripts\Activate.ps1

# Start Streamlit frontend
streamlit run ui/app.py
```

#### Automated Local Testing

```powershell
# Test backend and frontend locally
powershell -ExecutionPolicy Bypass -File scripts\test_local_services.ps1
```

**Access**:
- Backend: http://127.0.0.1:8000
- Frontend: http://127.0.0.1:8501

---

### Option 2: Fix Docker Network (Recommended)

#### Step 1: Restart Docker Desktop

```powershell
# Stop Docker Desktop
Stop-Process -Name "Docker Desktop" -Force -ErrorAction SilentlyContinue

# Wait a few seconds
Start-Sleep -Seconds 5

# Start Docker Desktop
Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"

# Wait 60 seconds for Docker to fully start
Start-Sleep -Seconds 60
```

#### Step 2: Configure DNS in Docker Desktop

1. Open **Docker Desktop**
2. Click **Settings** (gear icon)
3. Go to **Docker Engine**
4. Add DNS configuration:

```json
{
  "dns": ["8.8.8.8", "8.8.4.4", "1.1.1.1"]
}
```

5. Click **Apply & Restart**

#### Step 3: Test Image Pull

```powershell
# Try pulling the image directly
docker pull python:3.11-slim

# If successful, proceed with build
docker-compose build
```

---

### Option 3: Use Alternative Registry Mirror

If Docker Hub is blocked, configure a mirror:

1. Open **Docker Desktop** > **Settings** > **Docker Engine**
2. Add registry mirror:

```json
{
  "registry-mirrors": [
    "https://registry.docker-cn.com",
    "https://mirror.gcr.io"
  ]
}
```

3. Click **Apply & Restart**
4. Try pulling again:

```powershell
docker pull python:3.11-slim
```

---

### Option 4: Manual Image Import (Advanced)

If you have access to another machine with Docker:

1. **On the other machine**:
   ```bash
   docker pull python:3.11-slim
   docker save python:3.11-slim -o python-3.11-slim.tar
   ```

2. **Transfer the `.tar` file** to this machine

3. **On this machine**:
   ```powershell
   docker load -i python-3.11-slim.tar
   docker-compose build
   ```

---

### Option 5: Use System Proxy (If Behind Corporate Firewall)

1. Open **Docker Desktop** > **Settings** > **Resources** > **Proxies**
2. Configure proxy settings:
   - Enable manual proxy configuration
   - Enter your proxy server and port
   - Add any required authentication
3. Click **Apply & Restart**
4. Try pulling again

---

## 🔍 Diagnostic Commands

Check what's wrong:

```powershell
# Check Docker is running
docker ps

# Check network connectivity
Test-NetConnection docker.io -Port 443

# Check DNS resolution
Resolve-DnsName docker.io

# Check Docker info
docker info

# Try pulling with verbose output
docker pull python:3.11-slim --platform linux/amd64
```

---

## ✅ Verification

Once network is fixed:

```powershell
# 1. Test image pull
docker pull python:3.11-slim

# 2. Build images
docker-compose build

# 3. Start services
docker-compose up -d

# 4. Check status
docker-compose ps

# 5. Test services
powershell -ExecutionPolicy Bypass -File scripts\test_docker_services.ps1
```

---

## 📊 Current Status

- ✅ **All Docker files are correctly configured**
- ✅ **Application works locally** (test with Option 1)
- ❌ **Docker build blocked by network issue** (temporary)

Once network is resolved, Docker setup will work immediately.

---

## 🎯 Recommended Approach

1. **Test locally first** (Option 1) to verify everything works
2. **Fix Docker network** (Option 2 or 3)
3. **Run Docker setup** once network is working

This way you can continue development while resolving the network issue.

