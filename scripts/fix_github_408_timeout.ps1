# Fix GitHub HTTP 408 Timeout Error
# This error occurs when the push takes too long

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "FIXING GITHUB HTTP 408 TIMEOUT ERROR" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "HTTP 408 = Request Timeout" -ForegroundColor Yellow
Write-Host "This means the push is taking too long." -ForegroundColor Cyan
Write-Host ""

# Step 1: Increase timeout settings
Write-Host "[1/5] Increasing git timeout settings..." -ForegroundColor Yellow

# Increase HTTP timeout
git config http.timeout 600
Write-Host "  [OK] HTTP timeout set to 600 seconds" -ForegroundColor Green

# Increase HTTP post buffer
git config http.postBuffer 524288000
Write-Host "  [OK] HTTP post buffer set to 500 MB" -ForegroundColor Green

# Increase low speed limit
git config http.lowSpeedLimit 0
Write-Host "  [OK] Low speed limit disabled" -ForegroundColor Green

# Increase low speed time
git config http.lowSpeedTime 999999
Write-Host "  [OK] Low speed time increased" -ForegroundColor Green

Write-Host ""

# Step 2: Check repository size
Write-Host "[2/5] Checking repository size..." -ForegroundColor Yellow
$repoSize = 0
git ls-files | ForEach-Object {
    if (Test-Path $_) {
        $file = Get-Item $_
        $repoSize += $file.Length
    }
}
$repoSizeMB = [math]::Round($repoSize / 1MB, 2)
Write-Host "  Repository size: $repoSizeMB MB" -ForegroundColor Cyan

if ($repoSizeMB -gt 100) {
    Write-Host "  [WARN] Repository is large. Consider removing large files." -ForegroundColor Yellow
} else {
    Write-Host "  [OK] Repository size is reasonable" -ForegroundColor Green
}
Write-Host ""

# Step 3: Check for large files
Write-Host "[3/5] Checking for large files..." -ForegroundColor Yellow
$largeFiles = git ls-files | ForEach-Object {
    if (Test-Path $_) {
        $file = Get-Item $_
        if ($file.Length -gt 50MB) {
            Write-Host "  [WARN] Large file: $_ ($([math]::Round($file.Length/1MB, 2)) MB)" -ForegroundColor Yellow
            $_
        }
    }
}

if ($largeFiles) {
    Write-Host "  [WARN] Large files may cause timeout issues" -ForegroundColor Yellow
} else {
    Write-Host "  [OK] No very large files found" -ForegroundColor Green
}
Write-Host ""

# Step 4: Try alternative push methods
Write-Host "[4/5] Suggested solutions..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Option 1: Push with increased timeout (try this first)" -ForegroundColor Cyan
Write-Host "  git push origin main --force --verbose" -ForegroundColor Gray
Write-Host ""
Write-Host "Option 2: Push with shallow depth" -ForegroundColor Cyan
Write-Host "  git push origin main --force --depth=1" -ForegroundColor Gray
Write-Host ""
Write-Host "Option 3: Use SSH instead of HTTPS" -ForegroundColor Cyan
Write-Host "  git remote set-url origin git@github.com:hetulpandya44/TweetMoodAI.git" -ForegroundColor Gray
Write-Host "  git push origin main --force" -ForegroundColor Gray
Write-Host ""
Write-Host "Option 4: Create fresh repository (removes history)" -ForegroundColor Cyan
Write-Host "  powershell -ExecutionPolicy Bypass -File scripts\fix_and_push_final.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "Option 5: Use manual upload (web interface)" -ForegroundColor Cyan
Write-Host "  powershell -ExecutionPolicy Bypass -File scripts\prepare_for_manual_upload.ps1" -ForegroundColor Gray
Write-Host "  Then upload via: https://github.com/hetulpandya44/TweetMoodAI/upload" -ForegroundColor Gray
Write-Host ""

# Step 5: Network check
Write-Host "[5/5] Network diagnostics..." -ForegroundColor Yellow
$ping = Test-Connection -ComputerName github.com -Count 2 -ErrorAction SilentlyContinue
if ($ping) {
    Write-Host "  [OK] GitHub is reachable" -ForegroundColor Green
    $avgLatency = ($ping | Measure-Object -Property ResponseTime -Average).Average
    Write-Host "  Average latency: $avgLatency ms" -ForegroundColor Cyan
    if ($avgLatency -gt 500) {
        Write-Host "  [WARN] High latency may cause timeouts" -ForegroundColor Yellow
    }
} else {
    Write-Host "  [ERROR] Cannot reach GitHub. Check your internet connection." -ForegroundColor Red
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "RECOMMENDED ACTIONS" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Try pushing with verbose output:" -ForegroundColor White
Write-Host "   git push origin main --force --verbose" -ForegroundColor Gray
Write-Host ""
Write-Host "2. If still timing out, use manual upload (easiest):" -ForegroundColor White
Write-Host "   powershell -ExecutionPolicy Bypass -File scripts\prepare_for_manual_upload.ps1" -ForegroundColor Gray
Write-Host "   Then upload via web interface" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Or create fresh repository:" -ForegroundColor White
Write-Host "   powershell -ExecutionPolicy Bypass -File scripts\fix_and_push_final.ps1" -ForegroundColor Gray
Write-Host ""

