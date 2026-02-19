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

# ─── SecondBrain Save (clipboard text) ─────────────────────
$SecondBrainDir = "F:\secondbrain_v4\secondbrain"
$SavedFiles = @()

# Ensure SecondBrain directory exists
if (-not (Test-Path $SecondBrainDir)) {
    try {
        if (Test-Path "F:\") {
            New-Item -Path $SecondBrainDir -ItemType Directory -Force | Out-Null
            Write-Log "Created SecondBrain directory: $SecondBrainDir"
        } else {
            Write-Log "F: drive not available - SecondBrain saves will be skipped" -Level "WARN"
        }
    } catch {
        Write-Log "Cannot create SecondBrain dir: $($_.Exception.Message)" -Level "WARN"
    }
}

# Save clipboard text to SecondBrain as markdown
if (Test-Path $SecondBrainDir) {
    try {
        $Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $TextPath = Join-Path $SecondBrainDir "readclip_$Timestamp.md"
        $TextContent = "# Read Clipboard`n`n## Source`n`n$($ClipboardText -join "`n")`n"
        [System.IO.File]::WriteAllText($TextPath, $TextContent, [System.Text.UTF8Encoding]::new($true))
        Write-Log "SecondBrain text saved: $TextPath"
        $SavedFiles += $TextPath
    } catch {
        Write-Log "SecondBrain text save failed: $($_.Exception.Message)" -Level "ERROR"
    }
} else {
    Write-Log "SecondBrain directory not found - text not saved" -Level "WARN"
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
        Write-Host ""
        Write-Host ("=" * 60) -ForegroundColor Red
        Write-Host "  [X]  TTS FAILED" -ForegroundColor Red
        Write-Host ("=" * 60) -ForegroundColor Red
        Write-Host "     Elapsed: $($Elapsed.ToString('mm\:ss\.ff'))" -ForegroundColor Yellow
        Write-Host "     Check .env or run: python 7_Testing_known/test_elevenlabs.py" -ForegroundColor DarkGray
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show(
            "TTS failed after $($Elapsed.TotalSeconds.ToString('F1'))s.`n`nCheck your API key configuration in .env file.`nRun 'python 7_Testing_known/test_elevenlabs.py' to diagnose.",
            "TTS Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )
    } else {
        Write-Log "TTS completed in $($Elapsed.TotalSeconds.ToString('F1'))s"

        # Copy latest audio to SecondBrain
        if (Test-Path $SecondBrainDir) {
            try {
                $LatestAudio = Get-ChildItem -Path ([Environment]::GetFolderPath("UserProfile") + "\Downloads") -Filter "tts_*" -File |
                    Sort-Object LastWriteTime -Descending | Select-Object -First 1
                if ($LatestAudio) {
                    $SBAudioPath = Join-Path $SecondBrainDir "readclip_$($LatestAudio.BaseName.Split('_')[-2])_$($LatestAudio.BaseName.Split('_')[-1])$($LatestAudio.Extension)"
                    Copy-Item -Path $LatestAudio.FullName -Destination $SBAudioPath -Force
                    Write-Log "SecondBrain audio saved: $SBAudioPath"
                    $SavedFiles += $SBAudioPath
                }
            } catch {
                Write-Log "SecondBrain audio copy failed: $($_.Exception.Message)" -Level "ERROR"
            }
        }

        # Summary output (matching _base.ps1 look and feel)
        Write-Host ""
        Write-Host ("=" * 60) -ForegroundColor DarkGray
        Write-Host "  DONE  ALL STAGES COMPLETE" -ForegroundColor White
        Write-Host ("=" * 60) -ForegroundColor DarkGray
        Write-Host "     Total time: " -ForegroundColor DarkGray -NoNewline
        Write-Host "$($Elapsed.ToString('mm\:ss\.ff'))" -ForegroundColor White

        if ($SavedFiles.Count -gt 0) {
            Write-Host ""
            Write-Host "  Obsidian / SecondBrain saves:" -ForegroundColor Green
            foreach ($f in $SavedFiles) {
                $fileName = Split-Path $f -Leaf
                Write-Host "       [OK] $fileName" -ForegroundColor Green
            }
        }

        Write-Host "     Log: " -ForegroundColor DarkGray -NoNewline
        Write-Host $LogFile -ForegroundColor White
        Write-Host ""
        Write-Host "  [TOTAL: $($Elapsed.TotalSeconds.ToString('F1'))s]" -ForegroundColor Red
    }
}
catch {
    $Stopwatch.Stop()
    $Elapsed = $Stopwatch.Elapsed
    Write-Log "TTS exception: $($_.Exception.Message) after $($Elapsed.TotalSeconds.ToString('F1'))s" -Level "ERROR"
    Write-Host ""
    Write-Host ("=" * 60) -ForegroundColor Red
    Write-Host "  [X]  TTS ERROR" -ForegroundColor Red
    Write-Host ("=" * 60) -ForegroundColor Red
    Write-Host "     $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "     Elapsed: $($Elapsed.ToString('mm\:ss\.ff'))" -ForegroundColor DarkGray
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show(
        "Error running TTS after $($Elapsed.TotalSeconds.ToString('F1'))s: $($_.Exception.Message)",
        "TTS Error",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    )
    exit 1
}
