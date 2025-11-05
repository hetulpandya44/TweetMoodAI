# Complete Docker Setup and Testing Script
# This script builds, starts, and tests all Docker services
# Run after network connectivity is resolved

Write-Host "========================================"
Write-Host "Docker Complete Setup and Testing"
Write-Host "========================================"
Write-Host ""

# Step 1: Check Docker
Write-Host "[Step 1/7] Checking Docker..." -ForegroundColor Cyan
$dockerCheck = docker ps 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Docker is not running. Please start Docker Desktop." -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Docker is running" -ForegroundColor Green
Write-Host ""

# Step 2: Build images
Write-Host "[Step 2/7] Building Docker images..." -ForegroundColor Cyan
Write-Host "This may take several minutes on first build..." -ForegroundColor Yellow
docker-compose build
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Build failed. Check network connectivity." -ForegroundColor Red
    Write-Host "See DOCKER_BUILD_ISSUE.md for troubleshooting." -ForegroundColor Yellow
    exit 1
}
Write-Host "[OK] Images built successfully" -ForegroundColor Green
Write-Host ""

# Step 3: Start services
Write-Host "[Step 3/7] Starting services..." -ForegroundColor Cyan
docker-compose up -d
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Failed to start services" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Services started" -ForegroundColor Green
Write-Host ""

# Step 4: Wait for services to be ready
Write-Host "[Step 4/7] Waiting for services to be ready (30 seconds)..." -ForegroundColor Cyan
Start-Sleep -Seconds 30
Write-Host "[OK] Wait complete" -ForegroundColor Green
Write-Host ""

# Step 5: Check status
Write-Host "[Step 5/7] Checking service status..." -ForegroundColor Cyan
docker-compose ps
Write-Host ""

# Step 6: Test backend health
Write-Host "[Step 6/7] Testing backend health..." -ForegroundColor Cyan
try {
    $healthResponse = Invoke-WebRequest -Uri "http://localhost:8000/healthz" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
    if ($healthResponse.StatusCode -eq 200) {
        Write-Host "[OK] Backend is healthy (HTTP 200)" -ForegroundColor Green
        $healthData = $healthResponse.Content | ConvertFrom-Json
        Write-Host "    Status: $($healthData.status)" -ForegroundColor Gray
    }
} catch {
    Write-Host "[WARN] Backend health check failed: $_" -ForegroundColor Yellow
    Write-Host "    Services may still be starting. Check logs with: docker-compose logs backend" -ForegroundColor Yellow
}
Write-Host ""

# Step 7: Test frontend
Write-Host "[Step 7/7] Testing frontend..." -ForegroundColor Cyan
try {
    $frontendResponse = Invoke-WebRequest -Uri "http://localhost:8501/" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
    if ($frontendResponse.StatusCode -eq 200) {
        Write-Host "[OK] Frontend is accessible (HTTP 200)" -ForegroundColor Green
    }
} catch {
    Write-Host "[WARN] Frontend check failed: $_" -ForegroundColor Yellow
    Write-Host "    Services may still be starting. Check logs with: docker-compose logs frontend" -ForegroundColor Yellow
}
Write-Host ""

# Summary
Write-Host "========================================"
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "========================================"
Write-Host ""
Write-Host "Services are now running:" -ForegroundColor Cyan
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

