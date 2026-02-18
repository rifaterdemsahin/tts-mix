# Kokoro TTS Setup Script for Windows
# Run in PowerShell: .\kokoro_setup.ps1
# Or with bypass: powershell -ExecutionPolicy Bypass -File .\kokoro_setup.ps1

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Kokoro TTS Setup Script for Windows" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "⚠ Not running as Administrator. Some features may not work." -ForegroundColor Yellow
    Write-Host "  Right-click PowerShell and select 'Run as Administrator' for full functionality.`n" -ForegroundColor Yellow
}

# Function to test command availability
function Test-Command {
    param($cmdname)
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

# Check Python
Write-Host "[1/8] Checking Python installation..." -ForegroundColor Yellow
if (Test-Command python) {
    $pythonVersion = python --version 2>&1
    Write-Host "      ✓ $pythonVersion" -ForegroundColor Green
    
    # Check Python version is 3.8+
    $versionMatch = $pythonVersion -match '(\d+)\.(\d+)'
    if ($versionMatch) {
        $major = [int]$Matches[1]
        $minor = [int]$Matches[2]
        if ($major -lt 3 -or ($major -eq 3 -and $minor -lt 8)) {
            Write-Host "      ✗ Python 3.8+ required. Current: $pythonVersion" -ForegroundColor Red
            Write-Host "      Download from: https://www.python.org/downloads/" -ForegroundColor Yellow
            exit 1
        }
    }
} else {
    Write-Host "      ✗ Python not found" -ForegroundColor Red
    Write-Host "      Download from: https://www.python.org/downloads/" -ForegroundColor Yellow
    Write-Host "      Make sure to check 'Add Python to PATH' during installation" -ForegroundColor Yellow
    exit 1
}

# Check Git
Write-Host "`n[2/8] Checking Git installation..." -ForegroundColor Yellow
if (Test-Command git) {
    $gitVersion = git --version 2>&1
    Write-Host "      ✓ $gitVersion" -ForegroundColor Green
} else {
    Write-Host "      ✗ Git not found" -ForegroundColor Red
    Write-Host "      Download from: https://git-scm.com/download/win" -ForegroundColor Yellow
    exit 1
}

# Check espeak-ng
Write-Host "`n[3/8] Checking espeak-ng installation..." -ForegroundColor Yellow
if (Test-Command espeak-ng) {
    $espeakVersion = espeak-ng --version 2>&1 | Select-Object -First 1
    Write-Host "      ✓ $espeakVersion" -ForegroundColor Green
} else {
    Write-Host "      ✗ espeak-ng not found" -ForegroundColor Red
    Write-Host "      This is REQUIRED for Kokoro TTS to work!" -ForegroundColor Yellow
    Write-Host "      Download from: https://github.com/espeak-ng/espeak-ng/releases" -ForegroundColor Yellow
    Write-Host "      Install the .msi file and restart PowerShell" -ForegroundColor Yellow
    
    $response = Read-Host "`n      Continue anyway? (y/n)"
    if ($response -ne 'y') {
        Write-Host "`nSetup cancelled. Please install espeak-ng first." -ForegroundColor Red
        exit 1
    }
}

# Create projects directory
Write-Host "`n[4/8] Setting up projects directory..." -ForegroundColor Yellow
$projectsDir = "C:\projects"
if (-not (Test-Path $projectsDir)) {
    try {
        New-Item -ItemType Directory -Path $projectsDir -Force | Out-Null
        Write-Host "      ✓ Created $projectsDir" -ForegroundColor Green
    } catch {
        Write-Host "      ✗ Failed to create $projectsDir" -ForegroundColor Red
        $projectsDir = Read-Host "      Enter alternate directory path"
        New-Item -ItemType Directory -Path $projectsDir -Force | Out-Null
    }
} else {
    Write-Host "      ✓ Directory exists: $projectsDir" -ForegroundColor Green
}

# Clone repository
Write-Host "`n[5/8] Cloning Kokoro-82M-WebUI repository..." -ForegroundColor Yellow
$repoPath = Join-Path $projectsDir "Kokoro-82M-WebUI"

if (Test-Path $repoPath) {
    Write-Host "      ✓ Repository already exists at: $repoPath" -ForegroundColor Green
    $response = Read-Host "      Pull latest changes? (y/n)"
    if ($response -eq 'y') {
        Set-Location $repoPath
        git pull
        Write-Host "      ✓ Repository updated" -ForegroundColor Green
    }
} else {
    Set-Location $projectsDir
    try {
        git clone https://github.com/NeuralFalconYT/Kokoro-82M-WebUI.git 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "      ✓ Repository cloned successfully" -ForegroundColor Green
        } else {
            throw "Git clone failed"
        }
    } catch {
        Write-Host "      ✗ Failed to clone repository" -ForegroundColor Red
        Write-Host "      Error: $_" -ForegroundColor Red
        exit 1
    }
}

Set-Location $repoPath

# Create virtual environment
Write-Host "`n[6/8] Setting up virtual environment..." -ForegroundColor Yellow
$venvPath = Join-Path $repoPath "venv"

if (Test-Path $venvPath) {
    Write-Host "      ✓ Virtual environment already exists" -ForegroundColor Green
} else {
    try {
        python -m venv venv
        Write-Host "      ✓ Virtual environment created" -ForegroundColor Green
    } catch {
        Write-Host "      ✗ Failed to create virtual environment" -ForegroundColor Red
        exit 1
    }
}

# Activate virtual environment
Write-Host "`n[7/8] Activating virtual environment..." -ForegroundColor Yellow
$activateScript = Join-Path $venvPath "Scripts\Activate.ps1"

try {
    & $activateScript
    Write-Host "      ✓ Virtual environment activated" -ForegroundColor Green
} catch {
    Write-Host "      ✗ Failed to activate virtual environment" -ForegroundColor Red
    Write-Host "      Try running: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor Yellow
    
    # Try to set execution policy
    try {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        & $activateScript
        Write-Host "      ✓ Execution policy updated and venv activated" -ForegroundColor Green
    } catch {
        Write-Host "      ✗ Still failed. You may need to run PowerShell as Administrator" -ForegroundColor Red
        exit 1
    }
}

# Upgrade pip
Write-Host "`n      Upgrading pip..." -ForegroundColor Yellow
python -m pip install --upgrade pip --quiet

# Install dependencies
Write-Host "`n[8/8] Installing dependencies..." -ForegroundColor Yellow
Write-Host "      This may take several minutes..." -ForegroundColor Cyan

$requirementsFile = Join-Path $repoPath "requirements.txt"

if (Test-Path $requirementsFile) {
    Write-Host "      Installing from requirements.txt..." -ForegroundColor Cyan
    pip install -r requirements.txt
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "      ✓ Dependencies installed successfully" -ForegroundColor Green
    } else {
        Write-Host "      ⚠ Some packages may have failed to install" -ForegroundColor Yellow
    }
} else {
    Write-Host "      No requirements.txt found, installing core packages..." -ForegroundColor Cyan
    
    $packages = @(
        "phonemizer>=3.3.0",
        "scipy",
        "munch",
        "transformers",
        "click",
        "librosa",
        "gradio",
        "huggingface-hub",
        "pydub",
        "sounddevice",
        "numpy",
        "pyperclip"
    )
    
    foreach ($package in $packages) {
        Write-Host "      Installing $package..." -ForegroundColor Cyan
        pip install $package --quiet
    }
    
    Write-Host "      ✓ Core packages installed" -ForegroundColor Green
}

# Test the installation
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  Testing Installation" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Running diagnostic tests..." -ForegroundColor Yellow
python -c @"
import sys
print('Testing imports...')
try:
    import numpy
    print('  ✓ numpy')
except: print('  ✗ numpy')
try:
    import sounddevice
    print('  ✓ sounddevice')
except: print('  ✗ sounddevice')
try:
    import pyperclip
    print('  ✓ pyperclip')
except: print('  ✗ pyperclip')
try:
    import gradio
    print('  ✓ gradio')
except: print('  ✗ gradio')
"@

# Final summary
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  Setup Complete!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Make sure espeak-ng is installed (critical!)" -ForegroundColor White
Write-Host "     Download: https://github.com/espeak-ng/espeak-ng/releases" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Activate the virtual environment:" -ForegroundColor White
Write-Host "     cd $repoPath" -ForegroundColor Gray
Write-Host "     .\venv\Scripts\Activate.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. Run the application:" -ForegroundColor White
Write-Host "     python app.py" -ForegroundColor Gray
Write-Host ""
Write-Host "  4. For troubleshooting, see:" -ForegroundColor White
Write-Host "     https://github.com/rifaterdemsahin/tts-mix/blob/main/TROUBLESHOOTING.md" -ForegroundColor Gray
Write-Host ""
Write-Host "Current location: $repoPath" -ForegroundColor Cyan
Write-Host ""
