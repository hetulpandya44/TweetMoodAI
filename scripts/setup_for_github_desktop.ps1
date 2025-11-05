# Setup Project for GitHub Desktop Upload
# This script prepares everything for GitHub Desktop

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "SETTING UP FOR GITHUB DESKTOP" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Ensure .gitignore is correct
Write-Host "[1/6] Verifying .gitignore..." -ForegroundColor Yellow
$gitignoreContent = Get-Content .gitignore -Raw -ErrorAction SilentlyContinue

$requiredExclusions = @(
    "models/checkpoints/",
    "*.safetensors",
    ".git_backup_*",
    "venv/",
    "__pycache__/"
)

$needsUpdate = $false
foreach ($exclusion in $requiredExclusions) {
    if ($gitignoreContent -notmatch [regex]::Escape($exclusion)) {
        Add-Content -Path .gitignore -Value "`n# $exclusion" -ErrorAction SilentlyContinue
        $needsUpdate = $true
    }
}

if ($needsUpdate) {
    Write-Host "  [OK] .gitignore updated" -ForegroundColor Green
} else {
    Write-Host "  [OK] .gitignore is correct" -ForegroundColor Green
}

# Step 2: Remove backup directories
Write-Host ""
Write-Host "[2/6] Removing backup directories..." -ForegroundColor Yellow
Get-ChildItem -Path . -Directory -Filter ".git_backup_*" -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "  Removing: $($_.Name)" -ForegroundColor Cyan
    Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
}
Write-Host "  [OK] Backup directories removed" -ForegroundColor Green

# Step 3: Initialize git if needed
Write-Host ""
Write-Host "[3/6] Checking git repository..." -ForegroundColor Yellow
if (-not (Test-Path .git)) {
    Write-Host "  Initializing git repository..." -ForegroundColor Cyan
    git init
    git branch -M main
    Write-Host "  [OK] Git repository initialized" -ForegroundColor Green
} else {
    Write-Host "  [OK] Git repository already exists" -ForegroundColor Green
}

# Step 4: Set remote if not set
Write-Host ""
Write-Host "[4/6] Checking remote repository..." -ForegroundColor Yellow
$remoteUrl = git remote get-url origin 2>$null
if (-not $remoteUrl) {
    Write-Host "  Setting remote to: https://github.com/hetulpandya44/TweetMoodAI.git" -ForegroundColor Cyan
    git remote add origin https://github.com/hetulpandya44/TweetMoodAI.git
    Write-Host "  [OK] Remote added" -ForegroundColor Green
} else {
    Write-Host "  [OK] Remote already set: $remoteUrl" -ForegroundColor Green
}

# Step 5: Configure git settings
Write-Host ""
Write-Host "[5/6] Configuring git settings..." -ForegroundColor Yellow
git config http.timeout 600
git config http.postBuffer 524288000
git config http.lowSpeedLimit 0
git config http.lowSpeedTime 999999
Write-Host "  [OK] Git settings configured" -ForegroundColor Green

# Step 6: Stage files (excluding large ones)
Write-Host ""
Write-Host "[6/6] Staging files (excluding large files)..." -ForegroundColor Yellow

# Remove any large files from staging
git reset HEAD . 2>$null

# Add .gitignore first
git add .gitignore

# Add all files (gitignore will exclude large ones)
git add .

# Check for large files in staging
$stagedFiles = git diff --cached --name-only
$largeFilesFound = $false

foreach ($file in $stagedFiles) {
    if (Test-Path $file) {
        $fileInfo = Get-Item $file -ErrorAction SilentlyContinue
        if ($fileInfo -and $fileInfo.Length -gt 100MB) {
            Write-Host "  [WARN] Removing large file: $file ($([math]::Round($fileInfo.Length/1MB, 2)) MB)" -ForegroundColor Yellow
            git reset HEAD -- "$file" 2>$null
            $largeFilesFound = $true
        }
        # Also check for checkpoint files
        if ($file -like "*checkpoints*" -or $file -like "*.safetensors" -or $file -like ".git_backup_*") {
            Write-Host "  [WARN] Removing excluded file: $file" -ForegroundColor Yellow
            git reset HEAD -- "$file" 2>$null
            $largeFilesFound = $true
        }
    }
}

if ($largeFilesFound) {
    Write-Host "  [OK] Large files removed from staging" -ForegroundColor Green
} else {
    Write-Host "  [OK] No large files in staging" -ForegroundColor Green
}

$stagedCount = (git diff --cached --name-only).Count
Write-Host "  Files staged: $stagedCount" -ForegroundColor Cyan

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "SETUP COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "NEXT STEPS FOR GITHUB DESKTOP:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Option 1: Using GitHub Desktop GUI" -ForegroundColor Cyan
Write-Host "  1. Open GitHub Desktop" -ForegroundColor White
Write-Host "  2. Click 'File' → 'Add Local Repository'" -ForegroundColor White
Write-Host "  3. Select this folder: $((Get-Location).Path)" -ForegroundColor White
Write-Host "  4. GitHub Desktop will show all changes" -ForegroundColor White
Write-Host "  5. Enter commit message: 'Initial commit: TweetMoodAI - Complete Steps 8-13'" -ForegroundColor White
Write-Host "  6. Click 'Commit to main'" -ForegroundColor White
Write-Host "  7. Click 'Push origin' button" -ForegroundColor White
Write-Host ""
Write-Host "Option 2: Using Command Line (Alternative)" -ForegroundColor Cyan
Write-Host "  git commit -m 'Initial commit: TweetMoodAI - Complete Steps 8-13'" -ForegroundColor Gray
Write-Host "  git push origin main --force" -ForegroundColor Gray
Write-Host ""
Write-Host "IMPORTANT:" -ForegroundColor Yellow
Write-Host "  - Large files are excluded automatically" -ForegroundColor Cyan
Write-Host "  - GitHub Desktop will show what will be pushed" -ForegroundColor Cyan
Write-Host "  - Review the changes before pushing" -ForegroundColor Cyan
Write-Host ""

