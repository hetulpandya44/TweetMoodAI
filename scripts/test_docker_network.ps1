# Quick test script to verify Docker network is working

Write-Host "Testing Docker network..." -ForegroundColor Cyan
Write-Host ""

# Check Docker is running
Write-Host "[1/3] Checking Docker Desktop..." -ForegroundColor Cyan
try {
    $null = docker ps 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] Docker is running" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] Docker is not running" -ForegroundColor Red
        Write-Host "  Please start Docker Desktop first." -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "  [FAIL] Cannot connect to Docker" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Test DNS resolution
Write-Host "[2/3] Testing DNS resolution..." -ForegroundColor Cyan
try {
    $dnsResult = Resolve-DnsName -Name docker.io -ErrorAction Stop
    Write-Host "  [OK] DNS resolution works" -ForegroundColor Green
    Write-Host "    Resolved to: $($dnsResult[0].IPAddress)" -ForegroundColor Gray
} catch {
    Write-Host "  [WARN] DNS resolution issue: $_" -ForegroundColor Yellow
    Write-Host "    This might still work in Docker, testing anyway..." -ForegroundColor Gray
}

Write-Host ""

# Test image pull
Write-Host "[3/3] Testing image pull (this may take 30-60 seconds)..." -ForegroundColor Cyan
Write-Host "  Attempting to pull python:3.11-slim..." -ForegroundColor Gray

$pullOutput = docker pull python:3.11-slim 2>&1 | Out-String

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================"
    Write-Host "SUCCESS! Docker network is working!" -ForegroundColor Green
    Write-Host "========================================"
    Write-Host ""
    Write-Host "You can now proceed with Docker setup:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  docker-compose build" -ForegroundColor White
    Write-Host "  docker-compose up -d" -ForegroundColor White
    Write-Host ""
    Write-Host "Or run complete setup:" -ForegroundColor Cyan
    Write-Host "  powershell -ExecutionPolicy Bypass -File scripts\docker_complete_setup.ps1" -ForegroundColor White
    Write-Host ""
    exit 0
} else {
    Write-Host ""
    Write-Host "========================================"
    Write-Host "FAILED: Network issue detected" -ForegroundColor Red
    Write-Host "========================================"
    Write-Host ""
    Write-Host "Error details:" -ForegroundColor Yellow
    Write-Host $pullOutput -ForegroundColor Red
    Write-Host ""
    Write-Host "Please run the fix script:" -ForegroundColor Cyan
    Write-Host "  powershell -ExecutionPolicy Bypass -File scripts\fix_docker_network.ps1" -ForegroundColor White
    Write-Host ""
    Write-Host "Or manually configure DNS in Docker Desktop:" -ForegroundColor Yellow
    Write-Host "  Settings > Docker Engine > Add DNS configuration" -ForegroundColor White
    Write-Host ""
    exit 1
}

