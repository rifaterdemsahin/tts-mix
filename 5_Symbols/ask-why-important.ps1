# Ask Why Important — xAI (Grok) + ElevenLabs TTS Pipeline
#
# Pipeline:
#   1. Read clipboard text
#   2. Send to xAI Grok API: "Why is this important?"
#   3. Convert Grok's answer to speech via ElevenLabs
#   4. Play audio
#
# Usage from Stream Deck:
#   Action: System > Open
#   App: powershell.exe
#   Arguments: -ExecutionPolicy Bypass -File "C:\projects\tts-mix\5_Symbols\ask-why-important.ps1"

# ─── Load .env ───────────────────────────────────────────
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
$EnvFile = Join-Path $ProjectRoot ".env"

$EnvVars = @{}
if (Test-Path $EnvFile) {
    Get-Content $EnvFile | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]+?)\s*=\s*(.+)\s*$') {
            $EnvVars[$Matches[1]] = $Matches[2]
        }
    }
}

$XAI_API_KEY = $EnvVars["XAI_API_KEY"]
$ELEVENLABS_API_KEY = $EnvVars["ELEVENLABS_API_KEY"]
$VOICE_ID = if ($EnvVars["VOICE_ID"]) { $EnvVars["VOICE_ID"] } else { "JBFqnCBsd6RMkjVDRZzb" }
$MODEL_ID = if ($EnvVars["MODEL_ID"]) { $EnvVars["MODEL_ID"] } else { "eleven_flash_v2_5" }

$DownloadsDir = [Environment]::GetFolderPath("UserProfile") + "\Downloads"
$SecondBrainDir = "F:\secondbrain_v4\secondbrain"
$Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

# ─── Helper: Print Stage ─────────────────────────────────
function Write-Stage {
    param([string]$Emoji, [string]$Text, [ConsoleColor]$Color = "White")
    Write-Host ""
    Write-Host ("=" * 60) -ForegroundColor DarkGray
    Write-Host "  $Emoji  $Text" -ForegroundColor $Color
    Write-Host ("=" * 60) -ForegroundColor DarkGray
}

function Write-Detail {
    param([string]$Label, [string]$Value, [ConsoleColor]$Color = "Gray")
    Write-Host "     $Label " -ForegroundColor DarkGray -NoNewline
    Write-Host $Value -ForegroundColor $Color
}

function Write-StatusOk {
    param([string]$Text)
    Write-Host "  ✅  $Text" -ForegroundColor Green
}

function Write-StatusFail {
    param([string]$Text)
    Write-Host "  ❌  $Text" -ForegroundColor Red
}

# ─── STAGE 1: Read Clipboard ─────────────────────────────
Write-Stage "📋" "STAGE 1 — Reading Clipboard" Cyan

$ClipboardText = Get-Clipboard -ErrorAction SilentlyContinue
if (-not $ClipboardText) {
    Write-StatusFail "Clipboard is empty! Copy some text first."
    exit 1
}

# Join array lines into single string
$ClipboardText = ($ClipboardText -join "`n").Trim()
$WordCount = ($ClipboardText -split '\s+').Count
$CharCount = $ClipboardText.Length

# Show clipboard content in a box
$MaxDisplay = if ($ClipboardText.Length -gt 120) { $ClipboardText.Substring(0, 120) + "..." } else { $ClipboardText }
Write-Host ""
Write-Host "  ┌$('─' * 56)┐" -ForegroundColor DarkYellow
foreach ($line in ($MaxDisplay -split "`n" | Select-Object -First 4)) {
    $padded = $line.PadRight(54).Substring(0, 54)
    Write-Host "  │ " -ForegroundColor DarkYellow -NoNewline
    Write-Host $padded -ForegroundColor Yellow -NoNewline
    Write-Host " │" -ForegroundColor DarkYellow
}
Write-Host "  └$('─' * 56)┘" -ForegroundColor DarkYellow
Write-Detail "Words:" "$WordCount" Yellow
Write-Detail "Chars:" "$CharCount" Yellow
Write-StatusOk "Clipboard captured"

# ─── STAGE 2: Validate API Keys ──────────────────────────
Write-Stage "🔑" "STAGE 2 — Checking API Keys" Magenta

if (-not $XAI_API_KEY) {
    Write-StatusFail "XAI_API_KEY not set in .env"
    exit 1
}
Write-Detail "xAI Key:" "$($XAI_API_KEY.Substring(0,8))...$($XAI_API_KEY.Substring($XAI_API_KEY.Length-6))" Magenta

if (-not $ELEVENLABS_API_KEY) {
    Write-StatusFail "ELEVENLABS_API_KEY not set in .env"
    exit 1
}
Write-Detail "ElevenLabs:" "$($ELEVENLABS_API_KEY.Substring(0,8))...$($ELEVENLABS_API_KEY.Substring($ELEVENLABS_API_KEY.Length-6))" Magenta
Write-Detail "Voice ID:" $VOICE_ID Magenta
Write-Detail "Model:" $MODEL_ID Magenta
Write-StatusOk "API keys validated"

# ─── STAGE 3: Ask xAI (Grok) ─────────────────────────────
Write-Stage "🧠" "STAGE 3 — Asking xAI Grok: Why is this important?" Blue

$GrokStart = [System.Diagnostics.Stopwatch]::StartNew()

$Prompt = @"
The user copied this text:

---
$ClipboardText
---

Explain in 2-3 concise sentences why this is important. Be insightful and direct. Respond in the same language as the text.
"@

$Body = @{
    model    = "grok-3-mini-fast"
    messages = @(
        @{ role = "system"; content = "You are a concise, insightful analyst. Keep responses brief (2-3 sentences max) and suitable for text-to-speech reading." }
        @{ role = "user"; content = $Prompt }
    )
    temperature = 0.7
    max_tokens  = 300
} | ConvertTo-Json -Depth 5

$Headers = @{
    "Authorization" = "Bearer $XAI_API_KEY"
    "Content-Type"  = "application/json"
}

try {
    Write-Host "     ⏳ Sending to Grok..." -ForegroundColor DarkCyan
    $Response = Invoke-RestMethod -Uri "https://api.x.ai/v1/chat/completions" `
                                  -Method Post `
                                  -Headers $Headers `
                                  -Body $Body `
                                  -TimeoutSec 30

    $GrokAnswer = $Response.choices[0].message.content.Trim()
    $GrokStart.Stop()
    $GrokElapsed = $GrokStart.Elapsed

    Write-Host ""
    Write-Host "  ┌$('─' * 56)┐" -ForegroundColor DarkCyan
    # Word-wrap the answer to fit in the box
    $Words = $GrokAnswer -split '\s+'
    $Line = ""
    $Lines = @()
    foreach ($word in $Words) {
        if (($Line + " " + $word).Trim().Length -gt 54) {
            $Lines += $Line.Trim()
            $Line = $word
        } else {
            $Line = ("$Line $word").Trim()
        }
    }
    if ($Line) { $Lines += $Line.Trim() }
    foreach ($l in $Lines | Select-Object -First 8) {
        $padded = $l.PadRight(54).Substring(0, 54)
        Write-Host "  │ " -ForegroundColor DarkCyan -NoNewline
        Write-Host $padded -ForegroundColor Cyan -NoNewline
        Write-Host " │" -ForegroundColor DarkCyan
    }
    Write-Host "  └$('─' * 56)┘" -ForegroundColor DarkCyan
    Write-Detail "Grok time:" "$($GrokElapsed.TotalSeconds.ToString('F1'))s" Blue
    Write-Detail "Tokens:" "$($Response.usage.total_tokens)" Blue

    # Save text to secondbrain
    if (Test-Path $SecondBrainDir) {
        $Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $TextPath = Join-Path $SecondBrainDir "why_$Timestamp.md"
        $TextContent = "# Why Is This Important?`n`n## Source`n`n$ClipboardText`n`n## Analysis (Grok)`n`n$GrokAnswer`n"
        [System.IO.File]::WriteAllText($TextPath, $TextContent, [System.Text.UTF8Encoding]::new($true))
        Write-Detail "Saved text:" $TextPath Blue
    }

    Write-StatusOk "Grok answered"
}
catch {
    $GrokStart.Stop()
    Write-StatusFail "xAI API call failed: $($_.Exception.Message)"
    exit 1
}

# ─── STAGE 4: Convert to Speech (ElevenLabs) ─────────────
Write-Stage "🔊" "STAGE 4 — Converting to Speech (ElevenLabs)" Green

$TTSStart = [System.Diagnostics.Stopwatch]::StartNew()

$TTSBody = @{
    text     = $GrokAnswer
    model_id = $MODEL_ID
} | ConvertTo-Json

$TTSHeaders = @{
    "xi-api-key"   = $ELEVENLABS_API_KEY
    "Content-Type" = "application/json"
    "Accept"       = "audio/mpeg"
}

try {
    Write-Host "     ⏳ Generating speech..." -ForegroundColor DarkGreen
    $Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $SavePath = Join-Path $DownloadsDir "tts_grok_$Timestamp.mp3"

    Invoke-RestMethod -Uri "https://api.elevenlabs.io/v1/text-to-speech/$VOICE_ID" `
                      -Method Post `
                      -Headers $TTSHeaders `
                      -Body $TTSBody `
                      -OutFile $SavePath `
                      -TimeoutSec 30

    $FileSize = (Get-Item $SavePath).Length
    $TTSStart.Stop()
    $TTSElapsed = $TTSStart.Elapsed

    Write-Detail "Saved:" $SavePath Green
    Write-Detail "Size:" "$([math]::Round($FileSize / 1024, 1)) KB" Green
    Write-Detail "TTS time:" "$($TTSElapsed.TotalSeconds.ToString('F1'))s" Green

    # Copy audio to secondbrain
    if (Test-Path $SecondBrainDir) {
        $SBSavePath = Join-Path $SecondBrainDir "why_$Timestamp.mp3"
        Copy-Item -Path $SavePath -Destination $SBSavePath -Force
        Write-Detail "SecondBrain:" $SBSavePath Green
    }

    Write-StatusOk "Audio generated"
}
catch {
    $TTSStart.Stop()
    Write-StatusFail "ElevenLabs TTS failed: $($_.Exception.Message)"
    exit 1
}

# ─── STAGE 5: Play Audio ─────────────────────────────────
Write-Stage "▶️" "STAGE 5 — Playing Audio" Yellow

try {
    Write-Host "     🔈 Playing..." -ForegroundColor DarkYellow

    Add-Type -AssemblyName presentationCore
    $Player = New-Object System.Windows.Media.MediaPlayer
    $Player.Open([Uri]$SavePath)
    Start-Sleep -Milliseconds 500
    $Player.Play()

    # Wait for playback to finish
    while (-not $Player.NaturalDuration.HasTimeSpan) {
        Start-Sleep -Milliseconds 200
    }
    $Duration = $Player.NaturalDuration.TimeSpan
    Write-Detail "Duration:" "$($Duration.TotalSeconds.ToString('F1'))s" Yellow

    Start-Sleep -Milliseconds ($Duration.TotalMilliseconds + 500)
    $Player.Close()

    Write-StatusOk "Playback complete"
}
catch {
    Write-StatusFail "Playback failed: $($_.Exception.Message)"
    # Don't exit — audio is saved even if playback fails
}

# ─── DONE ─────────────────────────────────────────────────
$Stopwatch.Stop()
$TotalElapsed = $Stopwatch.Elapsed

Write-Host ""
Write-Host ("=" * 60) -ForegroundColor DarkGray
Write-Host "  🏁  ALL STAGES COMPLETE" -ForegroundColor White
Write-Host ("=" * 60) -ForegroundColor DarkGray
Write-Detail "Total time:" "$($TotalElapsed.ToString('mm\:ss\.ff'))" White
Write-Host ""
Write-Host "  [TOTAL: $($TotalElapsed.TotalSeconds.ToString('F1'))s]" -ForegroundColor Red
Write-Host ""
