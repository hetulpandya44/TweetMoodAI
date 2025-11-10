# PowerShell script to start the backend server
# Usage: .\start_backend.ps1

Write-Host "Starting TweetMoodAI Backend..." -ForegroundColor Green
Write-Host ""

# Activate virtual environment
& .\venv\Scripts\Activate.ps1

# Check if uvicorn is available
try {
    $uvicornCheck = & .\venv\Scripts\python.exe -c "import uvicorn" 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: uvicorn is not installed!" -ForegroundColor Red
        Write-Host "Installing dependencies..." -ForegroundColor Yellow
        & .\venv\Scripts\python.exe -m pip install -r requirements.txt
    }
} catch {
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    & .\venv\Scripts\python.exe -m pip install -r requirements.txt
}

Write-Host "Backend will run on: http://localhost:8000" -ForegroundColor Cyan
Write-Host "API Docs will be available at: http://localhost:8000/docs" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host ""

# Start the backend server
& .\venv\Scripts\python.exe -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

