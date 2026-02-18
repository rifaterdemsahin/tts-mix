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

# Change to script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
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
    exit 1
}

# Check if clipboard has content
$ClipboardText = Get-Clipboard -ErrorAction SilentlyContinue

# Exit silently if clipboard is empty
if (-not $ClipboardText) {
    exit 0
}

# Run the TTS application (app.py is in the same directory)
$AppPath = Join-Path $ScriptDir "app.py"

# Exit silently if app not found
if (-not (Test-Path $AppPath)) {
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

    # Log elapsed time (red text if running in a visible console)
    Write-Host "`n[TTS COMPLETE] Elapsed: $($Elapsed.ToString('mm\:ss\.ff'))" -ForegroundColor Red
}
catch {
    $Stopwatch.Stop()
    $Elapsed = $Stopwatch.Elapsed
    Write-Host "`n[TTS ERROR] Elapsed: $($Elapsed.ToString('mm\:ss\.ff'))" -ForegroundColor Red
    exit 1
}
