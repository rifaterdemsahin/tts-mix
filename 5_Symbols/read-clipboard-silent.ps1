# Read Clipboard Text-to-Speech (Silent Version)
#
# This script reads text from the clipboard and speaks it using ElevenLabs TTS
# Priority: ElevenLabs (primary), fal.ai (fallback), Kokoro (local fallback)
# No popup messages - silent execution
# Designed for Stream Deck button integration
#
# Usage from Stream Deck:
#   Action: System > Open
#   App: powershell.exe
#   Arguments: -ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\projects\tts-mix\5_Symbols\read-clipboard-silent.ps1"

# ─── Logging Setup ────────────────────────────────────────
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
$LogDir = Join-Path $ProjectRoot "7_Testing_known\logs"
if (-not (Test-Path $LogDir)) { New-Item -Path $LogDir -ItemType Directory -Force | Out-Null }
$LogFile = Join-Path $LogDir "read-clipboard-silent_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
    Add-Content -Path $LogFile -Value "[$ts] [$Level] $Message" -Encoding UTF8 -ErrorAction SilentlyContinue
}

Write-Log "read-clipboard-silent.ps1 started"

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

# Exit silently if Python not found
if (-not $PythonExe) {
    Write-Log "Python not found" -Level "ERROR"
    exit 1
}

# Check if clipboard has content
$ClipboardText = Get-Clipboard -ErrorAction SilentlyContinue

# Exit silently if clipboard is empty
if (-not $ClipboardText) {
    Write-Log "Clipboard is empty" -Level "WARN"
    exit 0
}

# Run the TTS application (app.py is in the same directory)
$AppPath = Join-Path $ScriptDir "app.py"

# Exit silently if app not found
if (-not (Test-Path $AppPath)) {
    Write-Log "app.py not found at: $AppPath" -Level "ERROR"
    exit 1
}

# Execute Python script silently and track elapsed time
$Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
try {
    Start-Process -FilePath $PythonExe `
                  -ArgumentList $AppPath `
                  -WorkingDirectory $ScriptDir `
                  -WindowStyle Hidden `
                  -Wait
    $Stopwatch.Stop()
    $Elapsed = $Stopwatch.Elapsed
    Write-Log "TTS completed in $($Elapsed.TotalSeconds.ToString('F1'))s"

    # Log elapsed time (red text if running in a visible console)
    Write-Host "`n[TTS COMPLETE] Elapsed: $($Elapsed.ToString('mm\:ss\.ff'))" -ForegroundColor Red
}
catch {
    $Stopwatch.Stop()
    $Elapsed = $Stopwatch.Elapsed
    Write-Log "TTS exception: $($_.Exception.Message) after $($Elapsed.TotalSeconds.ToString('F1'))s" -Level "ERROR"
    Write-Host "`n[TTS ERROR] Elapsed: $($Elapsed.ToString('mm\:ss\.ff'))" -ForegroundColor Red
    exit 1
}
