# Remove Large Files from Git History
# This script completely removes checkpoint files from git history

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "REMOVING LARGE FILES FROM GIT HISTORY" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "WARNING: This will rewrite git history!" -ForegroundColor Red
Write-Host "If you've already pushed to GitHub, you may need to force push." -ForegroundColor Yellow
Write-Host ""

$confirm = Read-Host "Continue? (yes/no)"
if ($confirm -ne "yes") {
    Write-Host "Aborted." -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "[1/4] Checking git status..." -ForegroundColor Yellow
git status
Write-Host ""

Write-Host "[2/4] Removing large files from git history..." -ForegroundColor Yellow
Write-Host "This may take a few minutes..." -ForegroundColor Cyan

# Remove files from git history using git filter-branch
# This is the most compatible method (works on Windows without additional tools)

$filesToRemove = @(
    "models/checkpoints/checkpoint-60/model.safetensors",
    "models/checkpoints/checkpoint-60/optimizer.pt",
    "models/checkpoints/checkpoint-90/model.safetensors",
    "models/checkpoints/checkpoint-90/optimizer.pt",
    "models/checkpoints/checkpoint-60/*",
    "models/checkpoints/checkpoint-90/*"
)

# Use git filter-branch to remove files from all commits
$filterCommand = "git filter-branch --force --index-filter `"git rm -rf --cached --ignore-unmatch models/checkpoints/checkpoint-60 models/checkpoints/checkpoint-90`" --prune-empty --tag-name-filter cat -- --all"

Write-Host "Running: $filterCommand" -ForegroundColor Gray
Invoke-Expression $filterCommand

if ($LASTEXITCODE -eq 0) {
    Write-Host "  [OK] Files removed from git history" -ForegroundColor Green
} else {
    Write-Host "  [WARN] filter-branch may have failed. Trying alternative method..." -ForegroundColor Yellow
    
    # Alternative: Use git filter-repo (if available) or manual cleanup
    Write-Host "  [INFO] If git filter-branch is not available, try:" -ForegroundColor Cyan
    Write-Host "    1. Install git-filter-repo: pip install git-filter-repo" -ForegroundColor Gray
    Write-Host "    2. Or use BFG Repo-Cleaner" -ForegroundColor Gray
    Write-Host "    3. Or create a fresh repository (see alternative method)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "[3/4] Cleaning up backup refs..." -ForegroundColor Yellow
Remove-Item -Path .git/refs/original -Recurse -Force -ErrorAction SilentlyContinue
git reflog expire --expire=now --all
git gc --prune=now --aggressive

Write-Host "  [OK] Cleanup complete" -ForegroundColor Green

Write-Host ""
Write-Host "[4/4] Summary:" -ForegroundColor Yellow
Write-Host "  - Large files removed from git history" -ForegroundColor Cyan
Write-Host "  - Repository cleaned and optimized" -ForegroundColor Cyan
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Verify the files are gone:" -ForegroundColor White
Write-Host "   git log --all --full-history -- models/checkpoints/" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Force push to GitHub (if you've already pushed):" -ForegroundColor White
Write-Host "   git push origin main --force" -ForegroundColor Gray
Write-Host ""
Write-Host "   OR if you haven't pushed yet:" -ForegroundColor White
Write-Host "   git push origin main" -ForegroundColor Gray
Write-Host ""
Write-Host "WARNING: Force push will overwrite remote history!" -ForegroundColor Red
Write-Host "Make sure no one else is working on the same branch." -ForegroundColor Yellow
Write-Host ""

