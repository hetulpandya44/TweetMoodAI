# PowerShell script to start the frontend server
# Usage: .\start_frontend.ps1

Write-Host "Starting TweetMoodAI Frontend..." -ForegroundColor Green
Write-Host ""

# Activate virtual environment
& .\venv\Scripts\Activate.ps1

# Check if streamlit is available
try {
    $streamlitCheck = & .\venv\Scripts\python.exe -c "import streamlit" 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: streamlit is not installed!" -ForegroundColor Red
        Write-Host "Installing dependencies..." -ForegroundColor Yellow
        & .\venv\Scripts\python.exe -m pip install -r requirements.txt
    }
} catch {
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    & .\venv\Scripts\python.exe -m pip install -r requirements.txt
}

Write-Host "Frontend will run on: http://localhost:8501" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host ""

# Start the frontend server
& .\venv\Scripts\python.exe -m streamlit run ui/app.py --server.port 8501 --server.address 0.0.0.0

