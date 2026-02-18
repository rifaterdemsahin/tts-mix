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

if (-not $PythonExe) {
    # Show error notification
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
    # Show notification - clipboard is empty
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
    # Show error notification
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
        # Show error notification with elapsed time in red
        Write-Host "`n[TTS FAILED] Elapsed: $($Elapsed.ToString('mm\:ss\.ff'))" -ForegroundColor Red
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show(
            "TTS failed after $($Elapsed.TotalSeconds.ToString('F1'))s.`n`nCheck your API key configuration in .env file.`nRun 'python 7_Testing_known/test_elevenlabs.py' to diagnose.",
            "TTS Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )
    } else {
        # Show elapsed time in red
        Write-Host "`n[TTS COMPLETE] Elapsed: $($Elapsed.ToString('mm\:ss\.ff'))" -ForegroundColor Red
    }
}
catch {
    $Stopwatch.Stop()
    $Elapsed = $Stopwatch.Elapsed
    # Show error notification with exception details and elapsed time
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
