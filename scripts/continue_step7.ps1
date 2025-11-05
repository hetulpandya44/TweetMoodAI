# Step 7: Complete Docker Setup Script
# This script will check DNS, then build and start all services

Write-Host "========================================"
Write-Host "Step 7: Docker Containerization"
Write-Host "========================================"
Write-Host ""

# Step 1: Check Docker Desktop
Write-Host "[Step 1/7] Checking Docker Desktop..." -ForegroundColor Cyan
try {
    $null = docker ps 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] Docker Desktop is running" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] Docker Desktop is not running" -ForegroundColor Red
        Write-Host "  Starting Docker Desktop..." -ForegroundColor Yellow
        Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe" -ErrorAction SilentlyContinue
        Write-Host "  Please wait 60 seconds for Docker to start, then run this script again." -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "  [FAIL] Cannot connect to Docker" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 2: Test Network/DNS
Write-Host "[Step 2/7] Testing Docker network (DNS check)..." -ForegroundColor Cyan
Write-Host "  Attempting to pull test image..." -ForegroundColor Gray

$pullTest = docker pull python:3.11-slim 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  [OK] Network is working! Image pull successful." -ForegroundColor Green
} else {
    $pullOutput = $pullTest -join "`n"
    if ($pullOutput -match "no such host" -or $pullOutput -match "failed to resolve") {
        Write-Host ""
        Write-Host "========================================"
        Write-Host "⚠️  DNS Configuration Required" -ForegroundColor Yellow
        Write-Host "========================================"
        Write-Host ""
        Write-Host "Docker cannot resolve DNS to pull images." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Please configure DNS in Docker Desktop:" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "1. Open Docker Desktop" -ForegroundColor White
        Write-Host "2. Click Settings (gear icon)" -ForegroundColor White
        Write-Host "3. Go to 'Docker Engine'" -ForegroundColor White
        Write-Host "4. Add this to the JSON:" -ForegroundColor White
        Write-Host ""
        Write-Host '   {' -ForegroundColor Gray
        Write-Host '     "dns": ["8.8.8.8", "8.8.4.4", "1.1.1.1"]' -ForegroundColor Green
        Write-Host '   }' -ForegroundColor Gray
        Write-Host ""
        Write-Host "5. Click 'Apply & Restart'" -ForegroundColor White
        Write-Host "6. Wait 60 seconds for Docker to restart" -ForegroundColor White
        Write-Host ""
        Write-Host "Then run this script again:" -ForegroundColor Cyan
        Write-Host "  powershell -ExecutionPolicy Bypass -File scripts\continue_step7.ps1" -ForegroundColor White
        Write-Host ""
        exit 1
    } else {
        Write-Host "  [WARN] Network issue detected: $pullOutput" -ForegroundColor Yellow
        $continue = Read-Host "Continue anyway? (Y/N)"
        if ($continue -ne "Y" -and $continue -ne "y") {
            exit 1
        }
    }
}

Write-Host ""

# Step 3: Build Images
Write-Host "[Step 3/7] Building Docker images..." -ForegroundColor Cyan
Write-Host "  This may take 5-10 minutes on first build..." -ForegroundColor Gray

docker-compose build
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "  [FAIL] Build failed. Check the errors above." -ForegroundColor Red
    Write-Host "  See DOCKER_BUILD_ISSUE.md for troubleshooting." -ForegroundColor Yellow
    exit 1
}

Write-Host "  [OK] Images built successfully" -ForegroundColor Green
Write-Host ""

# Step 4: Start Services
Write-Host "[Step 4/7] Starting Docker services..." -ForegroundColor Cyan
docker-compose up -d
if ($LASTEXITCODE -ne 0) {
    Write-Host "  [FAIL] Failed to start services" -ForegroundColor Red
    exit 1
}

Write-Host "  [OK] Services started" -ForegroundColor Green
Write-Host ""

# Step 5: Wait for Services
Write-Host "[Step 5/7] Waiting for services to be ready (30 seconds)..." -ForegroundColor Cyan
Start-Sleep -Seconds 30
Write-Host "  [OK] Wait complete" -ForegroundColor Green
Write-Host ""

# Step 6: Check Status
Write-Host "[Step 6/7] Checking service status..." -ForegroundColor Cyan
docker-compose ps
Write-Host ""

# Step 7: Test Services
Write-Host "[Step 7/7] Testing services..." -ForegroundColor Cyan

# Test backend
Write-Host "  Testing backend..." -ForegroundColor Gray
try {
    $healthResponse = Invoke-WebRequest -Uri "http://localhost:8000/healthz" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
    if ($healthResponse.StatusCode -eq 200) {
        Write-Host "    [OK] Backend is healthy (HTTP 200)" -ForegroundColor Green
    }
} catch {
    Write-Host "    [WARN] Backend health check failed: $_" -ForegroundColor Yellow
    Write-Host "    Services may still be starting. Check logs with: docker-compose logs backend" -ForegroundColor Gray
}

# Test frontend
Write-Host "  Testing frontend..." -ForegroundColor Gray
try {
    $frontendResponse = Invoke-WebRequest -Uri "http://localhost:8501/" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
    if ($frontendResponse.StatusCode -eq 200) {
        Write-Host "    [OK] Frontend is accessible (HTTP 200)" -ForegroundColor Green
    }
} catch {
    Write-Host "    [WARN] Frontend check failed: $_" -ForegroundColor Yellow
    Write-Host "    Services may still be starting. Check logs with: docker-compose logs frontend" -ForegroundColor Gray
}

Write-Host ""

# Final Summary
Write-Host "========================================"
Write-Host "Step 7: Complete! ✅" -ForegroundColor Green
Write-Host "========================================"
Write-Host ""
Write-Host "Services are running:" -ForegroundColor Cyan
Write-Host "  Backend API:  http://localhost:8000" -ForegroundColor White
Write-Host "  API Docs:     http://localhost:8000/docs" -ForegroundColor White
Write-Host "  Health Check: http://localhost:8000/healthz" -ForegroundColor White
Write-Host "  Frontend UI:  http://localhost:8501" -ForegroundColor White
Write-Host ""
Write-Host "Useful commands:" -ForegroundColor Cyan
Write-Host "  View logs:    docker-compose logs -f" -ForegroundColor White
Write-Host "  Stop:         docker-compose down" -ForegroundColor White
Write-Host "  Restart:      docker-compose restart" -ForegroundColor White
Write-Host "  Status:       docker-compose ps" -ForegroundColor White
Write-Host ""


