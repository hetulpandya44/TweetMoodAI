# PowerShell script to start Docker Desktop on Windows
# Usage: .\scripts\start_docker.ps1

Write-Host "========================================"
Write-Host "Starting Docker Desktop"
Write-Host "========================================"

# Check if Docker Desktop is already running
$dockerProcess = Get-Process -Name "Docker Desktop" -ErrorAction SilentlyContinue

if ($dockerProcess) {
    Write-Host "[OK] Docker Desktop is already running!" -ForegroundColor Green
    Write-Host "PID: $($dockerProcess.Id)"
    exit 0
}

Write-Host "[*] Docker Desktop is not running. Attempting to start..." -ForegroundColor Yellow

# Common Docker Desktop installation paths
$dockerPaths = @(
    "C:\Program Files\Docker\Docker\Docker Desktop.exe",
    "$env:LOCALAPPDATA\Docker\Docker Desktop.exe",
    "$env:ProgramFiles\Docker\Docker\Docker Desktop.exe",
    "${env:ProgramFiles(x86)}\Docker\Docker\Docker Desktop.exe"
)

$dockerFound = $false

foreach ($path in $dockerPaths) {
    if (Test-Path $path) {
        Write-Host "[*] Found Docker Desktop at: $path" -ForegroundColor Cyan
        try {
            Start-Process -FilePath $path
            Write-Host "[OK] Docker Desktop start command issued!" -ForegroundColor Green
            Write-Host ""
            Write-Host "Please wait 30-60 seconds for Docker Desktop to fully start..." -ForegroundColor Yellow
            Write-Host "You can monitor the Docker Desktop icon in the system tray." -ForegroundColor Yellow
            $dockerFound = $true
            break
        } catch {
            Write-Host "[ERROR] Failed to start Docker Desktop: $_" -ForegroundColor Red
            exit 1
        }
    }
}

if (-not $dockerFound) {
    Write-Host "[ERROR] Docker Desktop not found in standard locations." -ForegroundColor Red
    Write-Host ""
    Write-Host "Please start Docker Desktop manually:" -ForegroundColor Yellow
    Write-Host "1. Search for 'Docker Desktop' in Start Menu" -ForegroundColor Yellow
    Write-Host "2. Click on Docker Desktop to launch it" -ForegroundColor Yellow
    Write-Host "3. Wait for Docker Desktop to fully start (whale icon in system tray)" -ForegroundColor Yellow
    Write-Host "4. Run this script again to verify" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "========================================"
Write-Host "Waiting for Docker daemon to be ready..."
Write-Host "========================================"

# Wait for Docker daemon to be ready (up to 60 seconds)
$maxWait = 60
$waited = 0
$interval = 2

while ($waited -lt $maxWait) {
    Start-Sleep -Seconds $interval
    $waited += $interval
    
    # Check if Docker daemon is responding
    $dockerCheck = docker ps 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Docker daemon is ready!" -ForegroundColor Green
        Write-Host ""
        docker --version
        docker compose version
        Write-Host ""
        Write-Host "You can now run: docker-compose up" -ForegroundColor Green
        exit 0
    }
    
    Write-Host "[*] Waiting for Docker daemon... ($waited/$maxWait seconds)" -ForegroundColor Yellow
}

Write-Host "[WARN] Docker Desktop may still be starting." -ForegroundColor Yellow
Write-Host "Please check the Docker Desktop window/system tray icon." -ForegroundColor Yellow
Write-Host "Once the whale icon stops animating, Docker is ready." -ForegroundColor Yellow

