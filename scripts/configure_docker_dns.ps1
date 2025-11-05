# Script to help configure Docker DNS via Docker Desktop settings file

Write-Host "========================================"
Write-Host "Docker DNS Configuration Helper"
Write-Host "========================================"
Write-Host ""

$dockerConfigPath = "$env:APPDATA\Docker\settings.json"
$dockerDaemonPath = "$env:ProgramData\Docker\config\daemon.json"

Write-Host "This script will help you configure DNS for Docker Desktop." -ForegroundColor Cyan
Write-Host ""
Write-Host "IMPORTANT: Docker Desktop must be closed for this to work!" -ForegroundColor Yellow
Write-Host ""

$response = Read-Host "Is Docker Desktop currently closed? (Y/N)"
if ($response -ne "Y" -and $response -ne "y") {
    Write-Host ""
    Write-Host "Please close Docker Desktop first, then run this script again." -ForegroundColor Yellow
    Write-Host "Or configure DNS manually via Docker Desktop GUI:" -ForegroundColor Cyan
    Write-Host "  1. Open Docker Desktop" -ForegroundColor White
    Write-Host "  2. Settings > Docker Engine" -ForegroundColor White
    Write-Host "  3. Add: { `"dns`": [`"8.8.8.8`", `"8.8.4.4`"] }" -ForegroundColor White
    Write-Host "  4. Apply & Restart" -ForegroundColor White
    exit 0
}

Write-Host ""
Write-Host "Trying to configure DNS in Docker Desktop settings..." -ForegroundColor Cyan

# Check if settings.json exists
if (Test-Path $dockerConfigPath) {
    Write-Host "  Found Docker Desktop settings file" -ForegroundColor Green
    try {
        $settings = Get-Content $dockerConfigPath -Raw | ConvertFrom-Json -ErrorAction Stop
        
        # Add DNS configuration
        if (-not $settings.dnsServers) {
            $settings | Add-Member -MemberType NoteProperty -Name "dnsServers" -Value @("8.8.8.8", "8.8.4.4", "1.1.1.1") -Force
            Write-Host "  Added DNS servers to settings" -ForegroundColor Green
        } else {
            Write-Host "  DNS servers already configured: $($settings.dnsServers -join ', ')" -ForegroundColor Yellow
        }
        
        # Save settings
        $settings | ConvertTo-Json -Depth 10 | Set-Content $dockerConfigPath -Encoding UTF8
        Write-Host "  Settings updated successfully" -ForegroundColor Green
    } catch {
        Write-Host "  Could not automatically update settings: $_" -ForegroundColor Yellow
        Write-Host "  Please configure manually via Docker Desktop GUI" -ForegroundColor Yellow
    }
} else {
    Write-Host "  Docker Desktop settings file not found" -ForegroundColor Yellow
    Write-Host "  Please configure DNS manually via Docker Desktop GUI" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================"
Write-Host "Next Steps:"
Write-Host "========================================"
Write-Host ""
Write-Host "1. Start Docker Desktop" -ForegroundColor Cyan
Write-Host "2. Wait 60 seconds for it to fully start" -ForegroundColor Cyan
Write-Host "3. Test network:" -ForegroundColor Cyan
Write-Host "   powershell -ExecutionPolicy Bypass -File scripts\test_docker_network.ps1" -ForegroundColor White
Write-Host ""
Write-Host "OR configure manually:" -ForegroundColor Yellow
Write-Host "  1. Open Docker Desktop" -ForegroundColor White
Write-Host "  2. Settings > Docker Engine" -ForegroundColor White
Write-Host "  3. Add this JSON:" -ForegroundColor White
Write-Host "     { `"dns`": [`"8.8.8.8`", `"8.8.4.4`", `"1.1.1.1`"] }" -ForegroundColor Green
Write-Host "  4. Click 'Apply & Restart'" -ForegroundColor White
Write-Host ""

