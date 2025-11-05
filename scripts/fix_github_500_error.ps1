# Fix GitHub HTTP 500 Error
# This error usually indicates GitHub server issues or repository problems

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "FIXING GITHUB HTTP 500 ERROR" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "HTTP 500 error usually means:" -ForegroundColor Yellow
Write-Host "  1. GitHub server issues (temporary)" -ForegroundColor Cyan
Write-Host "  2. Repository size/object issues" -ForegroundColor Cyan
Write-Host "  3. Network connectivity problems" -ForegroundColor Cyan
Write-Host "  4. Large files still in repository" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check GitHub status
Write-Host "[1/5] Checking GitHub status..." -ForegroundColor Yellow
Write-Host "  Visit: https://www.githubstatus.com" -ForegroundColor Cyan
Write-Host "  If GitHub is down, wait and try again later." -ForegroundColor Gray
Write-Host ""

# Step 2: Check repository remote
Write-Host "[2/5] Checking git remote configuration..." -ForegroundColor Yellow
$remoteUrl = git remote get-url origin 2>$null
if ($remoteUrl) {
    Write-Host "  Remote URL: $remoteUrl" -ForegroundColor Cyan
    Write-Host "  [OK] Remote configured" -ForegroundColor Green
} else {
    Write-Host "  [ERROR] No remote configured!" -ForegroundColor Red
    Write-Host "  Setting remote..." -ForegroundColor Yellow
    git remote add origin https://github.com/hetulpandya44/TweetMoodAI.git
    Write-Host "  [OK] Remote added" -ForegroundColor Green
}
Write-Host ""

# Step 3: Check repository size
Write-Host "[3/5] Checking repository for large files..." -ForegroundColor Yellow
$largeFiles = git ls-files | ForEach-Object {
    if (Test-Path $_) {
        $file = Get-Item $_
        if ($file.Length -gt 100MB) {
            Write-Host "  [WARN] Large file: $_ ($([math]::Round($file.Length/1MB, 2)) MB)" -ForegroundColor Yellow
            $_
        }
    }
}

if ($largeFiles) {
    Write-Host "  [WARN] Large files detected in repository!" -ForegroundColor Yellow
    Write-Host "  These may cause GitHub errors." -ForegroundColor Gray
} else {
    Write-Host "  [OK] No large files detected" -ForegroundColor Green
}
Write-Host ""

# Step 4: Try alternative push methods
Write-Host "[4/5] Suggested solutions..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Option 1: Wait and retry (if GitHub is down)" -ForegroundColor Cyan
Write-Host "  git push origin main --force" -ForegroundColor Gray
Write-Host ""
Write-Host "Option 2: Use SSH instead of HTTPS" -ForegroundColor Cyan
Write-Host "  git remote set-url origin git@github.com:hetulpandya44/TweetMoodAI.git" -ForegroundColor Gray
Write-Host "  git push origin main --force" -ForegroundColor Gray
Write-Host ""
Write-Host "Option 3: Increase HTTP buffer size" -ForegroundColor Cyan
Write-Host "  git config http.postBuffer 524288000" -ForegroundColor Gray
Write-Host "  git push origin main --force" -ForegroundColor Gray
Write-Host ""
Write-Host "Option 4: Push in smaller chunks" -ForegroundColor Cyan
Write-Host "  git push origin main --force --verbose" -ForegroundColor Gray
Write-Host ""

# Step 5: Check if we need to create fresh repository
Write-Host "[5/5] If error persists, create fresh repository:" -ForegroundColor Yellow
Write-Host "  powershell -ExecutionPolicy Bypass -File scripts\fix_and_push_final.ps1" -ForegroundColor Gray
Write-Host "  git push origin main --force" -ForegroundColor Gray
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "RECOMMENDED ACTIONS" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Check GitHub status: https://www.githubstatus.com" -ForegroundColor White
Write-Host "2. Try increasing HTTP buffer:" -ForegroundColor White
Write-Host "   git config http.postBuffer 524288000" -ForegroundColor Gray
Write-Host "3. Try pushing again:" -ForegroundColor White
Write-Host "   git push origin main --force" -ForegroundColor Gray
Write-Host "4. If still failing, use fresh repository script:" -ForegroundColor White
Write-Host "   scripts\fix_and_push_final.ps1" -ForegroundColor Gray
Write-Host ""

