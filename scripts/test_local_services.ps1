# Test Local Services Without Docker
# This allows you to verify the application works while fixing Docker network issues

Write-Host "========================================"
Write-Host "Local Service Testing (Without Docker)"
Write-Host "========================================"
Write-Host ""

# Check if virtual environment exists
if (-not (Test-Path "venv\Scripts\python.exe")) {
    Write-Host "[ERROR] Virtual environment not found. Please create it first:" -ForegroundColor Red
    Write-Host "  python -m venv venv" -ForegroundColor Yellow
    Write-Host "  .\venv\Scripts\Activate.ps1" -ForegroundColor Yellow
    exit 1
}

# Check if model exists
if (-not (Test-Path "models\sentiment_model\config.json")) {
    Write-Host "[ERROR] Model not found. Please train the model first:" -ForegroundColor Red
    Write-Host "  .\venv\Scripts\python.exe train.py" -ForegroundColor Yellow
    exit 1
}

Write-Host "[*] Virtual environment found" -ForegroundColor Green
Write-Host "[*] Model found" -ForegroundColor Green
Write-Host ""

# Check if .env exists
if (-not (Test-Path ".env")) {
    Write-Host "[WARN] .env file not found. Creating from env.example..." -ForegroundColor Yellow
    if (Test-Path "env.example") {
        Copy-Item "env.example" ".env"
        Write-Host "[*] Created .env file. Please update with your API keys." -ForegroundColor Yellow
    }
}

Write-Host "========================================"
Write-Host "Testing Backend API..."
Write-Host "========================================"
Write-Host ""

# Start backend in background
Write-Host "[*] Starting FastAPI backend..." -ForegroundColor Cyan
$backendProcess = Start-Process -FilePath ".\venv\Scripts\python.exe" `
    -ArgumentList "-m", "uvicorn", "app.main:app", "--host", "127.0.0.1", "--port", "8000" `
    -WindowStyle Hidden `
    -PassThru

Start-Sleep -Seconds 5

# Test health endpoint
Write-Host "[*] Testing backend health endpoint..." -ForegroundColor Cyan
try {
    $healthResponse = Invoke-WebRequest -Uri "http://127.0.0.1:8000/healthz" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    if ($healthResponse.StatusCode -eq 200) {
        Write-Host "[OK] Backend is running! (HTTP $($healthResponse.StatusCode))" -ForegroundColor Green
        $healthData = $healthResponse.Content | ConvertFrom-Json
        Write-Host "    Status: $($healthData.status)" -ForegroundColor Gray
    }
} catch {
    Write-Host "[ERROR] Backend health check failed: $_" -ForegroundColor Red
    Stop-Process -Id $backendProcess.Id -Force -ErrorAction SilentlyContinue
    exit 1
}

# Test prediction
Write-Host "[*] Testing sentiment prediction..." -ForegroundColor Cyan
try {
    $body = @{
        tweet_text = "This is amazing! I love it!"
    } | ConvertTo-Json

    $predResponse = Invoke-RestMethod -Uri "http://127.0.0.1:8000/predict" `
        -Method POST `
        -ContentType "application/json" `
        -Body $body `
        -TimeoutSec 10

    Write-Host "[OK] Prediction successful!" -ForegroundColor Green
    Write-Host "    Tweet: $($body.tweet_text)" -ForegroundColor Gray
    Write-Host "    Sentiment: $($predResponse.sentiment)" -ForegroundColor Gray
    Write-Host "    Confidence: $([math]::Round($predResponse.confidence, 2))" -ForegroundColor Gray
} catch {
    Write-Host "[WARN] Prediction test failed: $_" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================"
Write-Host "Backend Test Complete!"
Write-Host "========================================"
Write-Host ""
Write-Host "Backend is running at: http://127.0.0.1:8000" -ForegroundColor Cyan
Write-Host "API Docs: http://127.0.0.1:8000/docs" -ForegroundColor Cyan
Write-Host ""
Write-Host "To test frontend, run:" -ForegroundColor Yellow
Write-Host "  .\venv\Scripts\streamlit run ui/app.py" -ForegroundColor White
Write-Host ""
Write-Host "To stop backend, press Ctrl+C or run:" -ForegroundColor Yellow
Write-Host "  Stop-Process -Id $($backendProcess.Id)" -ForegroundColor White
Write-Host ""
Write-Host "Keep this window open to keep the backend running." -ForegroundColor Yellow
Write-Host ""

# Keep process running
Write-Host "Press Ctrl+C to stop the backend..."
try {
    Wait-Process -Id $backendProcess.Id
} catch {
    Write-Host ""
    Write-Host "[*] Backend stopped." -ForegroundColor Yellow
}

