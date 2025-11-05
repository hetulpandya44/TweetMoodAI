# Docker Network Troubleshooting Script
# This script helps diagnose Docker network issues

Write-Host "========================================"
Write-Host "Docker Network Troubleshooting"
Write-Host "========================================"

# Check Docker connectivity
Write-Host "`n[*] Checking Docker registry connectivity..."
$registryCheck = Test-NetConnection -ComputerName registry-1.docker.io -Port 443 -WarningAction SilentlyContinue
if ($registryCheck.TcpTestSucceeded) {
    Write-Host "[OK] Can reach Docker Hub registry" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Cannot reach Docker Hub registry" -ForegroundColor Red
    Write-Host "This may be a network/DNS issue" -ForegroundColor Yellow
}

# Check DNS
Write-Host "`n[*] Checking DNS resolution..."
try {
    $dnsResult = Resolve-DnsName -Name registry-1.docker.io -ErrorAction Stop
    Write-Host "[OK] DNS resolution working" -ForegroundColor Green
    Write-Host "    IP: $($dnsResult[0].IPAddress)"
} catch {
    Write-Host "[ERROR] DNS resolution failed" -ForegroundColor Red
    Write-Host "    Error: $_" -ForegroundColor Yellow
}

# Check Docker daemon
Write-Host "`n[*] Checking Docker daemon..."
$dockerStatus = docker info 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Docker daemon is running" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Docker daemon is not responding" -ForegroundColor Red
}

# Suggestions
Write-Host "`n========================================"
Write-Host "Troubleshooting Suggestions:"
Write-Host "========================================"
Write-Host "1. Check your internet connection"
Write-Host "2. Try using a VPN or different network"
Write-Host "3. Check Docker Desktop settings:"
Write-Host "   - Settings > Resources > Network"
Write-Host "   - Settings > Docker Engine (check DNS settings)"
Write-Host "4. Try restarting Docker Desktop"
Write-Host "5. Check firewall/antivirus settings"
Write-Host "6. Try using a proxy if behind a corporate firewall"
Write-Host "`nOnce network issues are resolved, retry:"
Write-Host "   docker-compose build"

