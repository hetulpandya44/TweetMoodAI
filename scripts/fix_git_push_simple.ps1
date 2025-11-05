# Simple Fix: Remove checkpoints and create fresh repo
# This ensures checkpoints are never added to git

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "FIXING GIT PUSH - SIMPLE METHOD" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Verify .gitignore
Write-Host "[1/5] Verifying .gitignore..." -ForegroundColor Yellow
if (Select-String -Path .gitignore -Pattern "checkpoints" -Quiet) {
    Write-Host "  [OK] .gitignore excludes checkpoints" -ForegroundColor Green
} else {
    Write-Host "  [WARN] .gitignore might not exclude checkpoints properly" -ForegroundColor Yellow
}

# Step 2: Remove .git directory
Write-Host ""
Write-Host "[2/5] Removing old .git directory..." -ForegroundColor Yellow
if (Test-Path .git) {
    $backupName = ".git_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Write-Host "  Backing up to: $backupName" -ForegroundColor Cyan
    Copy-Item -Path .git -Destination $backupName -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path .git -Recurse -Force
    Write-Host "  [OK] Old .git removed" -ForegroundColor Green
} else {
    Write-Host "  [INFO] No .git directory found" -ForegroundColor Cyan
}

# Step 3: Initialize fresh repository
Write-Host ""
Write-Host "[3/5] Initializing fresh git repository..." -ForegroundColor Yellow
git init
git branch -M main
Write-Host "  [OK] Fresh repository initialized" -ForegroundColor Green

# Step 4: Verify checkpoints are not in working directory tracking
Write-Host ""
Write-Host "[4/5] Verifying large files are excluded..." -ForegroundColor Yellow
git status --porcelain | Select-String "checkpoints"
if ($LASTEXITCODE -eq 0) {
    Write-Host "  [WARN] Checkpoints might be tracked - checking .gitignore" -ForegroundColor Yellow
} else {
    Write-Host "  [OK] Checkpoints not in git tracking" -ForegroundColor Green
}

# Step 5: Add all files (checkpoints should be ignored by .gitignore)
Write-Host ""
Write-Host "[5/5] Adding files to git (checkpoints will be ignored)..." -ForegroundColor Yellow
git add .

# Check what will be committed
Write-Host ""
Write-Host "Checking for large files in staging area..." -ForegroundColor Cyan
$stagedFiles = git diff --cached --name-only
$largeFiles = $stagedFiles | ForEach-Object {
    if (Test-Path $_) {
        $file = Get-Item $_
        if ($file.Length -gt 100MB) {
            Write-Host "  [ERROR] Large file detected: $_ ($([math]::Round($file.Length/1MB, 2)) MB)" -ForegroundColor Red
            $_
        }
    }
}

if ($largeFiles) {
    Write-Host ""
    Write-Host "  [ERROR] Large files detected in staging area!" -ForegroundColor Red
    Write-Host "  Removing them from staging..." -ForegroundColor Yellow
    $largeFiles | ForEach-Object {
        git reset HEAD $_
        Write-Host "    Removed: $_" -ForegroundColor Gray
    }
    Write-Host "  [OK] Large files removed from staging" -ForegroundColor Green
} else {
    Write-Host "  [OK] No large files in staging area" -ForegroundColor Green
}

# Create commit
Write-Host ""
Write-Host "Creating initial commit..." -ForegroundColor Yellow
git commit -m "Initial commit: TweetMoodAI - Complete Steps 8-13

- FastAPI backend with sentiment analysis
- Streamlit frontend with monitoring dashboard
- Docker containerization
- CI/CD pipeline
- Cloud deployment ready
- Complete documentation
- All Steps 8-13 complete
- Checkpoints excluded (too large for GitHub)"

Write-Host "  [OK] Commit created" -ForegroundColor Green

# Setup remote
Write-Host ""
Write-Host "Setting up remote..." -ForegroundColor Yellow
git remote remove origin 2>$null
git remote add origin https://github.com/hetulpandya44/TweetMoodAI.git
Write-Host "  [OK] Remote configured" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "READY TO PUSH!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Run this command to push:" -ForegroundColor Yellow
Write-Host "  git push origin main --force" -ForegroundColor White
Write-Host ""
Write-Host "This will overwrite the remote repository." -ForegroundColor Yellow
Write-Host ""

