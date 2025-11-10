# PowerShell script to activate virtual environment and run commands
# Usage: .\ACTIVATE_VENV.ps1

Write-Host "Activating virtual environment..." -ForegroundColor Green

# Activate virtual environment
& .\venv\Scripts\Activate.ps1

Write-Host "Virtual environment activated!" -ForegroundColor Green
Write-Host ""
Write-Host "You can now run:" -ForegroundColor Yellow
Write-Host "  - Backend: uvicorn app.main:app --reload" -ForegroundColor Cyan
Write-Host "  - Frontend: streamlit run ui/app.py" -ForegroundColor Cyan
Write-Host ""
Write-Host "To deactivate, type: deactivate" -ForegroundColor Yellow

