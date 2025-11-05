# Pre-Deployment Verification Script
# Run this before deploying to cloud (Step 9+)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "PRE-DEPLOYMENT VERIFICATION" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan

$errors = 0
$warnings = 0

# 1. Check Python
Write-Host "[1/10] Checking Python..." -ForegroundColor Yellow
try {
    $pythonVersion = python --version 2>&1
    Write-Host "  [OK] $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "  [FAIL] Python not found" -ForegroundColor Red
    $errors++
}

# 2. Check Virtual Environment
Write-Host "`n[2/10] Checking Virtual Environment..." -ForegroundColor Yellow
if (Test-Path "venv\Scripts\python.exe") {
    Write-Host "  [OK] Virtual environment exists" -ForegroundColor Green
} else {
    Write-Host "  [WARN] Virtual environment not found - create with: python -m venv venv" -ForegroundColor Yellow
    $warnings++
}

# 3. Check .env file
Write-Host "`n[3/10] Checking .env file..." -ForegroundColor Yellow
if (Test-Path .env) {
    Write-Host "  [OK] .env file exists" -ForegroundColor Green
    # Check for required variables
    $envContent = Get-Content .env -Raw
    $requiredVars = @("API_HOST", "API_PORT", "MODEL_PATH")
    $missingVars = @()
    foreach ($var in $requiredVars) {
        if ($envContent -notmatch $var) {
            $missingVars += $var
        }
    }
    if ($missingVars.Count -gt 0) {
        Write-Host "  [WARN] Missing variables: $($missingVars -join ', ')" -ForegroundColor Yellow
        $warnings++
    }
} else {
    Write-Host "  [WARN] .env file missing - copy from env.example" -ForegroundColor Yellow
    Write-Host "    Run: Copy-Item env.example .env" -ForegroundColor Cyan
    $warnings++
}

# 4. Check Docker
Write-Host "`n[4/10] Checking Docker..." -ForegroundColor Yellow
try {
    docker info | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] Docker is running" -ForegroundColor Green
    } else {
        throw "Docker not running"
    }
} catch {
    Write-Host "  [FAIL] Docker is not running - start Docker Desktop" -ForegroundColor Red
    $errors++
}

# 5. Check Docker Compose
Write-Host "`n[5/10] Checking Docker Compose..." -ForegroundColor Yellow
try {
    $composeVersion = docker-compose --version 2>&1
    if ($composeVersion) {
        Write-Host "  [OK] Docker Compose available" -ForegroundColor Green
    }
} catch {
    Write-Host "  [WARN] Docker Compose not found" -ForegroundColor Yellow
    $warnings++
}

# 6. Check model files
Write-Host "`n[6/10] Checking model files..." -ForegroundColor Yellow
$modelFiles = @(
    "models/sentiment_model/model.safetensors",
    "models/sentiment_model/config.json",
    "models/sentiment_model/tokenizer_config.json",
    "models/sentiment_model/label_map.json"
)
$missingFiles = @()
foreach ($file in $modelFiles) {
    if (-not (Test-Path $file)) {
        $missingFiles += $file
    }
}
if ($missingFiles.Count -eq 0) {
    Write-Host "  [OK] All model files exist" -ForegroundColor Green
} else {
    Write-Host "  [WARN] Missing model files:" -ForegroundColor Yellow
    foreach ($file in $missingFiles) {
        Write-Host "    - $file" -ForegroundColor Yellow
    }
    Write-Host "    Run: .\venv\Scripts\python.exe train.py" -ForegroundColor Cyan
    $warnings++
}

# 7. Check test files
Write-Host "`n[7/10] Checking test files..." -ForegroundColor Yellow
if (Test-Path "tests/test_api.py") {
    Write-Host "  [OK] Test files exist" -ForegroundColor Green
} else {
    Write-Host "  [WARN] Test files missing" -ForegroundColor Yellow
    $warnings++
}

# 8. Check Docker images
Write-Host "`n[8/10] Checking Docker images..." -ForegroundColor Yellow
$images = docker images --format "{{.Repository}}" 2>&1 | Select-String "tweetmoodai"
if ($images) {
    Write-Host "  [OK] Docker images found:" -ForegroundColor Green
    $images | ForEach-Object { Write-Host "    - $_" -ForegroundColor Gray }
} else {
    Write-Host "  [WARN] Docker images not built" -ForegroundColor Yellow
    Write-Host "    Run: docker-compose build" -ForegroundColor Cyan
    $warnings++
}

# 9. Check Docker Compose file
Write-Host "`n[9/10] Checking docker-compose.yml..." -ForegroundColor Yellow
if (Test-Path "docker-compose.yml") {
    Write-Host "  [OK] docker-compose.yml exists" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] docker-compose.yml missing" -ForegroundColor Red
    $errors++
}

# 10. Check GitHub Actions
Write-Host "`n[10/10] Checking GitHub Actions..." -ForegroundColor Yellow
if (Test-Path ".github/workflows/ci.yml") {
    Write-Host "  [OK] CI/CD workflow exists" -ForegroundColor Green
} else {
    Write-Host "  [WARN] CI/CD workflow missing" -ForegroundColor Yellow
    $warnings++
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "VERIFICATION SUMMARY" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

if ($errors -eq 0 -and $warnings -eq 0) {
    Write-Host "`n[OK] All checks passed! Ready for deployment." -ForegroundColor Green
    Write-Host "You can proceed to Step 9: Deploy to Cloud Platform`n" -ForegroundColor Cyan
    exit 0
} elseif ($errors -eq 0) {
    Write-Host "`n[WARN] Checks passed with $warnings warning(s)" -ForegroundColor Yellow
    Write-Host "Review warnings above. You can proceed, but fix warnings first for best results.`n" -ForegroundColor Cyan
    exit 0
} else {
    Write-Host "`n[FAIL] Found $errors error(s) and $warnings warning(s)" -ForegroundColor Red
    Write-Host "Fix errors before proceeding to Step 9.`n" -ForegroundColor Red
    exit 1
}


