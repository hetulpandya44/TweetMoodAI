# Script to Fix Docker Network DNS Issue
# This script helps configure Docker Desktop DNS settings

Write-Host "========================================"
Write-Host "Docker Network Fix Script"
Write-Host "========================================"
Write-Host ""

Write-Host "This script will help you configure DNS for Docker Desktop." -ForegroundColor Cyan
Write-Host ""

# Step 1: Check if Docker Desktop is running
Write-Host "[Step 1/3] Checking Docker Desktop..." -ForegroundColor Cyan
try {
    $null = docker ps 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] Docker Desktop is running" -ForegroundColor Green
    } else {
        Write-Host "  [WARN] Docker Desktop might not be running" -ForegroundColor Yellow
        Write-Host "  Starting Docker Desktop..." -ForegroundColor Gray
        Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe" -ErrorAction SilentlyContinue
        Write-Host "  Please wait 60 seconds for Docker to start, then run this script again." -ForegroundColor Yellow
        exit 0
    }
} catch {
    Write-Host "  [ERROR] Cannot connect to Docker" -ForegroundColor Red
    Write-Host "  Please start Docker Desktop first." -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Step 2: Show DNS configuration instructions
Write-Host "[Step 2/3] DNS Configuration Instructions" -ForegroundColor Cyan
Write-Host ""
Write-Host "Follow these steps to configure DNS in Docker Desktop:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Open Docker Desktop" -ForegroundColor White
Write-Host "2. Click the Settings icon (gear) in the top right" -ForegroundColor White
Write-Host "3. Go to 'Docker Engine' in the left sidebar" -ForegroundColor White
Write-Host "4. In the JSON editor, add or update the DNS setting:" -ForegroundColor White
Write-Host ""
Write-Host "   Add this to your Docker Engine configuration:" -ForegroundColor Cyan
Write-Host ""
Write-Host '{' -ForegroundColor White
Write-Host '  "dns": ["8.8.8.8", "8.8.4.4", "1.1.1.1"]' -ForegroundColor Green
Write-Host '}' -ForegroundColor White
Write-Host ""
Write-Host "   If you already have other settings, add the DNS line to the existing JSON object." -ForegroundColor Gray
Write-Host ""
Write-Host "5. Click 'Apply & Restart'" -ForegroundColor White
Write-Host "6. Wait 60 seconds for Docker to restart" -ForegroundColor White
Write-Host ""

# Step 3: Wait for user action
Write-Host "[Step 3/3] Waiting for configuration..." -ForegroundColor Cyan
Write-Host ""
$response = Read-Host "Have you configured DNS in Docker Desktop and restarted? (Y/N)"
if ($response -ne "Y" -and $response -ne "y") {
    Write-Host ""
    Write-Host "Please configure DNS in Docker Desktop and restart it, then run:" -ForegroundColor Yellow
    Write-Host "  powershell -ExecutionPolicy Bypass -File scripts\test_docker_network.ps1" -ForegroundColor White
    exit 0
}

Write-Host ""
Write-Host "Testing Docker network..." -ForegroundColor Cyan
Start-Sleep -Seconds 5

# Test network
Write-Host ""
Write-Host "Attempting to pull test image..." -ForegroundColor Cyan
$pullResult = docker pull python:3.11-slim 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================"
    Write-Host "SUCCESS! Network is fixed!" -ForegroundColor Green
    Write-Host "========================================"
    Write-Host ""
    Write-Host "You can now build and start Docker services:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  docker-compose build" -ForegroundColor White
    Write-Host "  docker-compose up -d" -ForegroundColor White
    Write-Host ""
    Write-Host "Or run the complete setup:" -ForegroundColor Cyan
    Write-Host "  powershell -ExecutionPolicy Bypass -File scripts\docker_complete_setup.ps1" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "========================================"
    Write-Host "Network issue persists" -ForegroundColor Yellow
    Write-Host "========================================"
    Write-Host ""
    Write-Host "The pull test failed. Error output:" -ForegroundColor Yellow
    Write-Host $pullResult -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting steps:" -ForegroundColor Cyan
    Write-Host "1. Verify DNS configuration in Docker Desktop" -ForegroundColor White
    Write-Host "2. Restart Docker Desktop again" -ForegroundColor White
    Write-Host "3. Check firewall/antivirus settings" -ForegroundColor White
    Write-Host "4. Try a different network (mobile hotspot)" -ForegroundColor White
    Write-Host ""
    Write-Host "See NETWORK_WORKAROUND.md for more help." -ForegroundColor Gray
}

Write-Host ""

