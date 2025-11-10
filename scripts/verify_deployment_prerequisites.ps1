# PowerShell script to verify deployment prerequisites
# This script checks all requirements for deployment

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Deployment Prerequisites Verification" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$allChecksPassed = $true

# 1. Check GitHub Repository
Write-Host "1. Checking GitHub Repository..." -ForegroundColor Yellow
try {
    $remote = git remote get-url origin
    if ($remote -like "*github.com*hetulpandya44/TweetMoodAI*") {
        Write-Host "   ✅ GitHub repository connected: $remote" -ForegroundColor Green
    } else {
        Write-Host "   ❌ GitHub repository not configured correctly" -ForegroundColor Red
        $allChecksPassed = $false
    }
} catch {
    Write-Host "   ❌ Git remote not found" -ForegroundColor Red
    $allChecksPassed = $false
}

# Check if all changes are committed
$gitStatus = git status --porcelain
if ($gitStatus -eq "") {
    Write-Host "   ✅ All changes are committed" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Uncommitted changes found:" -ForegroundColor Yellow
    Write-Host $gitStatus -ForegroundColor Yellow
    Write-Host "   💡 Run: git add . && git commit -m 'Ready for deployment' && git push" -ForegroundColor Cyan
}

Write-Host ""

# 2. Check Required Files
Write-Host "2. Checking Required Files..." -ForegroundColor Yellow

$requiredFiles = @(
    "render.yaml",
    "Dockerfile.backend",
    "Dockerfile.frontend",
    "requirements.txt",
    "app/main.py",
    "ui/app.py"
)

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "   ✅ $file exists" -ForegroundColor Green
    } else {
        Write-Host "   ❌ $file NOT FOUND" -ForegroundColor Red
        $allChecksPassed = $false
    }
}

Write-Host ""

# 3. Check Model Files
Write-Host "3. Checking Model Files..." -ForegroundColor Yellow

$modelFiles = @(
    "models/sentiment_model/config.json",
    "models/sentiment_model/label_map.json",
    "models/sentiment_model/tokenizer_config.json",
    "models/sentiment_model/vocab.txt",
    "models/sentiment_model/special_tokens_map.json"
)

foreach ($file in $modelFiles) {
    if (Test-Path $file) {
        Write-Host "   ✅ $file exists" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  $file NOT FOUND (may cause issues)" -ForegroundColor Yellow
    }
}

# Check model weights file
if (Test-Path "models/sentiment_model/model.safetensors") {
    $modelSize = (Get-Item "models/sentiment_model/model.safetensors").Length / 1MB
    Write-Host "   ✅ model.safetensors exists ($([math]::Round($modelSize, 2)) MB)" -ForegroundColor Green
    Write-Host "   ⚠️  Note: Large file (255 MB) - may need special handling for deployment" -ForegroundColor Yellow
} else {
    Write-Host "   ⚠️  model.safetensors NOT FOUND" -ForegroundColor Yellow
    Write-Host "   💡 Model weights file is required for deployment" -ForegroundColor Cyan
}

Write-Host ""

# 4. Check Virtual Environment
Write-Host "4. Checking Virtual Environment..." -ForegroundColor Yellow

if (Test-Path "venv") {
    Write-Host "   ✅ Virtual environment exists" -ForegroundColor Green
    
    # Check if uvicorn is installed
    $uvicornCheck = & .\venv\Scripts\python.exe -c "import uvicorn" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ uvicorn is installed" -ForegroundColor Green
    } else {
        Write-Host "   ❌ uvicorn is NOT installed" -ForegroundColor Red
        Write-Host "   💡 Run: .\venv\Scripts\python.exe -m pip install -r requirements.txt" -ForegroundColor Cyan
        $allChecksPassed = $false
    }
    
    # Check if streamlit is installed
    $streamlitCheck = & .\venv\Scripts\python.exe -c "import streamlit" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ streamlit is installed" -ForegroundColor Green
    } else {
        Write-Host "   ❌ streamlit is NOT installed" -ForegroundColor Red
        Write-Host "   💡 Run: .\venv\Scripts\python.exe -m pip install -r requirements.txt" -ForegroundColor Cyan
        $allChecksPassed = $false
    }
    
    # Check if fastapi is installed
    $fastapiCheck = & .\venv\Scripts\python.exe -c "import fastapi" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ fastapi is installed" -ForegroundColor Green
    } else {
        Write-Host "   ❌ fastapi is NOT installed" -ForegroundColor Red
        $allChecksPassed = $false
    }
} else {
    Write-Host "   ⚠️  Virtual environment not found" -ForegroundColor Yellow
    Write-Host "   💡 Create with: python -m venv venv" -ForegroundColor Cyan
}

Write-Host ""

# 5. Check Environment Variables Template
Write-Host "5. Checking Environment Configuration..." -ForegroundColor Yellow

if (Test-Path "env.example") {
    Write-Host "   ✅ env.example exists" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  env.example NOT FOUND" -ForegroundColor Yellow
}

if (Test-Path ".env") {
    Write-Host "   ⚠️  .env file exists (should NOT be committed to git)" -ForegroundColor Yellow
} else {
    Write-Host "   ✅ .env file not found (correct - use env.example)" -ForegroundColor Green
}

Write-Host ""

# 6. Check Docker Files
Write-Host "6. Checking Docker Configuration..." -ForegroundColor Yellow

if (Test-Path "docker-compose.yml") {
    Write-Host "   ✅ docker-compose.yml exists" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  docker-compose.yml NOT FOUND" -ForegroundColor Yellow
}

if (Test-Path ".dockerignore") {
    Write-Host "   ✅ .dockerignore exists" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  .dockerignore NOT FOUND (optional)" -ForegroundColor Yellow
}

Write-Host ""

# 7. Check Documentation
Write-Host "7. Checking Documentation..." -ForegroundColor Yellow

$docFiles = @(
    "README.md",
    "STEP_BY_STEP_DEPLOYMENT.md",
    "PROJECT_REPORT.md"
)

foreach ($file in $docFiles) {
    if (Test-Path $file) {
        Write-Host "   ✅ $file exists" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  $file NOT FOUND (optional but recommended)" -ForegroundColor Yellow
    }
}

Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Verification Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($allChecksPassed) {
    Write-Host "✅ All critical checks passed!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Test locally (optional but recommended)" -ForegroundColor White
    Write-Host "2. Deploy to Render.com" -ForegroundColor White
    Write-Host "3. See STEP_BY_STEP_DEPLOYMENT.md for detailed instructions" -ForegroundColor White
} else {
    Write-Host "❌ Some checks failed. Please fix the issues above." -ForegroundColor Red
    Write-Host ""
    Write-Host "Common fixes:" -ForegroundColor Cyan
    Write-Host "1. Install dependencies: .\venv\Scripts\python.exe -m pip install -r requirements.txt" -ForegroundColor White
    Write-Host "2. Commit changes: git add . && git commit -m 'Ready for deployment' && git push" -ForegroundColor White
    Write-Host "3. Verify all required files exist" -ForegroundColor White
}

Write-Host ""

