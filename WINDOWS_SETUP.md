# Windows PowerShell Setup Guide

This guide provides step-by-step instructions for setting up the Kokoro TTS system on Windows using PowerShell.

## Prerequisites

- Windows 10 or later
- PowerShell 5.1 or later (PowerShell 7+ recommended)
- Internet connection
- Administrator access (for some installations)

## Step 1: Install Python 3.8+

1. Download Python from [python.org](https://www.python.org/downloads/)
2. Run the installer
3. **IMPORTANT**: Check "Add Python to PATH" during installation
4. Verify installation:

```powershell
python --version
# Should output: Python 3.x.x
```

## Step 2: Install espeak-ng

espeak-ng is required by Kokoro for phoneme processing.

1. Download the latest Windows installer (.msi) from:
   https://github.com/espeak-ng/espeak-ng/releases

2. Run the installer (e.g., `espeak-ng-X64.msi`)

3. During installation, ensure it's added to PATH

4. **Restart PowerShell** after installation

5. Verify installation:

```powershell
espeak-ng --version
# Should output version information
```

### Troubleshooting espeak-ng

If `espeak-ng --version` doesn't work after installation:

1. Add to PATH manually:
   - Open System Properties → Environment Variables
   - Add `C:\Program Files\eSpeak NG` to PATH
   - Restart PowerShell

2. Verify the installation directory exists:
   ```powershell
   Test-Path "C:\Program Files\eSpeak NG\espeak-ng.exe"
   ```

## Step 3: Clone the Kokoro-82M-WebUI Repository

```powershell
# Navigate to your projects directory
cd C:\projects

# Clone the repository
git clone https://github.com/NeuralFalconYT/Kokoro-82M-WebUI.git

# Enter the directory
cd Kokoro-82M-WebUI
```

## Step 4: Create Virtual Environment

Always use a virtual environment to avoid dependency conflicts:

```powershell
# Create virtual environment
python -m venv venv

# Activate the virtual environment
.\venv\Scripts\Activate.ps1
```

### If PowerShell Execution Policy Prevents Activation

You may see an error like:
```
.\venv\Scripts\Activate.ps1 : File cannot be loaded because running scripts is disabled on this system.
```

**Solution:**
```powershell
# Set execution policy for current user (run as Administrator)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Then try activating again
.\venv\Scripts\Activate.ps1
```

Your prompt should now show `(venv)` at the beginning:
```
(venv) PS C:\projects\Kokoro-82M-WebUI>
```

## Step 5: Upgrade pip

```powershell
python -m pip install --upgrade pip
```

## Step 6: Install Dependencies

### Method A: Install from requirements.txt (if available)

```powershell
pip install -r requirements.txt
```

### Method B: Manual Installation

If requirements.txt is missing or causes issues:

```powershell
# Install core dependencies
pip install phonemizer>=3.3.0
pip install scipy>=1.14.1
pip install munch>=4.0.0
pip install transformers>=4.47.1
pip install click>=8.1.8
pip install librosa>=0.10.2
pip install gradio>=5.9.1
pip install huggingface-hub>=0.27.0
pip install pydub>=0.25.1

# Additional dependencies for TTS
pip install sounddevice
pip install numpy
pip install pyperclip
pip install elevenlabs
```

### Common Installation Issues

#### Issue: "No module named 'kokoro'"

**Solution:** Install kokoro from source:
```powershell
# Clone kokoro repository
cd C:\projects
git clone https://github.com/remixer-dec/kokoro-82m
cd kokoro-82m

# Install in editable mode
pip install -e .

# Return to Kokoro-82M-WebUI
cd C:\projects\Kokoro-82M-WebUI
```

#### Issue: PortAudio/sounddevice installation fails

**Solution:** Use conda or pre-built wheels:
```powershell
# If using conda
conda install portaudio

# Or try upgrading
pip install --upgrade sounddevice
```

#### Issue: "Microsoft Visual C++ 14.0 or greater is required"

**Solution:** Install Microsoft C++ Build Tools:
1. Download from: https://visualstudio.microsoft.com/visual-cpp-build-tools/
2. Install "Desktop development with C++"
3. Restart PowerShell and try pip install again

## Step 7: Test Your Setup

Create a test file to verify everything works:

```powershell
# Download the diagnostic script
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/rifaterdemsahin/tts-mix/main/test_setup.py" -OutFile "test_setup.py"

# Run diagnostic
python test_setup.py
```

Expected output:
```
✓ pyperclip installed
✓ sounddevice installed
✓ numpy installed
✓ kokoro installed
✓ elevenlabs installed
✓ espeak-ng found
✓ Audio test completed
```

## Step 8: Run the Application

```powershell
python app.py
```

Or if using Gradio WebUI:
```powershell
python main.py
# Open browser to http://localhost:7860
```

## Complete Setup Script

Save this as `setup.ps1` for automated setup:

```powershell
# Kokoro TTS Setup Script for Windows
# Run in PowerShell as Administrator

Write-Host "=== Kokoro TTS Setup Script ===" -ForegroundColor Green

# Check Python
Write-Host "`nChecking Python installation..." -ForegroundColor Yellow
try {
    $pythonVersion = python --version 2>&1
    Write-Host "✓ $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Python not found. Please install from python.org" -ForegroundColor Red
    exit 1
}

# Check espeak-ng
Write-Host "`nChecking espeak-ng installation..." -ForegroundColor Yellow
try {
    $espeakVersion = espeak-ng --version 2>&1 | Select-Object -First 1
    Write-Host "✓ $espeakVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ espeak-ng not found." -ForegroundColor Red
    Write-Host "Download from: https://github.com/espeak-ng/espeak-ng/releases" -ForegroundColor Yellow
    $continue = Read-Host "Continue anyway? (y/n)"
    if ($continue -ne 'y') { exit 1 }
}

# Create projects directory
Write-Host "`nCreating projects directory..." -ForegroundColor Yellow
$projectsDir = "C:\projects"
if (-not (Test-Path $projectsDir)) {
    New-Item -ItemType Directory -Path $projectsDir | Out-Null
    Write-Host "✓ Created $projectsDir" -ForegroundColor Green
} else {
    Write-Host "✓ $projectsDir exists" -ForegroundColor Green
}

# Clone repository
Write-Host "`nCloning Kokoro-82M-WebUI..." -ForegroundColor Yellow
Set-Location $projectsDir
if (Test-Path "Kokoro-82M-WebUI") {
    Write-Host "✓ Repository already exists" -ForegroundColor Green
} else {
    git clone https://github.com/NeuralFalconYT/Kokoro-82M-WebUI.git
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Repository cloned successfully" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to clone repository" -ForegroundColor Red
        exit 1
    }
}

Set-Location "Kokoro-82M-WebUI"

# Create virtual environment
Write-Host "`nCreating virtual environment..." -ForegroundColor Yellow
if (Test-Path "venv") {
    Write-Host "✓ Virtual environment already exists" -ForegroundColor Green
} else {
    python -m venv venv
    Write-Host "✓ Virtual environment created" -ForegroundColor Green
}

# Activate virtual environment
Write-Host "`nActivating virtual environment..." -ForegroundColor Yellow
& .\venv\Scripts\Activate.ps1
Write-Host "✓ Virtual environment activated" -ForegroundColor Green

# Upgrade pip
Write-Host "`nUpgrading pip..." -ForegroundColor Yellow
python -m pip install --upgrade pip --quiet
Write-Host "✓ pip upgraded" -ForegroundColor Green

# Install dependencies
Write-Host "`nInstalling dependencies..." -ForegroundColor Yellow
if (Test-Path "requirements.txt") {
    pip install -r requirements.txt --quiet
} else {
    # Install core dependencies manually
    $packages = @(
        "phonemizer>=3.3.0",
        "scipy>=1.14.1",
        "munch>=4.0.0",
        "transformers>=4.47.1",
        "click>=8.1.8",
        "librosa>=0.10.2",
        "gradio>=5.9.1",
        "huggingface-hub>=0.27.0",
        "pydub>=0.25.1",
        "sounddevice",
        "numpy",
        "pyperclip",
        "elevenlabs"
    )
    
    foreach ($package in $packages) {
        pip install $package --quiet
    }
}
Write-Host "✓ Dependencies installed" -ForegroundColor Green

# Test setup
Write-Host "`nTesting setup..." -ForegroundColor Yellow
python -c "import sounddevice; import numpy; import pyperclip; print('✓ Core packages working')" 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Setup test passed" -ForegroundColor Green
} else {
    Write-Host "⚠ Some packages may have issues" -ForegroundColor Yellow
}

Write-Host "`n=== Setup Complete ===" -ForegroundColor Green
Write-Host "`nNext steps:"
Write-Host "1. Ensure espeak-ng is installed and in PATH"
Write-Host "2. Run: python app.py"
Write-Host "3. For issues, see: https://github.com/rifaterdemsahin/tts-mix/blob/main/TROUBLESHOOTING.md"
```

## Running the Setup Script

1. Save the script above as `setup.ps1`

2. Run in PowerShell (as Administrator):
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
   .\setup.ps1
   ```

## Quick Reference Commands

```powershell
# Activate virtual environment
cd C:\projects\Kokoro-82M-WebUI
.\venv\Scripts\Activate.ps1

# Deactivate virtual environment
deactivate

# Update dependencies
pip install --upgrade -r requirements.txt

# Check installed packages
pip list

# Run application
python app.py

# Run diagnostic
python test_setup.py
```

## Common Error Messages and Solutions

### Error: "python: command not found"
- **Solution**: Restart PowerShell after installing Python, or add Python to PATH manually

### Error: "espeak-ng: command not found"
- **Solution**: Install espeak-ng and add to PATH (see Step 2)

### Error: "Traceback at line 3: ModuleNotFoundError"
- **Solution**: Install missing package with `pip install <package-name>`
- **See**: [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for detailed solutions

### Error: "No audio output"
- **Solution**: Check default audio device in Windows Sound settings
- **Test**: Run `python test_setup.py` to test audio

### Error: "Access is denied" when activating venv
- **Solution**: Run PowerShell as Administrator or adjust execution policy

## Additional Resources

- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Detailed troubleshooting guide
- [test_setup.py](test_setup.py) - Diagnostic tool
- [Kokoro GitHub](https://github.com/remixer-dec/kokoro-82m) - Kokoro TTS source
- [espeak-ng Releases](https://github.com/espeak-ng/espeak-ng/releases) - Latest espeak-ng versions

## Support

If you encounter issues not covered here:
1. Run `python test_setup.py` to diagnose the problem
2. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
3. Verify all prerequisites are installed
4. Ensure espeak-ng is in PATH
