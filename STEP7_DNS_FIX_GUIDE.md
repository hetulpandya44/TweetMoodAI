# Docker DNS Fix - Step by Step Guide

## 🔴 Problem

Docker cannot pull images because it cannot resolve DNS for Docker Hub.

**Error**: `dial tcp: lookup docker-images-prod...r2.cloudflarestorage.com: no such host`

---

## ✅ Solution: Configure DNS in Docker Desktop

### Method 1: Via Docker Desktop GUI (Recommended)

#### Step 1: Open Docker Desktop
- Click the Docker Desktop icon in your system tray (or Start Menu)
- Wait for Docker Desktop to fully open

#### Step 2: Open Settings
- Click the **Settings** icon (⚙️ gear) in the top right corner of Docker Desktop

#### Step 3: Navigate to Docker Engine
- In the left sidebar, click **"Docker Engine"**
- You'll see a JSON editor on the right

#### Step 4: Edit the JSON Configuration

**Current configuration might look like:**
```json
{
  "builder": {
    "gc": {
      "enabled": true,
      "defaultKeepStorage": "20GB"
    }
  },
  "experimental": false
}
```

**Add DNS configuration:**
```json
{
  "builder": {
    "gc": {
      "enabled": true,
      "defaultKeepStorage": "20GB"
    }
  },
  "experimental": false,
  "dns": ["8.8.8.8", "8.8.4.4", "1.1.1.1"]
}
```

**Important**: 
- Add a comma after the last existing property
- Add the `"dns"` line exactly as shown
- Keep all existing configuration intact

#### Step 5: Apply Changes
- Click the **"Apply & Restart"** button at the top
- Docker Desktop will restart (this takes 30-60 seconds)

#### Step 6: Wait for Restart
- Wait for Docker Desktop to fully restart
- The system tray icon should show "Docker Desktop is running"
- This usually takes 30-60 seconds

#### Step 7: Verify Fix

Open PowerShell and run:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\test_docker_network.ps1
```

**Expected Success Output**:
```
Testing Docker network...

[1/3] Checking Docker Desktop...
  [OK] Docker is running

[2/3] Testing DNS resolution...
  [OK] DNS resolution works
    Resolved to: [IP address]

[3/3] Testing image pull (this may take 30-60 seconds)...
  Attempting to pull python:3.11-slim...

========================================
SUCCESS! Docker network is working!
========================================
```

---

### Method 2: Alternative DNS Servers

If Google DNS (8.8.8.8) doesn't work, try:

**Cloudflare DNS**:
```json
"dns": ["1.1.1.1", "1.0.0.1"]
```

**OpenDNS**:
```json
"dns": ["208.67.222.222", "208.67.220.220"]
```

**Combined**:
```json
"dns": ["8.8.8.8", "8.8.4.4", "1.1.1.1", "1.0.0.1"]
```

---

## 🔍 Troubleshooting

### Issue 1: "Apply & Restart" Button is Grayed Out

**Solution**: 
- Check if your JSON is valid (no syntax errors)
- Look for missing commas or extra commas
- Make sure all quotes are properly closed

### Issue 2: Docker Desktop Won't Start After Restart

**Solution**:
1. Close Docker Desktop completely
2. Wait 10 seconds
3. Start Docker Desktop again
4. Wait 60 seconds for full startup

### Issue 3: DNS Still Doesn't Work

**Try These Steps**:

1. **Check system DNS**:
   ```powershell
   ipconfig /all | Select-String "DNS"
   ```
   Make sure your system can resolve DNS

2. **Try different DNS servers** (see Method 2 above)

3. **Check firewall**:
   - Temporarily disable Windows Firewall
   - Test if Docker can pull images
   - If it works, add Docker Desktop to firewall exceptions

4. **Try different network**:
   - Switch to mobile hotspot
   - Test if it works
   - If it works, the issue is with your current network

5. **Restart network adapter**:
   ```powershell
   # Run as Administrator
   ipconfig /release
   ipconfig /renew
   ```

### Issue 4: JSON Syntax Error

**Common Mistakes**:
- ❌ Missing comma: `"experimental": false "dns": [...]`
- ✅ Correct: `"experimental": false, "dns": [...]`
- ❌ Extra comma: `"dns": [...], }`
- ✅ Correct: `"dns": [...] }`

---

## ✅ Verification After Fix

Once DNS is configured, verify everything works:

### 1. Test Network
```powershell
powershell -ExecutionPolicy Bypass -File scripts\test_docker_network.ps1
```

### 2. Build Images
```powershell
docker-compose build
```

### 3. Start Services
```powershell
docker-compose up -d
```

### 4. Check Status
```powershell
docker-compose ps
```

### 5. Test Services
```powershell
curl http://localhost:8000/healthz
```

---

## 📸 Visual Guide

**Docker Desktop Settings Location**:
```
Docker Desktop
  └─ Settings (⚙️ icon)
      └─ Docker Engine
          └─ JSON Editor (right side)
              └─ Add "dns" configuration
                  └─ Apply & Restart
```

---

## 🎯 Quick Reference

**DNS Servers to Try**:
- Google: `8.8.8.8`, `8.8.4.4`
- Cloudflare: `1.1.1.1`, `1.0.0.1`
- OpenDNS: `208.67.222.222`, `208.67.220.220`

**Configuration JSON**:
```json
"dns": ["8.8.8.8", "8.8.4.4", "1.1.1.1"]
```

**Test Command**:
```powershell
powershell -ExecutionPolicy Bypass -File scripts\test_docker_network.ps1
```

---

## ✅ Success Criteria

You'll know DNS is fixed when:

1. ✅ `docker pull python:3.11-slim` succeeds
2. ✅ `docker-compose build` completes without errors
3. ✅ Network test script shows "SUCCESS!"
4. ✅ No more "no such host" errors

---

**After DNS is fixed, proceed with Step 7 setup!** 🚀

