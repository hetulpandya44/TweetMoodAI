# PowerShell script to test local setup
# This script verifies that the application can run locally

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Local Setup Test" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if virtual environment is activated
$venvActivated = $env:VIRTUAL_ENV -ne $null
if (-not $venvActivated) {
    Write-Host "⚠️  Virtual environment not activated" -ForegroundColor Yellow
    Write-Host "Activating virtual environment..." -ForegroundColor Yellow
    & .\venv\Scripts\Activate.ps1
    Start-Sleep -Seconds 2
}

# Test 1: Check Python version
Write-Host "1. Testing Python version..." -ForegroundColor Yellow
try {
    $pythonVersion = & .\venv\Scripts\python.exe --version
    Write-Host "   ✅ Python version: $pythonVersion" -ForegroundColor Green
    
    # Check if Python 3.10+
    $versionMatch = $pythonVersion -match "Python (\d+)\.(\d+)"
    if ($versionMatch) {
        $major = [int]$matches[1]
        $minor = [int]$matches[2]
        if ($major -ge 3 -and $minor -ge 10) {
            Write-Host "   ✅ Python version is 3.10+ (compatible)" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Python version should be 3.10 or higher" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "   ❌ Python not found" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Test 2: Check if dependencies are installed
Write-Host "2. Testing dependencies..." -ForegroundColor Yellow

$dependencies = @("uvicorn", "streamlit", "fastapi", "transformers", "torch")
foreach ($dep in $dependencies) {
    try {
        $check = & .\venv\Scripts\python.exe -c "import $dep" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   ✅ $dep is installed" -ForegroundColor Green
        } else {
            Write-Host "   ❌ $dep is NOT installed" -ForegroundColor Red
        }
    } catch {
        Write-Host "   ❌ $dep is NOT installed" -ForegroundColor Red
    }
}

Write-Host ""

# Test 3: Check if application files can be imported
Write-Host "3. Testing application imports..." -ForegroundColor Yellow

try {
    $appCheck = & .\venv\Scripts\python.exe -c "import sys; sys.path.insert(0, '.'); from app import main" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Backend application can be imported" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Backend application import check: $appCheck" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ⚠️  Could not test backend import" -ForegroundColor Yellow
}

try {
    $uiCheck = & .\venv\Scripts\python.exe -c "import sys; sys.path.insert(0, '.'); import ui.app" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Frontend application can be imported" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Frontend application import check: $uiCheck" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ⚠️  Could not test frontend import" -ForegroundColor Yellow
}

Write-Host ""

# Test 4: Check if model files exist
Write-Host "4. Testing model files..." -ForegroundColor Yellow

if (Test-Path "models/sentiment_model/config.json") {
    Write-Host "   ✅ Model configuration exists" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Model configuration not found" -ForegroundColor Yellow
}

if (Test-Path "models/sentiment_model/model.safetensors") {
    $modelSize = (Get-Item "models/sentiment_model/model.safetensors").Length / 1MB
    Write-Host "   ✅ Model weights exist ($([math]::Round($modelSize, 2)) MB)" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Model weights not found" -ForegroundColor Yellow
}

Write-Host ""

# Test 5: Check if ports are available
Write-Host "5. Testing port availability..." -ForegroundColor Yellow

function Test-Port {
    param($port)
    $connection = Test-NetConnection -ComputerName localhost -Port $port -WarningAction SilentlyContinue -InformationLevel Quiet
    return $connection
}

$port8000 = Test-Port 8000
if (-not $port8000) {
    Write-Host "   ✅ Port 8000 is available (backend)" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Port 8000 is in use (backend may already be running)" -ForegroundColor Yellow
}

$port8501 = Test-Port 8501
if (-not $port8501) {
    Write-Host "   ✅ Port 8501 is available (frontend)" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Port 8501 is in use (frontend may already be running)" -ForegroundColor Yellow
}

Write-Host ""

# Test 6: Test uvicorn command
Write-Host "6. Testing uvicorn command..." -ForegroundColor Yellow
try {
    $uvicornVersion = & .\venv\Scripts\python.exe -m uvicorn --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ uvicorn is available: $uvicornVersion" -ForegroundColor Green
    } else {
        Write-Host "   ❌ uvicorn is not available" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ uvicorn is not available" -ForegroundColor Red
}

Write-Host ""

# Test 7: Test streamlit command
Write-Host "7. Testing streamlit command..." -ForegroundColor Yellow
try {
    $streamlitVersion = & .\venv\Scripts\python.exe -m streamlit --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ streamlit is available: $streamlitVersion" -ForegroundColor Green
    } else {
        Write-Host "   ❌ streamlit is not available" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ streamlit is not available" -ForegroundColor Red
}

Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Test Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ Local setup test completed!" -ForegroundColor Green
Write-Host ""
Write-Host "To start the application:" -ForegroundColor Cyan
Write-Host "1. Backend: .\start_backend.ps1" -ForegroundColor White
Write-Host "2. Frontend: .\start_frontend.ps1" -ForegroundColor White
Write-Host ""
Write-Host "Or manually:" -ForegroundColor Cyan
Write-Host "1. Backend: python -m uvicorn app.main:app --reload" -ForegroundColor White
Write-Host "2. Frontend: python -m streamlit run ui/app.py" -ForegroundColor White
Write-Host ""

