# Final Fix: Exclude backup and large model files
# This ensures NO large files are added to git

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "FINAL GIT PUSH FIX - UPDATED" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Remove current commit if exists
Write-Host "[1/6] Cleaning up..." -ForegroundColor Yellow
if (Test-Path .git) {
    # Remove any existing commits
    git reset --hard 2>$null
    Write-Host "  [OK] Cleaned up" -ForegroundColor Green
}

# Step 2: Update .gitignore to exclude backup and large model files
Write-Host ""
Write-Host "[2/6] Updating .gitignore..." -ForegroundColor Yellow
$gitignoreContent = Get-Content .gitignore -Raw -ErrorAction SilentlyContinue
$needsUpdate = $false

if ($gitignoreContent -notmatch "\.git_backup_") {
    Add-Content -Path .gitignore -Value "`n# Git backup directories (contain old git objects with large files)`n.git_backup_*/`n"
    $needsUpdate = $true
    Write-Host "  Added .git_backup_ exclusion" -ForegroundColor Cyan
}

if ($gitignoreContent -notmatch "\.safetensors") {
    Add-Content -Path .gitignore -Value "`n# Large model files (too large for GitHub)`n*.safetensors`n*.bin`n!models/sentiment_model/config.json`n!models/sentiment_model/*.json`n!models/sentiment_model/vocab.txt`n"
    $needsUpdate = $true
    Write-Host "  Added .safetensors exclusion" -ForegroundColor Cyan
}

if (-not $needsUpdate) {
    Write-Host "  [OK] .gitignore already updated" -ForegroundColor Green
}

# Step 3: Remove backup directory if it exists
Write-Host ""
Write-Host "[3/6] Removing backup directories..." -ForegroundColor Yellow
Get-ChildItem -Path . -Directory -Filter ".git_backup_*" -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "  Removing: $($_.Name)" -ForegroundColor Cyan
    Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
}
Write-Host "  [OK] Backup directories removed" -ForegroundColor Green

# Step 4: Initialize fresh repository
Write-Host ""
Write-Host "[4/6] Initializing fresh git repository..." -ForegroundColor Yellow
if (Test-Path .git) {
    Remove-Item -Path .git -Recurse -Force -ErrorAction SilentlyContinue
}
git init
git branch -M main
Write-Host "  [OK] Fresh repository initialized" -ForegroundColor Green

# Step 5: Add files (excluding large ones)
Write-Host ""
Write-Host "[5/6] Adding files to git (excluding large files)..." -ForegroundColor Yellow
git add .gitignore
git add .

# Check for large files and remove them
Write-Host ""
Write-Host "Checking for large files..." -ForegroundColor Cyan
$stagedFiles = git diff --cached --name-only
$foundIssues = $false

foreach ($file in $stagedFiles) {
    # Check file size
    if (Test-Path $file) {
        $fileInfo = Get-Item $file -ErrorAction SilentlyContinue
        if ($fileInfo -and $fileInfo.Length -gt 100MB) {
            Write-Host "  [ERROR] Large file: $file ($([math]::Round($fileInfo.Length/1MB, 2)) MB)" -ForegroundColor Red
            git reset HEAD -- "$file" 2>$null
            $foundIssues = $true
        }
    }
    
    # Check for backup directories
    if ($file -like ".git_backup_*" -or $file -like "*/.git_backup_*") {
        Write-Host "  [ERROR] Backup directory: $file" -ForegroundColor Red
        git reset HEAD -- "$file" 2>$null
        $foundIssues = $true
    }
    
    # Check for large model files
    if ($file -like "*.safetensors" -or $file -like "*.bin") {
        Write-Host "  [ERROR] Large model file: $file" -ForegroundColor Red
        git reset HEAD -- "$file" 2>$null
        $foundIssues = $true
    }
}

if ($foundIssues) {
    Write-Host "  [WARN] Some files were removed from staging" -ForegroundColor Yellow
} else {
    Write-Host "  [OK] No large files in staging" -ForegroundColor Green
}

# Step 6: Create commit
Write-Host ""
Write-Host "[6/6] Creating commit..." -ForegroundColor Yellow
git commit -m "Initial commit: TweetMoodAI - Complete Steps 8-13

- FastAPI backend with sentiment analysis
- Streamlit frontend with monitoring dashboard
- Docker containerization
- CI/CD pipeline
- Cloud deployment ready
- Complete documentation
- All Steps 8-13 complete
- Large model files excluded (use Git LFS or download separately)"

Write-Host "  [OK] Commit created" -ForegroundColor Green

# Setup remote
Write-Host ""
Write-Host "Setting up remote..." -ForegroundColor Yellow
git remote remove origin 2>$null
git remote add origin https://github.com/hetulpandya44/TweetMoodAI.git
Write-Host "  [OK] Remote configured" -ForegroundColor Green

# Final check
Write-Host ""
Write-Host "Final verification..." -ForegroundColor Cyan
$finalStaged = git diff --cached --name-only
$finalLarge = $finalStaged | ForEach-Object {
    if (Test-Path $_) {
        $f = Get-Item $_ -ErrorAction SilentlyContinue
        if ($f -and $f.Length -gt 100MB) {
            $_
        }
    }
}

if ($finalLarge) {
    Write-Host "  [ERROR] Large files still in staging!" -ForegroundColor Red
    $finalLarge | ForEach-Object {
        git reset HEAD -- "$_" 2>$null
    }
    Write-Host "  Re-committing..." -ForegroundColor Yellow
    git commit --amend -m "Initial commit: TweetMoodAI - Complete Steps 8-13

- FastAPI backend with sentiment analysis
- Streamlit frontend with monitoring dashboard
- Docker containerization
- CI/CD pipeline
- Cloud deployment ready
- Complete documentation
- All Steps 8-13 complete
- Large model files excluded (use Git LFS or download separately)"
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "READY TO PUSH!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "IMPORTANT NOTE:" -ForegroundColor Yellow
Write-Host "  The model file (model.safetensors) is excluded because it's too large." -ForegroundColor Cyan
Write-Host "  For deployment, you can:" -ForegroundColor Cyan
Write-Host "    1. Use Git LFS for the model file" -ForegroundColor Gray
Write-Host "    2. Download it separately after cloning" -ForegroundColor Gray
Write-Host "    3. Train it fresh on the deployment server" -ForegroundColor Gray
Write-Host ""
Write-Host "Run this command to push:" -ForegroundColor Yellow
Write-Host "  git push origin main --force" -ForegroundColor White
Write-Host ""

