# Script to help fix Docker DNS issues
# This attempts to configure Docker DNS settings

Write-Host "========================================"
Write-Host "Docker DNS Configuration Helper"
Write-Host "========================================"
Write-Host ""

Write-Host "This script will help you configure Docker DNS settings." -ForegroundColor Yellow
Write-Host "You may need to manually edit Docker Desktop settings." -ForegroundColor Yellow
Write-Host ""

# Check if Docker Desktop settings file exists
$dockerConfigPath = "$env:USERPROFILE\.docker\config.json"
if (Test-Path $dockerConfigPath) {
    Write-Host "[*] Found Docker config: $dockerConfigPath" -ForegroundColor Cyan
} else {
    Write-Host "[*] Docker config not found at: $dockerConfigPath" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================"
Write-Host "Manual DNS Configuration Steps:"
Write-Host "========================================"
Write-Host ""
Write-Host "Option 1: Via Docker Desktop GUI" -ForegroundColor Cyan
Write-Host "1. Open Docker Desktop" -ForegroundColor White
Write-Host "2. Click Settings (gear icon)" -ForegroundColor White
Write-Host "3. Go to 'Docker Engine'" -ForegroundColor White
Write-Host "4. Add DNS configuration:" -ForegroundColor White
Write-Host ""
Write-Host '   {'
Write-Host '     "dns": ["8.8.8.8", "8.8.4.4", "1.1.1.1"]'
Write-Host '   }'
Write-Host ""
Write-Host "5. Click 'Apply & Restart'" -ForegroundColor White
Write-Host ""

Write-Host "Option 2: Via daemon.json" -ForegroundColor Cyan
Write-Host "1. Locate daemon.json (usually in Docker data directory)" -ForegroundColor White
Write-Host "2. Add DNS settings as above" -ForegroundColor White
Write-Host "3. Restart Docker Desktop" -ForegroundColor White
Write-Host ""

Write-Host "Option 3: Try alternative registry mirror" -ForegroundColor Cyan
Write-Host "Add to Docker Engine settings:" -ForegroundColor White
Write-Host ""
Write-Host '   {'
Write-Host '     "registry-mirrors": ["https://registry.docker-cn.com"]'
Write-Host '   }'
Write-Host ""

Write-Host "After making changes:" -ForegroundColor Yellow
Write-Host "1. Restart Docker Desktop" -ForegroundColor White
Write-Host "2. Wait 30-60 seconds for Docker to fully start" -ForegroundColor White
Write-Host "3. Try: docker pull python:3.11-slim" -ForegroundColor White
Write-Host "4. If successful, run: docker-compose build" -ForegroundColor White
Write-Host ""

