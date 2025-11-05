# Wait for Docker Desktop to be ready

Write-Host "Waiting for Docker Desktop to start..." -ForegroundColor Cyan
Write-Host "This may take 30-60 seconds..." -ForegroundColor Yellow
Write-Host ""

$maxWait = 120 # seconds
$elapsed = 0
$interval = 5 # seconds

while ($elapsed -lt $maxWait) {
    try {
        $result = docker ps 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Docker Desktop is ready!" -ForegroundColor Green
            Start-Sleep -Seconds 5 # Give it a few more seconds to fully initialize
            exit 0
        }
    } catch {
        # Docker not ready yet
    }
    
    Write-Host "  Waiting... ($elapsed seconds)" -ForegroundColor Gray
    Start-Sleep -Seconds $interval
    $elapsed += $interval
}

Write-Host ""
Write-Host "Timeout waiting for Docker Desktop." -ForegroundColor Red
Write-Host "Please check Docker Desktop manually and ensure it's running." -ForegroundColor Yellow
exit 1

