# Alternative: Create Fresh Repository (Safest Method)
# This creates a fresh repository without the large files in history

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CREATING FRESH REPOSITORY" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This method creates a fresh git repository without large files." -ForegroundColor Cyan
Write-Host "It's the safest method if you haven't shared the repository yet." -ForegroundColor Cyan
Write-Host ""

$confirm = Read-Host "Continue? (yes/no)"
if ($confirm -notin @("yes", "y", "Y")) {
    Write-Host "Aborted." -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "[1/5] Backing up current .git directory..." -ForegroundColor Yellow
if (Test-Path .git) {
    $backupName = ".git_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Copy-Item -Path .git -Destination $backupName -Recurse -Force
    Write-Host "  [OK] Backup created: $backupName" -ForegroundColor Green
}

Write-Host ""
Write-Host "[2/5] Removing .git directory..." -ForegroundColor Yellow
Remove-Item -Path .git -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "  [OK] Old .git removed" -ForegroundColor Green

Write-Host ""
Write-Host "[3/5] Initializing new git repository..." -ForegroundColor Yellow
git init
git branch -M main
Write-Host "  [OK] New repository initialized" -ForegroundColor Green

Write-Host ""
Write-Host "[4/5] Adding all files (excluding large checkpoints)..." -ForegroundColor Yellow
git add .
Write-Host "  [OK] Files staged" -ForegroundColor Green

Write-Host ""
Write-Host "[5/5] Creating initial commit..." -ForegroundColor Yellow
git commit -m "Initial commit: TweetMoodAI - Complete Steps 8-13

- FastAPI backend with sentiment analysis
- Streamlit frontend with monitoring dashboard
- Docker containerization
- CI/CD pipeline
- Cloud deployment ready
- Complete documentation
- All Steps 8-13 complete"
Write-Host "  [OK] Initial commit created" -ForegroundColor Green

Write-Host ""
Write-Host ""
Write-Host "[6/6] Setting up remote repository..." -ForegroundColor Yellow
# Remove existing remote if it exists
git remote remove origin 2>$null
# Add remote
git remote add origin https://github.com/hetulpandya44/TweetMoodAI.git
Write-Host "  [OK] Remote configured" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "READY TO PUSH!" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Force push to GitHub (overwrites remote):" -ForegroundColor White
Write-Host "   git push origin main --force" -ForegroundColor Gray
Write-Host ""
Write-Host "WARNING: This will overwrite the remote repository!" -ForegroundColor Red
Write-Host "Make sure you have a backup if needed." -ForegroundColor Yellow
Write-Host ""

