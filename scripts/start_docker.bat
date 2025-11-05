@echo off
REM Batch script to start Docker Desktop on Windows
REM Usage: scripts\start_docker.bat

echo ========================================
echo Starting Docker Desktop
echo ========================================

REM Check if Docker Desktop is already running
tasklist /FI "IMAGENAME eq Docker Desktop.exe" 2>NUL | find /I /N "Docker Desktop.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo [OK] Docker Desktop is already running!
    goto :verify
)

echo [*] Docker Desktop is not running. Attempting to start...

REM Try common Docker Desktop installation paths
if exist "C:\Program Files\Docker\Docker\Docker Desktop.exe" (
    echo [*] Found Docker Desktop at: C:\Program Files\Docker\Docker\Docker Desktop.exe
    start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    goto :wait
)

if exist "%LOCALAPPDATA%\Docker\Docker Desktop.exe" (
    echo [*] Found Docker Desktop at: %LOCALAPPDATA%\Docker\Docker Desktop.exe
    start "" "%LOCALAPPDATA%\Docker\Docker Desktop.exe"
    goto :wait
)

echo [ERROR] Docker Desktop not found in standard locations.
echo.
echo Please start Docker Desktop manually:
echo 1. Search for 'Docker Desktop' in Start Menu
echo 2. Click on Docker Desktop to launch it
echo 3. Wait for Docker Desktop to fully start (whale icon in system tray)
exit /b 1

:wait
echo.
echo ========================================
echo Waiting for Docker daemon to be ready...
echo ========================================
echo.

REM Wait for Docker daemon to be ready (up to 60 seconds)
set /a maxWait=60
set /a waited=0
set /a interval=2

:loop
timeout /t %interval% /nobreak >nul
set /a waited+=%interval%

docker ps >nul 2>&1
if %ERRORLEVEL%==0 (
    echo [OK] Docker daemon is ready!
    echo.
    docker --version
    docker compose version
    echo.
    echo You can now run: docker-compose up
    exit /b 0
)

if %waited% geq %maxWait% (
    echo [WARN] Docker Desktop may still be starting.
    echo Please check the Docker Desktop window/system tray icon.
    echo Once the whale icon stops animating, Docker is ready.
    exit /b 1
)

echo [*] Waiting for Docker daemon... (%waited%/%maxWait% seconds)
goto :loop

:verify
docker --version
docker compose version
echo.
echo [OK] Docker is ready to use!

