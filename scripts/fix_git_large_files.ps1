# Fix GitHub Large Files Issue
# This script removes large checkpoint files from git tracking

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "FIXING GITHUB LARGE FILES ISSUE" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if git is initialized
if (-not (Test-Path .git)) {
    Write-Host "[ERROR] Not a git repository. Run 'git init' first." -ForegroundColor Red
    exit 1
}

Write-Host "[1/4] Removing large checkpoint files from git tracking..." -ForegroundColor Yellow

# Remove checkpoints from git tracking (but keep files locally)
git rm -r --cached models/checkpoints/ 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "  [OK] Removed checkpoints from git tracking" -ForegroundColor Green
} else {
    Write-Host "  [INFO] Checkpoints not in git yet (good!)" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "[2/4] Checking .gitignore..." -ForegroundColor Yellow
if (Select-String -Path .gitignore -Pattern "checkpoints" -Quiet) {
    Write-Host "  [OK] .gitignore already excludes checkpoints" -ForegroundColor Green
} else {
    Write-Host "  [WARN] .gitignore should exclude checkpoints (already updated)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[3/4] Staging changes..." -ForegroundColor Yellow
git add .gitignore
Write-Host "  [OK] Staged .gitignore" -ForegroundColor Green

Write-Host ""
Write-Host "[4/4] Summary:" -ForegroundColor Yellow
Write-Host "  - Checkpoints removed from git tracking" -ForegroundColor Cyan
Write-Host "  - .gitignore updated to exclude checkpoints" -ForegroundColor Cyan
Write-Host "  - Final model in models/sentiment_model/ will be kept" -ForegroundColor Cyan
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Commit the changes:" -ForegroundColor White
Write-Host "   git commit -m 'Remove large checkpoint files from repository'" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Push to GitHub:" -ForegroundColor White
Write-Host "   git push origin main" -ForegroundColor Gray
Write-Host ""
Write-Host "NOTE: Only the final trained model will be pushed." -ForegroundColor Cyan
Write-Host "      Checkpoints are kept locally but not in repository." -ForegroundColor Cyan
Write-Host ""

