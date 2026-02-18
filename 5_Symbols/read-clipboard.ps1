# Read Clipboard Text-to-Speech
#
# This script reads text from the clipboard and speaks it using ElevenLabs TTS
# Priority: ElevenLabs (primary), fal.ai (fallback), Kokoro (local fallback)
# Designed for Stream Deck button integration
#
# Usage from Stream Deck:
#   Action: System > Open
#   App: powershell.exe
#   Arguments: -ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\projects\tts-mix\5_Symbols\read-clipboard.ps1"

# ─── Logging Setup ────────────────────────────────────────
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
$LogDir = Join-Path $ProjectRoot "7_Testing_known\logs"
if (-not (Test-Path $LogDir)) { New-Item -Path $LogDir -ItemType Directory -Force | Out-Null }
$LogFile = Join-Path $LogDir "read-clipboard_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
    Add-Content -Path $LogFile -Value "[$ts] [$Level] $Message" -Encoding UTF8 -ErrorAction SilentlyContinue
}

Write-Log "read-clipboard.ps1 started"

# Change to script directory
Set-Location $ScriptDir

# Get Python path (try common locations)
$PythonPaths = @(
    "C:\Python314\python.exe",
    "C:\Python313\python.exe",
    "C:\Python312\python.exe",
    "C:\Python311\python.exe",
    "C:\Python310\python.exe",
    (Get-Command python -ErrorAction SilentlyContinue).Source,
    (Get-Command python3 -ErrorAction SilentlyContinue).Source
)

$PythonExe = $null
foreach ($path in $PythonPaths) {
    if ($path -and (Test-Path $path)) {
        $PythonExe = $path
        break
    }
}

if (-not $PythonExe) {
    Write-Log "Python not found" -Level "ERROR"
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show(
        "Python not found. Please install Python or update the script with your Python path.",
        "TTS Error",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    )
    exit 1
}

# Check if clipboard has content
$ClipboardText = Get-Clipboard -ErrorAction SilentlyContinue

if (-not $ClipboardText) {
    Write-Log "Clipboard is empty" -Level "WARN"
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show(
        "Clipboard is empty. Please copy some text first.",
        "TTS Info",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    )
    exit 0
}

# Run the TTS application (app.py is in the same directory)
$AppPath = Join-Path $ScriptDir "app.py"

if (-not (Test-Path $AppPath)) {
    Write-Log "app.py not found at: $AppPath" -Level "ERROR"
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show(
        "Could not find app.py at: $AppPath",
        "TTS Error",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    )
    exit 1
}

# Execute Python script and track elapsed time
$Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
try {
    & $PythonExe $AppPath
    $Stopwatch.Stop()
    $Elapsed = $Stopwatch.Elapsed

    # Check exit code
    if ($LASTEXITCODE -ne 0) {
        Write-Log "TTS failed (exit code: $LASTEXITCODE) after $($Elapsed.TotalSeconds.ToString('F1'))s" -Level "ERROR"
        Write-Host "`n[TTS FAILED] Elapsed: $($Elapsed.ToString('mm\:ss\.ff'))" -ForegroundColor Red
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show(
            "TTS failed after $($Elapsed.TotalSeconds.ToString('F1'))s.`n`nCheck your API key configuration in .env file.`nRun 'python 7_Testing_known/test_elevenlabs.py' to diagnose.",
            "TTS Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )
    } else {
        Write-Log "TTS completed in $($Elapsed.TotalSeconds.ToString('F1'))s"
        Write-Host "`n[TTS COMPLETE] Elapsed: $($Elapsed.ToString('mm\:ss\.ff'))" -ForegroundColor Red
    }
}
catch {
    $Stopwatch.Stop()
    $Elapsed = $Stopwatch.Elapsed
    Write-Log "TTS exception: $($_.Exception.Message) after $($Elapsed.TotalSeconds.ToString('F1'))s" -Level "ERROR"
    Write-Host "`n[TTS ERROR] Elapsed: $($Elapsed.ToString('mm\:ss\.ff'))" -ForegroundColor Red
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show(
        "Error running TTS after $($Elapsed.TotalSeconds.ToString('F1'))s: $($_.Exception.Message)",
        "TTS Error",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    )
    exit 1
}
