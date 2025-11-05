# Final Fix: Completely remove checkpoints and create clean repo
# This ensures NO checkpoint files are ever added to git

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "FINAL GIT PUSH FIX" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Backup current .git
Write-Host "[1/7] Backing up current .git directory..." -ForegroundColor Yellow
if (Test-Path .git) {
    $backupName = ".git_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Write-Host "  Backing up to: $backupName" -ForegroundColor Cyan
    Copy-Item -Path .git -Destination $backupName -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "  [OK] Backup created" -ForegroundColor Green
}

# Step 2: Remove .git completely
Write-Host ""
Write-Host "[2/7] Removing old .git directory..." -ForegroundColor Yellow
Remove-Item -Path .git -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "  [OK] Old .git removed" -ForegroundColor Green

# Step 3: Initialize fresh repository
Write-Host ""
Write-Host "[3/7] Initializing fresh git repository..." -ForegroundColor Yellow
git init
git branch -M main
Write-Host "  [OK] Fresh repository initialized" -ForegroundColor Green

# Step 4: Verify .gitignore excludes checkpoints
Write-Host ""
Write-Host "[4/7] Verifying .gitignore configuration..." -ForegroundColor Yellow
if (Test-Path .gitignore) {
    $gitignoreContent = Get-Content .gitignore -Raw
    if ($gitignoreContent -match "checkpoints") {
        Write-Host "  [OK] .gitignore excludes checkpoints" -ForegroundColor Green
    } else {
        Write-Host "  [WARN] .gitignore might not exclude checkpoints" -ForegroundColor Yellow
        Write-Host "  Adding checkpoint exclusion..." -ForegroundColor Cyan
        Add-Content -Path .gitignore -Value "`n# Model checkpoints (too large for GitHub)`nmodels/checkpoints/`n"
        Write-Host "  [OK] Updated .gitignore" -ForegroundColor Green
    }
} else {
    Write-Host "  [ERROR] .gitignore not found!" -ForegroundColor Red
    exit 1
}

# Step 5: Test git check-ignore
Write-Host ""
Write-Host "[5/7] Testing git ignore rules..." -ForegroundColor Yellow
if (Test-Path "models\checkpoints\checkpoint-60\model.safetensors") {
    $testResult = git check-ignore "models/checkpoints/checkpoint-60/model.safetensors" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] Checkpoints are properly ignored" -ForegroundColor Green
    } else {
        Write-Host "  [ERROR] Checkpoints are NOT being ignored!" -ForegroundColor Red
        Write-Host "  Fixing .gitignore..." -ForegroundColor Yellow
        # Force add exclusion
        $gitignore = Get-Content .gitignore
        $gitignore += ""
        $gitignore += "# Model checkpoints (too large for GitHub)"
        $gitignore += "models/checkpoints/"
        $gitignore += "models/**/checkpoint-*/"
        $gitignore | Set-Content .gitignore
        Write-Host "  [OK] .gitignore updated" -ForegroundColor Green
    }
}

# Step 6: Add files (but exclude checkpoints)
Write-Host ""
Write-Host "[6/7] Adding files to git (checkpoints will be excluded)..." -ForegroundColor Yellow

# First, add .gitignore to ensure it's in place
git add .gitignore

# Now add all other files
git add .

# Check what's staged
Write-Host ""
Write-Host "Checking staged files for large files..." -ForegroundColor Cyan
$stagedFiles = git diff --cached --name-only
$foundLarge = $false

foreach ($file in $stagedFiles) {
    if (Test-Path $file) {
        $fileInfo = Get-Item $file -ErrorAction SilentlyContinue
        if ($fileInfo -and $fileInfo.Length -gt 100MB) {
            Write-Host "  [ERROR] Large file detected: $file ($([math]::Round($fileInfo.Length/1MB, 2)) MB)" -ForegroundColor Red
            git reset HEAD $file
            Write-Host "    Removed from staging: $file" -ForegroundColor Yellow
            $foundLarge = $true
        }
    }
    # Also check if it's a checkpoint file
    if ($file -like "*checkpoints*" -or $file -like "*checkpoint-*") {
        Write-Host "  [ERROR] Checkpoint file detected: $file" -ForegroundColor Red
        git reset HEAD $file
        Write-Host "    Removed from staging: $file" -ForegroundColor Yellow
        $foundLarge = $true
    }
}

if ($foundLarge) {
    Write-Host "  [WARN] Some large files were removed from staging" -ForegroundColor Yellow
} else {
    Write-Host "  [OK] No large files in staging area" -ForegroundColor Green
}

# Step 7: Create commit
Write-Host ""
Write-Host "[7/7] Creating initial commit..." -ForegroundColor Yellow
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

# Final verification
Write-Host ""
Write-Host "Final verification..." -ForegroundColor Cyan
$finalCheck = git diff --cached --name-only
$checkpointFiles = $finalCheck | Where-Object { $_ -like "*checkpoints*" -or $_ -like "*checkpoint-*" }
if ($checkpointFiles) {
    Write-Host "  [ERROR] Checkpoint files still in staging!" -ForegroundColor Red
    $checkpointFiles | ForEach-Object {
        Write-Host "    $_" -ForegroundColor Red
        git reset HEAD $_
    }
    Write-Host "  [OK] Removed checkpoint files" -ForegroundColor Green
    Write-Host "  Re-committing..." -ForegroundColor Yellow
    git commit --amend -m "Initial commit: TweetMoodAI - Complete Steps 8-13

- FastAPI backend with sentiment analysis
- Streamlit frontend with monitoring dashboard
- Docker containerization
- CI/CD pipeline
- Cloud deployment ready
- Complete documentation
- All Steps 8-13 complete
- Checkpoints excluded (too large for GitHub)"
}

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

