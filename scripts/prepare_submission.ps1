# PowerShell Script to Prepare Project Submission Folder
# This script creates a clean submission folder with all essential files

param(
    [string]$SubmissionFolder = "TweetMoodAI_Submission",
    [switch]$IncludeModelWeights = $false,
    [switch]$IncludeCheckpoints = $false,
    [switch]$IncludeGitHistory = $false
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TweetMoodAI - Submission Folder Creator" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get the project root directory (parent of scripts folder)
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$SubmissionPath = Join-Path $ProjectRoot $SubmissionFolder

# Remove existing submission folder if it exists
if (Test-Path $SubmissionPath) {
    Write-Host "Removing existing submission folder..." -ForegroundColor Yellow
    Remove-Item -Path $SubmissionPath -Recurse -Force
}

# Create submission folder
Write-Host "Creating submission folder: $SubmissionFolder" -ForegroundColor Green
New-Item -ItemType Directory -Path $SubmissionPath -Force | Out-Null

# Function to copy directory structure
function Copy-DirectoryStructure {
    param(
        [string]$Source,
        [string]$Destination,
        [string[]]$ExcludePatterns = @()
    )
    
    if (-not (Test-Path $Source)) {
        Write-Host "Warning: Source path does not exist: $Source" -ForegroundColor Yellow
        return
    }
    
    $destDir = Join-Path $Destination (Split-Path -Leaf $Source)
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    
    Get-ChildItem -Path $Source -Recurse -File | ForEach-Object {
        $relativePath = $_.FullName.Substring($Source.Length + 1)
        $shouldExclude = $false
        
        foreach ($pattern in $ExcludePatterns) {
            if ($relativePath -like $pattern) {
                $shouldExclude = $true
                break
            }
        }
        
        if (-not $shouldExclude) {
            $destFile = Join-Path $destDir $relativePath
            $destFileDir = Split-Path -Parent $destFile
            if (-not (Test-Path $destFileDir)) {
                New-Item -ItemType Directory -Path $destFileDir -Force | Out-Null
            }
            Copy-Item -Path $_.FullName -Destination $destFile -Force
        }
    }
}

# Function to copy file
function Copy-File {
    param(
        [string]$Source,
        [string]$Destination
    )
    
    if (Test-Path $Source) {
        $destDir = Split-Path -Parent $Destination
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        Copy-Item -Path $Source -Destination $Destination -Force
        Write-Host "  Copied: $Source" -ForegroundColor Gray
    } else {
        Write-Host "  Warning: File not found: $Source" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Copying files..." -ForegroundColor Green
Write-Host ""

# 1. Copy source code directories (excluding __pycache__)
Write-Host "1. Copying source code..." -ForegroundColor Cyan
Copy-DirectoryStructure -Source (Join-Path $ProjectRoot "app") -Destination $SubmissionPath -ExcludePatterns @("__pycache__\*", "*.pyc", "*.pyo")
Copy-DirectoryStructure -Source (Join-Path $ProjectRoot "ui") -Destination $SubmissionPath -ExcludePatterns @("__pycache__\*", "*.pyc", "*.pyo")
Copy-DirectoryStructure -Source (Join-Path $ProjectRoot "tests") -Destination $SubmissionPath -ExcludePatterns @("__pycache__\*", "*.pyc", "*.pyo")

# 2. Copy scripts (excluding __pycache__)
Write-Host "2. Copying scripts..." -ForegroundColor Cyan
Copy-DirectoryStructure -Source (Join-Path $ProjectRoot "scripts") -Destination $SubmissionPath -ExcludePatterns @("__pycache__\*", "*.pyc", "*.pyo")

# 3. Copy models (with options)
Write-Host "3. Copying model files..." -ForegroundColor Cyan
$modelExcludePatterns = @("__pycache__\*", "*.pyc", "*.pyo")

if (-not $IncludeCheckpoints) {
    $modelExcludePatterns += "checkpoints\*"
}

# Copy model structure
Copy-DirectoryStructure -Source (Join-Path $ProjectRoot "models") -Destination $SubmissionPath -ExcludePatterns $modelExcludePatterns

# Handle model weights file
if (-not $IncludeModelWeights) {
    $modelWeightsPath = Join-Path $SubmissionPath "models\sentiment_model\model.safetensors"
    if (Test-Path $modelWeightsPath) {
        Remove-Item -Path $modelWeightsPath -Force
        Write-Host "  Excluded: model.safetensors (use -IncludeModelWeights to include)" -ForegroundColor Yellow
    }
} else {
    Write-Host "  Included: model.safetensors (255 MB)" -ForegroundColor Green
}

# 4. Copy data files
Write-Host "4. Copying data files..." -ForegroundColor Cyan
Copy-DirectoryStructure -Source (Join-Path $ProjectRoot "data") -Destination $SubmissionPath -ExcludePatterns @()

# 5. Copy configuration files
Write-Host "5. Copying configuration files..." -ForegroundColor Cyan
Copy-File -Source (Join-Path $ProjectRoot "requirements.txt") -Destination (Join-Path $SubmissionPath "requirements.txt")
Copy-File -Source (Join-Path $ProjectRoot "train.py") -Destination (Join-Path $SubmissionPath "train.py")
Copy-File -Source (Join-Path $ProjectRoot "pytest.ini") -Destination (Join-Path $SubmissionPath "pytest.ini")
Copy-File -Source (Join-Path $ProjectRoot "pyrightconfig.json") -Destination (Join-Path $SubmissionPath "pyrightconfig.json")
Copy-File -Source (Join-Path $ProjectRoot "env.example") -Destination (Join-Path $SubmissionPath "env.example")
Copy-File -Source (Join-Path $ProjectRoot ".gitignore") -Destination (Join-Path $SubmissionPath ".gitignore")

# Copy .gitattributes if it exists
if (Test-Path (Join-Path $ProjectRoot ".gitattributes")) {
    Copy-File -Source (Join-Path $ProjectRoot ".gitattributes") -Destination (Join-Path $SubmissionPath ".gitattributes")
}

# 6. Copy Docker files
Write-Host "6. Copying Docker files..." -ForegroundColor Cyan
Copy-File -Source (Join-Path $ProjectRoot "Dockerfile.backend") -Destination (Join-Path $SubmissionPath "Dockerfile.backend")
Copy-File -Source (Join-Path $ProjectRoot "Dockerfile.frontend") -Destination (Join-Path $SubmissionPath "Dockerfile.frontend")
Copy-File -Source (Join-Path $ProjectRoot "docker-compose.yml") -Destination (Join-Path $SubmissionPath "docker-compose.yml")

# Copy .dockerignore if it exists
if (Test-Path (Join-Path $ProjectRoot ".dockerignore")) {
    Copy-File -Source (Join-Path $ProjectRoot ".dockerignore") -Destination (Join-Path $SubmissionPath ".dockerignore")
}

# 7. Copy deployment configuration
Write-Host "7. Copying deployment configuration..." -ForegroundColor Cyan
Copy-File -Source (Join-Path $ProjectRoot "render.yaml") -Destination (Join-Path $SubmissionPath "render.yaml")

# 8. Copy CI/CD configuration
Write-Host "8. Copying CI/CD configuration..." -ForegroundColor Cyan
$githubWorkflowsSource = Join-Path $ProjectRoot ".github\workflows"
if (Test-Path $githubWorkflowsSource) {
    Copy-DirectoryStructure -Source $githubWorkflowsSource -Destination (Join-Path $SubmissionPath ".github") -ExcludePatterns @()
}

# 9. Copy documentation files
Write-Host "9. Copying documentation..." -ForegroundColor Cyan
$docFiles = @(
    "README.md",
    "PROJECT_REPORT.md",
    "PROJECT_STRUCTURE.md",
    "DEPLOYMENT_READY.md",
    "LOCAL_TESTING_GUIDE.md",
    "DATASET_EXPANSION_GUIDE.md",
    "RENDER_DEPLOYMENT_GUIDE.md",
    "RENDER_QUICK_START.md",
    "QUICK_LAUNCH.md",
    "PROJECT_SUBMISSION_GUIDE.md"
)

foreach ($docFile in $docFiles) {
    Copy-File -Source (Join-Path $ProjectRoot $docFile) -Destination (Join-Path $SubmissionPath $docFile)
}

# 10. Copy FILES_ON_GITHUB.md (optional)
if (Test-Path (Join-Path $ProjectRoot "FILES_ON_GITHUB.md")) {
    Copy-File -Source (Join-Path $ProjectRoot "FILES_ON_GITHUB.md") -Destination (Join-Path $SubmissionPath "FILES_ON_GITHUB.md")
}

# 11. Copy Git history (if requested)
if ($IncludeGitHistory) {
    Write-Host "10. Copying Git history..." -ForegroundColor Cyan
    $gitSource = Join-Path $ProjectRoot ".git"
    if (Test-Path $gitSource) {
        Copy-DirectoryStructure -Source $gitSource -Destination (Join-Path $SubmissionPath ".git") -ExcludePatterns @()
        Write-Host "  Included: .git folder" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Submission folder created successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Location: $SubmissionPath" -ForegroundColor Yellow
Write-Host ""

# Calculate folder size
$folderSize = (Get-ChildItem -Path $SubmissionPath -Recurse -File | Measure-Object -Property Length -Sum).Sum
$folderSizeMB = [math]::Round($folderSize / 1MB, 2)
Write-Host "Total size: $folderSizeMB MB" -ForegroundColor Yellow
Write-Host ""

# Display summary
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  - Source code: Included" -ForegroundColor Green
Write-Host "  - Configuration files: Included" -ForegroundColor Green
Write-Host "  - Documentation: Included" -ForegroundColor Green
Write-Host "  - Docker files: Included" -ForegroundColor Green
Write-Host "  - Data files: Included" -ForegroundColor Green
Write-Host "  - Model config: Included" -ForegroundColor Green
if ($IncludeModelWeights) {
    Write-Host "  - Model weights: Included (255 MB)" -ForegroundColor Green
} else {
    Write-Host "  - Model weights: Excluded (use -IncludeModelWeights to include)" -ForegroundColor Yellow
}
if ($IncludeCheckpoints) {
    Write-Host "  - Model checkpoints: Included" -ForegroundColor Green
} else {
    Write-Host "  - Model checkpoints: Excluded" -ForegroundColor Yellow
}
Write-Host "  - Virtual environment: Excluded" -ForegroundColor Yellow
Write-Host "  - Python cache: Excluded" -ForegroundColor Yellow
Write-Host "  - Log files: Excluded" -ForegroundColor Yellow
Write-Host "  - .env file: Excluded (use env.example)" -ForegroundColor Yellow
if ($IncludeGitHistory) {
    Write-Host "  - Git history: Included" -ForegroundColor Green
} else {
    Write-Host "  - Git history: Excluded" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Review the submission folder" -ForegroundColor White
Write-Host "  2. Check PROJECT_SUBMISSION_GUIDE.md for details" -ForegroundColor White
Write-Host "  3. Verify all required files are included" -ForegroundColor White
Write-Host "  4. Create a zip file if needed" -ForegroundColor White
Write-Host "  5. Submit to your professor" -ForegroundColor White
Write-Host ""

# Create a note file about excluded files
$noteContent = @"
# Submission Notes

This submission folder was created on $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Included Files
- All source code (app/, ui/, scripts/, tests/)
- Configuration files (requirements.txt, pytest.ini, etc.)
- Docker files (Dockerfile.backend, Dockerfile.frontend, docker-compose.yml)
- Deployment configuration (render.yaml)
- CI/CD configuration (.github/workflows/ci.yml)
- Documentation files (README.md, PROJECT_REPORT.md, etc.)
- Model configuration files
- Data files

## Excluded Files
- Virtual environment (venv/) - Can be recreated using requirements.txt
- Python cache (__pycache__/) - Automatically generated
- Environment secrets (.env) - Use env.example template
- Log files (logs/) - Generated at runtime
- IDE files (.vscode/, .idea/) - Editor-specific

## Model Weights
Model weights file status: $(if ($IncludeModelWeights) { "INCLUDED" } else { "EXCLUDED - File size: 255 MB" })

$(if (-not $IncludeModelWeights) {
"If model weights are needed, you can:
1. Download from the original source
2. Rebuild using train.py script
3. Request separately if file size is an issue"
})

## Checkpoints
Model checkpoints status: $(if ($IncludeCheckpoints) { "INCLUDED" } else { "EXCLUDED - Not needed for running the application" })

## Git History
Git history status: $(if ($IncludeGitHistory) { "INCLUDED" } else { "EXCLUDED" })

## Setup Instructions
1. Create virtual environment: python -m venv venv
2. Activate virtual environment: venv\Scripts\activate (Windows) or source venv/bin/activate (Linux/Mac)
3. Install dependencies: pip install -r requirements.txt
4. Create .env file: cp env.example .env (then edit with your credentials)
5. Run application: uvicorn app.main:app --reload

See README.md for detailed setup instructions.
"@

$noteFile = Join-Path $SubmissionPath "SUBMISSION_NOTES.txt"
Set-Content -Path $noteFile -Value $noteContent
Write-Host "Created: SUBMISSION_NOTES.txt" -ForegroundColor Green
Write-Host ""

