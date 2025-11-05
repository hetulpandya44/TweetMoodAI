#!/usr/bin/env python3
"""
Docker Setup Verification Script
Checks if Docker is installed and docker-compose.yml is valid
"""
import subprocess
import sys
import os
from pathlib import Path

def run_command(cmd, check=True):
    """Run a shell command and return result."""
    try:
        result = subprocess.run(
            cmd,
            shell=True,
            capture_output=True,
            text=True,
            check=check
        )
        return result.returncode == 0, result.stdout, result.stderr
    except Exception as e:
        return False, "", str(e)

def check_docker_installed():
    """Check if Docker is installed."""
    print("[*] Checking Docker installation...")
    success, stdout, stderr = run_command("docker --version", check=False)
    if success:
        print(f"[OK] Docker installed: {stdout.strip()}")
        return True
    else:
        print("[ERROR] Docker is not installed")
        print("   Install from: https://docs.docker.com/get-docker/")
        return False

def check_docker_compose_installed():
    """Check if Docker Compose is installed."""
    print("\n[*] Checking Docker Compose installation...")
    # Try 'docker compose' (newer) first, then 'docker-compose' (older)
    success, stdout, stderr = run_command("docker compose version", check=False)
    if success:
        print(f"[OK] Docker Compose installed: {stdout.strip()}")
        return True
    
    success, stdout, stderr = run_command("docker-compose --version", check=False)
    if success:
        print(f"[OK] Docker Compose installed: {stdout.strip()}")
        return True
    else:
        print("[ERROR] Docker Compose is not installed")
        return False

def check_docker_running():
    """Check if Docker daemon is running."""
    print("\n[*] Checking if Docker daemon is running...")
    success, stdout, stderr = run_command("docker ps", check=False)
    if success:
        print("[OK] Docker daemon is running")
        return True
    else:
        print("[ERROR] Docker daemon is not running")
        print("   Start Docker Desktop or Docker service")
        return False

def check_docker_files():
    """Check if required Docker files exist."""
    print("\n[*] Checking Docker configuration files...")
    files = {
        "docker-compose.yml": "Docker Compose configuration",
        "Dockerfile.backend": "Backend Dockerfile",
        "Dockerfile.frontend": "Frontend Dockerfile",
        ".dockerignore": "Docker ignore file"
    }
    
    all_exist = True
    for file, desc in files.items():
        path = Path(file)
        if path.exists():
            print(f"[OK] {file} exists ({desc})")
        else:
            print(f"[ERROR] {file} missing ({desc})")
            all_exist = False
    
    return all_exist

def check_env_file():
    """Check if .env file exists."""
    print("\n[*] Checking environment configuration...")
    env_path = Path(".env")
    env_example = Path("env.example")
    
    if env_path.exists():
        print("[OK] .env file exists")
        return True
    elif env_example.exists():
        print("[WARN] .env file not found, but env.example exists")
        print("   Copy env.example to .env and configure it:")
        print("   cp env.example .env")
        return False
    else:
        print("[ERROR] No .env or env.example file found")
        return False

def validate_docker_compose():
    """Validate docker-compose.yml syntax."""
    print("\n[*] Validating docker-compose.yml...")
    success, stdout, stderr = run_command("docker compose config", check=False)
    if success:
        print("[OK] docker-compose.yml is valid")
        return True
    else:
        print("[ERROR] docker-compose.yml has errors:")
        print(stderr)
        return False

def check_ports_available():
    """Check if required ports are available."""
    print("\n[*] Checking if ports are available...")
    ports = {
        8000: "Backend API",
        8501: "Frontend UI"
    }
    
    import socket
    all_available = True
    
    for port, service in ports.items():
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        result = sock.connect_ex(('localhost', port))
        sock.close()
        
        if result != 0:
            print(f"[OK] Port {port} is available ({service})")
        else:
            print(f"[WARN] Port {port} is already in use ({service})")
            print(f"   You may need to stop other services or change the port")
            all_available = False
    
    return all_available

def main():
    """Run all verification checks."""
    print("=" * 60)
    print("Docker Setup Verification")
    print("=" * 60)
    
    checks = [
        ("Docker Installation", check_docker_installed),
        ("Docker Compose Installation", check_docker_compose_installed),
        ("Docker Daemon", check_docker_running),
        ("Docker Files", check_docker_files),
        ("Environment File", check_env_file),
        ("Docker Compose Config", validate_docker_compose),
        ("Port Availability", check_ports_available),
    ]
    
    results = []
    for name, check_func in checks:
        try:
            result = check_func()
            results.append((name, result))
        except Exception as e:
            print(f"❌ Error checking {name}: {e}")
            results.append((name, False))
    
    print("\n" + "=" * 60)
    print("Verification Summary")
    print("=" * 60)
    
    all_passed = True
    for name, result in results:
        status = "[PASS]" if result else "[FAIL]"
        print(f"{status}: {name}")
        if not result:
            all_passed = False
    
    print("=" * 60)
    
    if all_passed:
        print("\n[OK] All checks passed! Ready to build and run:")
        print("\n   docker-compose build")
        print("   docker-compose up -d")
        return 0
    else:
        print("\n[WARN] Some checks failed. Please fix the issues above.")
        print("\n   Quick start:")
        print("   1. Install Docker Desktop")
        print("   2. Copy env.example to .env")
        print("   3. Configure .env with your settings")
        print("   4. Run: docker-compose build")
        return 1

if __name__ == "__main__":
    sys.exit(main())

