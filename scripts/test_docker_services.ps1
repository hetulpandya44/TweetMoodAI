# PowerShell script to test Docker services
# Run this after: docker-compose up -d

Write-Host "========================================"
Write-Host "Testing Docker Services"
Write-Host "========================================"

# Wait for services to be ready
Write-Host ""
Write-Host "[*] Waiting for services to start (30 seconds)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Test Backend Health
Write-Host ""
Write-Host "[*] Testing Backend Health Check..." -ForegroundColor Cyan
try {
    $healthResponse = Invoke-WebRequest -Uri "http://localhost:8000/healthz" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    if ($healthResponse.StatusCode -eq 200) {
        Write-Host "[OK] Backend is healthy (HTTP $($healthResponse.StatusCode))" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Backend health check failed (HTTP $($healthResponse.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "[ERROR] Backend health check failed: $_" -ForegroundColor Red
}

# Test Backend API
Write-Host ""
Write-Host "[*] Testing Backend API endpoint..." -ForegroundColor Cyan
try {
    $apiResponse = Invoke-WebRequest -Uri "http://localhost:8000/" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    if ($apiResponse.StatusCode -eq 200) {
        Write-Host "[OK] Backend API is responding (HTTP $($apiResponse.StatusCode))" -ForegroundColor Green
    }
} catch {
    Write-Host "[ERROR] Backend API not responding: $_" -ForegroundColor Red
}

# Test Frontend
Write-Host ""
Write-Host "[*] Testing Frontend..." -ForegroundColor Cyan
try {
    $frontendResponse = Invoke-WebRequest -Uri "http://localhost:8501/" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    if ($frontendResponse.StatusCode -eq 200) {
        Write-Host "[OK] Frontend is accessible (HTTP $($frontendResponse.StatusCode))" -ForegroundColor Green
    }
} catch {
    Write-Host "[ERROR] Frontend not accessible: $_" -ForegroundColor Red
}

# Test API prediction endpoint
Write-Host ""
Write-Host "[*] Testing Sentiment Analysis API..." -ForegroundColor Cyan
try {
    $body = @{
        tweet_text = "This is a test tweet!"
    } | ConvertTo-Json
    
    $predictResponse = Invoke-RestMethod -Uri "http://localhost:8000/predict" `
        -Method POST `
        -ContentType "application/json" `
        -Body $body `
        -TimeoutSec 10 `
        -ErrorAction Stop
    
    Write-Host "[OK] Prediction endpoint is working" -ForegroundColor Green
    Write-Host "Response: $($predictResponse | ConvertTo-Json -Compress)" -ForegroundColor Gray
} catch {
    Write-Host "[ERROR] Prediction endpoint failed: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================"
Write-Host "Service Status:"
Write-Host "========================================"
docker-compose ps

Write-Host ""
Write-Host "[OK] Testing complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Access services at:"
Write-Host "  Backend:  http://localhost:8000"
Write-Host "  Frontend: http://localhost:8501"
Write-Host "  API Docs: http://localhost:8000/docs"

