# Prepare Files for Manual GitHub Upload
# This script creates a clean copy of files ready for manual upload

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "PREPARING FILES FOR MANUAL UPLOAD" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$uploadDir = "TweetMoodAI_ForUpload"
$excludePatterns = @(
    ".git",
    ".git_backup_*",
    "venv",
    "__pycache__",
    "*.pyc",
    "*.pyo",
    "*.pyd",
    ".Python",
    "models/checkpoints",
    "*.safetensors",
    "*.optimizer.pt",
    "*.scheduler.pt",
    "*.rng_state.pth",
    ".env",
    "logs",
    "*.log"
)

Write-Host "[1/4] Creating upload directory..." -ForegroundColor Yellow
if (Test-Path $uploadDir) {
    Remove-Item -Path $uploadDir -Recurse -Force
    Write-Host "  Removed existing directory" -ForegroundColor Cyan
}
New-Item -Path $uploadDir -ItemType Directory | Out-Null
Write-Host "  [OK] Created: $uploadDir" -ForegroundColor Green

Write-Host ""
Write-Host "[2/4] Copying files (excluding large files)..." -ForegroundColor Yellow

$filesCopied = 0
$filesSkipped = 0
$totalSize = 0

Get-ChildItem -Path . -Recurse -File | Where-Object {
    $shouldCopy = $true
    $fullPath = $_.FullName
    
    # Check exclude patterns
    foreach ($pattern in $excludePatterns) {
        if ($fullPath -like "*$pattern*") {
            $shouldCopy = $false
            break
        }
    }
    
    # Check file size (skip files > 100 MB)
    if ($shouldCopy -and $_.Length -gt 100MB) {
        Write-Host "  [SKIP] Large file: $($_.Name) ($([math]::Round($_.Length/1MB, 2)) MB)" -ForegroundColor Yellow
        $shouldCopy = $false
        $script:filesSkipped++
    }
    
    # Check if it's in the upload directory itself
    if ($shouldCopy -and $fullPath -like "*$uploadDir*") {
        $shouldCopy = $false
    }
    
    if ($shouldCopy) {
        $relativePath = $_.FullName.Replace((Get-Location).Path + "\", "")
        $destPath = Join-Path $uploadDir $relativePath
        $destDir = Split-Path $destPath -Parent
        
        if (-not (Test-Path $destDir)) {
            New-Item -Path $destDir -ItemType Directory -Force | Out-Null
        }
        
        Copy-Item -Path $_.FullName -Destination $destPath -Force
        $script:filesCopied++
        $script:totalSize += $_.Length
    }
    
    $shouldCopy
} | Out-Null

Write-Host "  [OK] Copied $filesCopied files" -ForegroundColor Green
Write-Host "  [INFO] Skipped $filesSkipped large/unnecessary files" -ForegroundColor Cyan
Write-Host "  [INFO] Total size: $([math]::Round($totalSize/1MB, 2)) MB" -ForegroundColor Cyan

Write-Host ""
Write-Host "[3/4] Creating upload instructions..." -ForegroundColor Yellow
$instructions = @"
# Manual Upload Instructions

## Files ready in: $uploadDir

## Steps:

1. Go to: https://github.com/hetulpandya44/TweetMoodAI/upload

2. Drag and drop the entire '$uploadDir' folder contents

3. Commit message: "Initial commit: TweetMoodAI - Complete Steps 8-13"

4. Click "Commit changes"

## Files included:
- All source code (app/, ui/, tests/, scripts/)
- All documentation (*.md files)
- Configuration files (.gitignore, requirements.txt, etc.)
- Docker files
- Model config files (excluding large .safetensors)

## Files excluded (too large):
- models/checkpoints/ (entire directory)
- *.safetensors files
- *.optimizer.pt files
- venv/ directory
- .git_backup_* directories

## Total size: $([math]::Round($totalSize/1MB, 2)) MB
"@

Set-Content -Path "$uploadDir/UPLOAD_INSTRUCTIONS.txt" -Value $instructions
Write-Host "  [OK] Created upload instructions" -ForegroundColor Green

Write-Host ""
Write-Host "[4/4] Creating file list..." -ForegroundColor Yellow
$fileList = Get-ChildItem -Path $uploadDir -Recurse -File | ForEach-Object {
    $relativePath = $_.FullName.Replace((Get-Location).Path + "\$uploadDir\", "")
    $sizeKB = [math]::Round($_.Length / 1KB, 2)
    "$relativePath ($sizeKB KB)"
}
Set-Content -Path "$uploadDir/FILE_LIST.txt" -Value $fileList
Write-Host "  [OK] Created file list" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "READY FOR UPLOAD!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Files prepared in: $uploadDir" -ForegroundColor Yellow
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Go to: https://github.com/hetulpandya44/TweetMoodAI/upload" -ForegroundColor White
Write-Host "  2. Open the '$uploadDir' folder" -ForegroundColor White
Write-Host "  3. Select all files and folders" -ForegroundColor White
Write-Host "  4. Drag and drop into GitHub upload area" -ForegroundColor White
Write-Host "  5. Commit with message: 'Initial commit: TweetMoodAI - Complete Steps 8-13'" -ForegroundColor White
Write-Host ""
Write-Host "See UPLOAD_INSTRUCTIONS.txt in the folder for details." -ForegroundColor Cyan
Write-Host ""

