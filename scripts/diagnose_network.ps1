# Network Diagnostic Script
# Checks Docker network connectivity and provides recommendations

Write-Host "========================================"
Write-Host "Docker Network Diagnostic"
Write-Host "========================================"
Write-Host ""

$issues = @()
$fixes = @()

# Check 1: Docker Desktop Running
Write-Host "[Check 1/6] Docker Desktop Status..." -ForegroundColor Cyan
try {
    $dockerPs = docker ps 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] Docker Desktop is running" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] Docker Desktop is not running" -ForegroundColor Red
        $issues += "Docker Desktop is not running"
        $fixes += "Start Docker Desktop: Start-Process 'C:\Program Files\Docker\Docker\Docker Desktop.exe'"
    }
} catch {
    Write-Host "  [FAIL] Cannot connect to Docker: $_" -ForegroundColor Red
    $issues += "Cannot connect to Docker daemon"
}

Write-Host ""

# Check 2: DNS Resolution
Write-Host "[Check 2/6] DNS Resolution..." -ForegroundColor Cyan
try {
    $dnsResult = Resolve-DnsName -Name docker.io -ErrorAction Stop
    Write-Host "  [OK] DNS resolution works for docker.io" -ForegroundColor Green
    Write-Host "    IP: $($dnsResult[0].IPAddress)" -ForegroundColor Gray
} catch {
    Write-Host "  [FAIL] DNS resolution failed: $_" -ForegroundColor Red
    $issues += "DNS resolution failure"
    $fixes += "Configure DNS in Docker Desktop: Settings > Docker Engine > Add DNS configuration"
}

Write-Host ""

# Check 3: Network Connectivity
Write-Host "[Check 3/6] Network Connectivity..." -ForegroundColor Cyan
try {
    $testConn = Test-NetConnection -ComputerName docker.io -Port 443 -WarningAction SilentlyContinue -ErrorAction Stop
    if ($testConn.TcpTestSucceeded) {
        Write-Host "  [OK] Can connect to docker.io:443" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] Cannot connect to docker.io:443" -ForegroundColor Red
        $issues += "Cannot connect to Docker Hub on port 443"
        $fixes += "Check firewall/antivirus settings, or use VPN/proxy"
    }
} catch {
    Write-Host "  [WARN] Connectivity test inconclusive: $_" -ForegroundColor Yellow
}

Write-Host ""

# Check 4: Try Image Pull
Write-Host "[Check 4/6] Testing Image Pull..." -ForegroundColor Cyan
Write-Host "  Attempting to pull python:3.11-slim (this may take a moment)..." -ForegroundColor Gray
try {
    $pullOutput = docker pull python:3.11-slim 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] Successfully pulled python:3.11-slim" -ForegroundColor Green
    } else {
        $pullError = $pullOutput -join "`n"
        if ($pullError -match "no such host" -or $pullError -match "failed to resolve") {
            Write-Host "  [FAIL] DNS resolution issue" -ForegroundColor Red
            $issues += "DNS resolution issue when pulling image"
            $fixes += "Configure DNS in Docker Desktop Settings > Docker Engine"
        } elseif ($pullError -match "timeout" -or $pullError -match "connection") {
            Write-Host "  [FAIL] Connection timeout" -ForegroundColor Red
            $issues += "Connection timeout when pulling image"
            $fixes += "Check network connection, firewall, or try different network"
        } else {
            Write-Host "  [FAIL] Pull failed: $pullError" -ForegroundColor Red
            $issues += "Image pull failed"
        }
    }
} catch {
    Write-Host "  [FAIL] Error during pull: $_" -ForegroundColor Red
    $issues += "Error during image pull test"
}

Write-Host ""

# Check 5: Docker DNS Configuration
Write-Host "[Check 5/6] Docker DNS Configuration..." -ForegroundColor Cyan
$dockerConfigPath = "$env:USERPROFILE\.docker\config.json"
$dockerDataPath = "$env:ProgramData\Docker\config\daemon.json"

if (Test-Path $dockerConfigPath) {
    Write-Host "  [*] Found Docker config: $dockerConfigPath" -ForegroundColor Gray
    $config = Get-Content $dockerConfigPath -Raw | ConvertFrom-Json -ErrorAction SilentlyContinue
    if ($config.dns) {
        Write-Host "  [OK] DNS configured in Docker config" -ForegroundColor Green
        Write-Host "    DNS: $($config.dns -join ', ')" -ForegroundColor Gray
    } else {
        Write-Host "  [INFO] No DNS configuration found in Docker config" -ForegroundColor Yellow
        $fixes += "Add DNS to Docker Desktop: Settings > Docker Engine > Add DNS configuration"
    }
} else {
    Write-Host "  [INFO] Docker config not found (this is normal)" -ForegroundColor Gray
}

# Check daemon.json (requires admin access)
if (Test-Path $dockerDataPath) {
    Write-Host "  [*] Found Docker daemon config: $dockerDataPath" -ForegroundColor Gray
} else {
    Write-Host "  [INFO] Docker daemon config not found (configure via Docker Desktop GUI)" -ForegroundColor Gray
}

Write-Host ""

# Check 6: Alternative Solutions
Write-Host "[Check 6/6] Checking for Alternative Solutions..." -ForegroundColor Cyan

# Check if Python image already exists locally
$localImages = docker images python:3.11-slim 2>&1
if ($localImages -match "3.11-slim") {
    Write-Host "  [OK] python:3.11-slim exists locally" -ForegroundColor Green
    Write-Host "    You can try building even if pull fails!" -ForegroundColor Gray
} else {
    Write-Host "  [INFO] python:3.11-slim not found locally" -ForegroundColor Yellow
}

Write-Host ""

# Summary
Write-Host "========================================"
Write-Host "Diagnostic Summary"
Write-Host "========================================"
Write-Host ""

if ($issues.Count -eq 0) {
    Write-Host "✅ All checks passed! Docker network appears to be working." -ForegroundColor Green
    Write-Host ""
    Write-Host "You should be able to build now:" -ForegroundColor Cyan
    Write-Host "  docker-compose build" -ForegroundColor White
} else {
    Write-Host "⚠️  Found $($issues.Count) issue(s):" -ForegroundColor Yellow
    Write-Host ""
    for ($i = 0; $i -lt $issues.Count; $i++) {
        Write-Host "  [$($i+1)] $($issues[$i])" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "🔧 Recommended Fixes:" -ForegroundColor Cyan
    Write-Host ""
    for ($i = 0; $i -lt $fixes.Count; $i++) {
        Write-Host "  [$($i+1)] $($fixes[$i])" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "For detailed instructions, see:" -ForegroundColor Cyan
    Write-Host "  - NETWORK_WORKAROUND.md" -ForegroundColor White
    Write-Host "  - DOCKER_BUILD_ISSUE.md" -ForegroundColor White
}

Write-Host ""
Write-Host "========================================"
Write-Host "Quick Fix Command" -ForegroundColor Cyan
Write-Host "========================================"
Write-Host ""
Write-Host "Open Docker Desktop and add this to Settings > Docker Engine:" -ForegroundColor Yellow
Write-Host ""
Write-Host '{' -ForegroundColor White
Write-Host '  "dns": ["8.8.8.8", "8.8.4.4", "1.1.1.1"]' -ForegroundColor White
Write-Host '}' -ForegroundColor White
Write-Host ""
Write-Host "Then click Apply & Restart and wait 60 seconds." -ForegroundColor Yellow
Write-Host ""

