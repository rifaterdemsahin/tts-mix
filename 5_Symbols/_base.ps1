# _base.ps1 - Centralized Base Module for TTS Pipeline Scripts
#
# Provides:
#   - Debug logging (screen + file in 7_Testing_known/logs/)
#   - .env loading
#   - UI helper functions (Write-Stage, Write-Detail, etc.)
#   - Clipboard reading (Stage 1)
#   - API key validation (Stage 2)
#   - LLM call with fallback (Stage 3)
#   - TTS with ElevenLabs / fal.ai fallback (Stage 4)
#   - Audio playback (Stage 5)
#   - Summary (Stage 6)
#
# Usage from pipeline scripts:
#   $PipelineConfig = @{ Name = "sanity-check"; Title = "Sanity Check"; ... }
#   . "$PSScriptRoot\_base.ps1"
#   Invoke-Pipeline

# ============================================================
#  LOGGING SYSTEM
# ============================================================

# Force UTF-8 for all output and web requests
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

$ErrorActionPreference = "Stop"

# Resolve paths
$script:ScriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$script:ProjectRoot = Split-Path -Parent $script:ScriptDir
$script:LogDir      = Join-Path $script:ProjectRoot "7_Testing_known\logs"

# Ensure log directory exists
if (-not (Test-Path $script:LogDir)) {
    New-Item -Path $script:LogDir -ItemType Directory -Force | Out-Null
}

# Create log file for this run
$script:RunTimestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$script:PipelineName = if ($PipelineConfig.Name) { $PipelineConfig.Name } else { "unknown" }
$script:LogFile = Join-Path $script:LogDir "$($script:PipelineName)_$($script:RunTimestamp).log"

# Box-drawing characters (defined once, avoids encoding issues)
$script:BOX_H  = [char]0x2500  # horizontal line
$script:BOX_TL = [char]0x250C  # top-left corner
$script:BOX_TR = [char]0x2510  # top-right corner
$script:BOX_BL = [char]0x2514  # bottom-left corner
$script:BOX_BR = [char]0x2518  # bottom-right corner
$script:BOX_V  = [char]0x2502  # vertical line

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO","WARN","ERROR","DEBUG","STAGE")]
        [string]$Level = "INFO"
    )
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
    $line = "[$ts] [$Level] $Message"
    Add-Content -Path $script:LogFile -Value $line -Encoding UTF8 -ErrorAction SilentlyContinue
}

function Write-LogHeader {
    $separator = "=" * 60
    $header = @(
        $separator
        "  Pipeline: $($PipelineConfig.Title)"
        "  Script:   $($PipelineConfig.Name).ps1"
        "  Started:  $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        "  Log:      $($script:LogFile)"
        $separator
        ""
    ) -join "`n"
    Set-Content -Path $script:LogFile -Value $header -Encoding UTF8 -ErrorAction SilentlyContinue
}

# ============================================================
#  GLOBAL ERROR TRAP
# ============================================================

trap {
    $errMsg = $_.Exception.Message
    $errLine = $_.InvocationInfo.ScriptLineNumber
    $errScript = $_.InvocationInfo.ScriptName
    Write-Log "UNEXPECTED ERROR: $errMsg at ${errScript}:${errLine}" -Level ERROR
    Write-Host ""
    Write-Host ("=" * 60) -ForegroundColor Red
    Write-Host "  [X]  UNEXPECTED ERROR" -ForegroundColor Red
    Write-Host ("=" * 60) -ForegroundColor Red
    Write-Host "  $errMsg" -ForegroundColor Yellow
    Write-Host "  At: ${errScript}:${errLine}" -ForegroundColor DarkGray
    Write-Host "  Log: $($script:LogFile)" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "Press Enter to close..." -ForegroundColor Red
    [Console]::ReadLine() | Out-Null
    exit 1
}

# ============================================================
#  .ENV LOADING
# ============================================================

$script:EnvFile = Join-Path $script:ProjectRoot ".env"
$script:EnvVars = @{}

if (Test-Path $script:EnvFile) {
    Get-Content $script:EnvFile | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]+?)\s*=\s*(.+)\s*$') {
            $script:EnvVars[$Matches[1]] = $Matches[2]
        }
    }
}

$script:XAI_API_KEY        = $script:EnvVars["XAI_API_KEY"]
$script:OPENROUTER_API_KEY = $script:EnvVars["OPENROUTER_API_KEY"]
$script:ELEVENLABS_API_KEY = $script:EnvVars["ELEVENLABS_API_KEY"]
$script:FAL_KEY            = $script:EnvVars["FAL_KEY"]
$script:VOICE_ID = if ($script:EnvVars["VOICE_ID"]) { $script:EnvVars["VOICE_ID"] } else { "JBFqnCBsd6RMkjVDRZzb" }
$script:MODEL_ID = if ($script:EnvVars["MODEL_ID"]) { $script:EnvVars["MODEL_ID"] } else { "eleven_flash_v2_5" }

$script:DownloadsDir   = [Environment]::GetFolderPath("UserProfile") + "\Downloads"
$script:SecondBrainDir = "F:\secondbrain_v4\secondbrain"

# Ensure SecondBrain directory exists (create if F: drive is accessible)
if (-not (Test-Path $script:SecondBrainDir)) {
    try {
        if (Test-Path "F:\") {
            New-Item -Path $script:SecondBrainDir -ItemType Directory -Force | Out-Null
            Write-Host "  [OK]  Created SecondBrain directory: $($script:SecondBrainDir)" -ForegroundColor Green
        } else {
            Write-Host "  [WARN]  F: drive not available - SecondBrain saves will be skipped" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  [WARN]  Cannot create SecondBrain dir: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# ============================================================
#  UI HELPER FUNCTIONS (screen + log)
# ============================================================

function Write-Stage {
    param([string]$Emoji, [string]$Text, [ConsoleColor]$Color = "White")
    Write-Log "== $Text ==" -Level STAGE
    Write-Host ""
    Write-Host ("=" * 60) -ForegroundColor DarkGray
    Write-Host "  $Emoji  $Text" -ForegroundColor $Color
    Write-Host ("=" * 60) -ForegroundColor DarkGray
}

function Write-Detail {
    param([string]$Label, [string]$Value, [ConsoleColor]$Color = "Gray")
    Write-Log "$Label $Value" -Level DEBUG
    Write-Host "     $Label " -ForegroundColor DarkGray -NoNewline
    Write-Host $Value -ForegroundColor $Color
}

function Write-StatusOk {
    param([string]$Text)
    Write-Log "OK: $Text" -Level INFO
    Write-Host "  [OK]  $Text" -ForegroundColor Green
}

function Write-StatusFail {
    param([string]$Text)
    Write-Log "FAIL: $Text" -Level ERROR
    Write-Host "  [FAIL]  $Text" -ForegroundColor Red
}

function Write-StatusWarn {
    param([string]$Text)
    Write-Log "WARN: $Text" -Level WARN
    Write-Host "  [WARN]  $Text" -ForegroundColor Yellow
}

function Write-WrappedBox {
    param([string]$Text, [ConsoleColor]$BorderColor = "DarkCyan", [ConsoleColor]$TextColor = "Cyan", [int]$Width = 54, [int]$MaxLines = 8)
    Write-Log "Response: $Text" -Level INFO
    Write-Host ""
    $hBar = [string]::new($script:BOX_H, $Width + 2)
    Write-Host "  $($script:BOX_TL)$hBar$($script:BOX_TR)" -ForegroundColor $BorderColor
    $Words = $Text -split '\s+'
    $Line = ""
    $Lines = @()
    foreach ($word in $Words) {
        $testLine = ("$Line $word").Trim()
        if ($testLine.Length -gt $Width) {
            if ($Line) { $Lines += $Line.Trim() }
            $Line = $word
        } else {
            $Line = $testLine
        }
    }
    if ($Line) { $Lines += $Line.Trim() }
    foreach ($l in $Lines | Select-Object -First $MaxLines) {
        $display = if ($l.Length -gt $Width) { $l.Substring(0, $Width) } else { $l.PadRight($Width) }
        Write-Host "  $($script:BOX_V) " -ForegroundColor $BorderColor -NoNewline
        Write-Host $display -ForegroundColor $TextColor -NoNewline
        Write-Host " $($script:BOX_V)" -ForegroundColor $BorderColor
    }
    Write-Host "  $($script:BOX_BL)$hBar$($script:BOX_BR)" -ForegroundColor $BorderColor
}

function Invoke-Utf8RestMethod {
    param([string]$Uri, [hashtable]$Headers, [string]$Body, [int]$TimeoutSec = 30)
    Write-Log "HTTP POST $Uri (timeout: ${TimeoutSec}s)" -Level DEBUG
    $webResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $Headers -Body ([System.Text.Encoding]::UTF8.GetBytes($Body)) -TimeoutSec $TimeoutSec -UseBasicParsing
    $utf8Content = [System.Text.Encoding]::UTF8.GetString($webResponse.RawContentStream.ToArray())
    Write-Log "HTTP response: $($webResponse.StatusCode)" -Level DEBUG
    return ($utf8Content | ConvertFrom-Json)
}

function Exit-WithError {
    param([string]$Message)
    Write-StatusFail $Message
    Write-Log "EXIT: $Message" -Level ERROR
    Write-Host "`nPress Enter to close..." -ForegroundColor Red
    Read-Host
    exit 1
}

# ============================================================
#  PIPELINE STAGES
# ============================================================

function Invoke-Stage1-ReadClipboard {
    Write-Stage ">>>" "STAGE 1 - Reading Clipboard" Cyan

    $text = Get-Clipboard -ErrorAction SilentlyContinue
    if (-not $text) {
        Exit-WithError "Clipboard is empty! Copy some text first."
    }

    # Join array lines into single string
    $text = ($text -join "`n").Trim()
    $script:ClipboardText = $text
    $WordCount = ($text -split '\s+').Count
    $CharCount = $text.Length

    Write-Log "Clipboard: $WordCount words, $CharCount chars" -Level INFO

    # Show clipboard content in a box
    $MaxDisplay = if ($text.Length -gt 120) { $text.Substring(0, 120) + "..." } else { $text }
    $hBar = [string]::new($script:BOX_H, 56)
    Write-Host ""
    Write-Host "  $($script:BOX_TL)$hBar$($script:BOX_TR)" -ForegroundColor DarkYellow
    foreach ($line in ($MaxDisplay -split "`n" | Select-Object -First 4)) {
        $padded = $line.PadRight(54).Substring(0, 54)
        Write-Host "  $($script:BOX_V) " -ForegroundColor DarkYellow -NoNewline
        Write-Host $padded -ForegroundColor Yellow -NoNewline
        Write-Host " $($script:BOX_V)" -ForegroundColor DarkYellow
    }
    Write-Host "  $($script:BOX_BL)$hBar$($script:BOX_BR)" -ForegroundColor DarkYellow
    Write-Detail "Words:" "$WordCount" Yellow
    Write-Detail "Chars:" "$CharCount" Yellow
    Write-StatusOk "Clipboard captured"
}

function Invoke-Stage2-ValidateKeys {
    Write-Stage "KEY" "STAGE 2 - Checking API Keys" Magenta

    if (-not $script:XAI_API_KEY) {
        Exit-WithError "XAI_API_KEY not set in .env"
    }
    Write-Detail "xAI Key:" "$($script:XAI_API_KEY.Substring(0,8))...$($script:XAI_API_KEY.Substring($script:XAI_API_KEY.Length-6))" Magenta

    if (-not $script:ELEVENLABS_API_KEY -and -not $script:FAL_KEY) {
        Exit-WithError "No TTS key set in .env (need ELEVENLABS_API_KEY or FAL_KEY)"
    }
    if ($script:ELEVENLABS_API_KEY) {
        Write-Detail "ElevenLabs:" "$($script:ELEVENLABS_API_KEY.Substring(0,8))...$($script:ELEVENLABS_API_KEY.Substring($script:ELEVENLABS_API_KEY.Length-6))" Magenta
    }
    if ($script:FAL_KEY) {
        Write-Detail "fal.ai:" "$($script:FAL_KEY.Substring(0,8))..." Magenta
    }
    Write-Detail "Voice ID:" $script:VOICE_ID Magenta
    Write-Detail "Model:" $script:MODEL_ID Magenta
    Write-StatusOk "API keys validated"
}

function Invoke-Stage3-AskLLM {
    param(
        [string]$StageTitle,
        [string]$StageEmoji = "LLM",
        [string]$SystemPrompt,
        [string]$UserPrompt,
        [double]$Temperature = 0.7,
        [int]$MaxTokens = 300,
        [string]$Model = "grok-3-mini-fast",
        [ConsoleColor]$BoxBorderColor = "DarkCyan",
        [ConsoleColor]$BoxTextColor = "Cyan"
    )

    Write-Stage $StageEmoji "STAGE 3 - $StageTitle" Blue

    $script:LLMAnswer = $null
    $script:LLMProvider = $null
    $GrokStart = [System.Diagnostics.Stopwatch]::StartNew()

    $Body = @{
        model       = $Model
        messages    = @(
            @{ role = "system"; content = $SystemPrompt }
            @{ role = "user";   content = $UserPrompt }
        )
        temperature = $Temperature
        max_tokens  = $MaxTokens
    } | ConvertTo-Json -Depth 5

    $Headers = @{
        "Authorization" = "Bearer $($script:XAI_API_KEY)"
        "Content-Type"  = "application/json"
    }

    # -- 3a: Try xAI Grok --
    try {
        Write-Host "     ... Sending to Grok..." -ForegroundColor DarkCyan
        Write-Log "LLM request to xAI Grok ($Model)" -Level INFO
        $Response = Invoke-Utf8RestMethod -Uri "https://api.x.ai/v1/chat/completions" `
                                          -Headers $Headers `
                                          -Body $Body `
                                          -TimeoutSec 30

        $script:LLMAnswer = $Response.choices[0].message.content.Trim()
        $script:LLMProvider = "Grok"
        $GrokStart.Stop()

        Write-WrappedBox $script:LLMAnswer -BorderColor $BoxBorderColor -TextColor $BoxTextColor
        Write-Detail "Grok time:" "$($GrokStart.Elapsed.TotalSeconds.ToString('F1'))s" Blue
        Write-Detail "Tokens:" "$($Response.usage.total_tokens)" Blue
        Write-StatusOk "Grok answered"
    }
    catch {
        $GrokStart.Stop()
        Write-StatusFail "xAI API call failed: $($_.Exception.Message)"
        Write-Log "xAI failed: $($_.Exception.Message)" -Level ERROR
        Write-Host "     Trying OpenRouter fallback..." -ForegroundColor DarkYellow
    }

    # -- 3b: Fallback to OpenRouter --
    if (-not $script:LLMAnswer -and $script:OPENROUTER_API_KEY) {
        Write-Stage ">>>" "STAGE 3b - Fallback: OpenRouter" DarkYellow
        $GrokStart = [System.Diagnostics.Stopwatch]::StartNew()

        $ORBody = @{
            model       = "google/gemini-2.0-flash-001"
            messages    = @(
                @{ role = "system"; content = $SystemPrompt }
                @{ role = "user";   content = $UserPrompt }
            )
            temperature = $Temperature
            max_tokens  = $MaxTokens
        } | ConvertTo-Json -Depth 5

        $ORHeaders = @{
            "Authorization" = "Bearer $($script:OPENROUTER_API_KEY)"
            "Content-Type"  = "application/json"
        }

        try {
            Write-Host "     ... Sending to OpenRouter..." -ForegroundColor DarkYellow
            Write-Log "LLM fallback to OpenRouter" -Level WARN
            $Response = Invoke-Utf8RestMethod -Uri "https://openrouter.ai/api/v1/chat/completions" `
                                              -Headers $ORHeaders `
                                              -Body $ORBody `
                                              -TimeoutSec 30

            $script:LLMAnswer = $Response.choices[0].message.content.Trim()
            $script:LLMProvider = "OpenRouter"
            $GrokStart.Stop()

            Write-WrappedBox $script:LLMAnswer -BorderColor $BoxBorderColor -TextColor $BoxTextColor
            Write-Detail "OpenRouter time:" "$($GrokStart.Elapsed.TotalSeconds.ToString('F1'))s" DarkYellow
            Write-Detail "Tokens:" "$($Response.usage.total_tokens)" DarkYellow
            Write-StatusOk "OpenRouter answered"
        }
        catch {
            $GrokStart.Stop()
            Write-Log "OpenRouter also failed: $($_.Exception.Message)" -Level ERROR
            Exit-WithError "OpenRouter also failed: $($_.Exception.Message)"
        }
    }
    elseif (-not $script:LLMAnswer) {
        Exit-WithError "All LLM providers failed. No OPENROUTER_API_KEY set."
    }

    # Save text to SecondBrain (always attempt)
    $Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $prefix = $PipelineConfig.FilePrefix
    if (Test-Path $script:SecondBrainDir) {
        try {
            $TextPath = Join-Path $script:SecondBrainDir "${prefix}_$Timestamp.md"
            $mdTitle = $PipelineConfig.Title
            $TextContent = "# $mdTitle`n`n## Source`n`n$($script:ClipboardText)`n`n## Analysis ($($script:LLMProvider))`n`n$($script:LLMAnswer)`n"
            [System.IO.File]::WriteAllText($TextPath, $TextContent, [System.Text.UTF8Encoding]::new($true))
            Write-Detail "Obsidian:" $TextPath Blue
            Write-Log "SecondBrain text saved: $TextPath" -Level INFO
            $script:SavedFiles += $TextPath
        } catch {
            Write-StatusWarn "SecondBrain text save failed: $($_.Exception.Message)"
            Write-Log "SecondBrain text save failed: $($_.Exception.Message)" -Level ERROR
        }
    } else {
        Write-StatusWarn "SecondBrain directory not found: $($script:SecondBrainDir) - text not saved to Obsidian"
        Write-Log "SecondBrain directory missing, text not saved" -Level WARN
    }
}

function Invoke-Stage4-TTS {
    Write-Stage "TTS" "STAGE 4 - Converting to Speech" Green

    $script:TTSSuccess = $false
    $Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $prefix = $PipelineConfig.FilePrefix
    $script:AudioSavePath = Join-Path $script:DownloadsDir "tts_${prefix}_$Timestamp.mp3"
    $script:AudioTimestamp = $Timestamp

    # -- 4a: Try ElevenLabs --
    if ($script:ELEVENLABS_API_KEY) {
        $TTSStart = [System.Diagnostics.Stopwatch]::StartNew()

        $TTSBody = @{
            text     = $script:LLMAnswer
            model_id = $script:MODEL_ID
        } | ConvertTo-Json

        $TTSHeaders = @{
            "xi-api-key"   = $script:ELEVENLABS_API_KEY
            "Content-Type" = "application/json"
            "Accept"       = "audio/mpeg"
        }

        try {
            Write-Host "     ... Trying ElevenLabs..." -ForegroundColor DarkGreen
            Write-Log "TTS request to ElevenLabs (voice: $($script:VOICE_ID))" -Level INFO

            $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($TTSBody)
            Invoke-WebRequest -Uri "https://api.elevenlabs.io/v1/text-to-speech/$($script:VOICE_ID)" `
                              -Method Post `
                              -Headers $TTSHeaders `
                              -Body $bodyBytes `
                              -OutFile $script:AudioSavePath `
                              -TimeoutSec 30 `
                              -UseBasicParsing

            $FileSize = (Get-Item $script:AudioSavePath).Length
            $TTSStart.Stop()

            Write-Detail "Engine:" "ElevenLabs" Green
            Write-Detail "Saved:" $script:AudioSavePath Green
            Write-Detail "Size:" "$([math]::Round($FileSize / 1024, 1)) KB" Green
            Write-Detail "TTS time:" "$($TTSStart.Elapsed.TotalSeconds.ToString('F1'))s" Green
            Write-Log "ElevenLabs TTS success: $([math]::Round($FileSize / 1024, 1)) KB in $($TTSStart.Elapsed.TotalSeconds.ToString('F1'))s" -Level INFO
            $script:TTSSuccess = $true
        }
        catch {
            $TTSStart.Stop()
            Write-StatusFail "ElevenLabs TTS failed: $($_.Exception.Message)"
            Write-Log "ElevenLabs TTS failed: $($_.Exception.Message)" -Level ERROR
            if (Test-Path $script:AudioSavePath) { Remove-Item $script:AudioSavePath -Force -ErrorAction SilentlyContinue }
        }
    }

    # -- 4b: Fallback to fal.ai (dia-tts) --
    if (-not $script:TTSSuccess -and $script:FAL_KEY) {
        Write-Host "     >>> Falling back to fal.ai..." -ForegroundColor DarkYellow
        Write-Log "TTS fallback to fal.ai" -Level WARN
        $TTSStart = [System.Diagnostics.Stopwatch]::StartNew()

        $FalBody = @{
            text = $script:LLMAnswer
        } | ConvertTo-Json

        $FalHeaders = @{
            "Authorization" = "Key $($script:FAL_KEY)"
            "Content-Type"  = "application/json"
        }

        try {
            Write-Host "     ... Generating speech via fal.ai..." -ForegroundColor DarkGreen
            $FalResponse = Invoke-Utf8RestMethod -Uri "https://fal.run/fal-ai/dia-tts" `
                                                 -Headers $FalHeaders `
                                                 -Body $FalBody `
                                                 -TimeoutSec 60

            $AudioUrl = $FalResponse.audio.url
            if (-not $AudioUrl) {
                throw "No audio URL in fal.ai response"
            }

            Invoke-WebRequest -Uri $AudioUrl -OutFile $script:AudioSavePath -TimeoutSec 30 -UseBasicParsing

            $FileSize = (Get-Item $script:AudioSavePath).Length
            $TTSStart.Stop()

            Write-Detail "Engine:" "fal.ai (dia-tts)" Green
            Write-Detail "Saved:" $script:AudioSavePath Green
            Write-Detail "Size:" "$([math]::Round($FileSize / 1024, 1)) KB" Green
            Write-Detail "TTS time:" "$($TTSStart.Elapsed.TotalSeconds.ToString('F1'))s" Green
            Write-Log "fal.ai TTS success: $([math]::Round($FileSize / 1024, 1)) KB in $($TTSStart.Elapsed.TotalSeconds.ToString('F1'))s" -Level INFO
            $script:TTSSuccess = $true
        }
        catch {
            $TTSStart.Stop()
            Write-StatusFail "fal.ai TTS failed: $($_.Exception.Message)"
            Write-Log "fal.ai TTS failed: $($_.Exception.Message)" -Level ERROR
        }
    }

    if (-not $script:TTSSuccess) {
        Exit-WithError "All TTS engines failed. No audio generated."
    }

    # Copy audio to SecondBrain (always attempt)
    if (Test-Path $script:SecondBrainDir) {
        try {
            $SBSavePath = Join-Path $script:SecondBrainDir "${prefix}_$($script:AudioTimestamp).mp3"
            Copy-Item -Path $script:AudioSavePath -Destination $SBSavePath -Force
            Write-Detail "Obsidian:" $SBSavePath Green
            Write-Log "SecondBrain audio saved: $SBSavePath" -Level INFO
            $script:SavedFiles += $SBSavePath
        } catch {
            Write-StatusWarn "SecondBrain audio save failed: $($_.Exception.Message)"
            Write-Log "SecondBrain audio save failed: $($_.Exception.Message)" -Level ERROR
        }
    } else {
        Write-StatusWarn "SecondBrain directory not found: $($script:SecondBrainDir) - audio not saved to Obsidian"
        Write-Log "SecondBrain directory missing, audio not saved" -Level WARN
    }

    Write-StatusOk "Audio generated"
}

function Invoke-Stage5-PlayAudio {
    Write-Stage ">>>" "STAGE 5 - Playing Audio" Yellow

    try {
        Write-Host "     Playing..." -ForegroundColor DarkYellow
        Write-Log "Playing audio: $($script:AudioSavePath)" -Level INFO

        Add-Type -AssemblyName presentationCore
        $Player = New-Object System.Windows.Media.MediaPlayer
        $Player.Open([Uri]$script:AudioSavePath)
        Start-Sleep -Milliseconds 500
        $Player.Play()

        # Wait for playback to finish
        while (-not $Player.NaturalDuration.HasTimeSpan) {
            Start-Sleep -Milliseconds 200
        }
        $Duration = $Player.NaturalDuration.TimeSpan
        Write-Detail "Duration:" "$($Duration.TotalSeconds.ToString('F1'))s" Yellow
        Write-Log "Playback duration: $($Duration.TotalSeconds.ToString('F1'))s" -Level INFO

        Start-Sleep -Milliseconds ($Duration.TotalMilliseconds + 500)
        $Player.Close()

        Write-StatusOk "Playback complete"
    }
    catch {
        Write-StatusFail "Playback failed: $($_.Exception.Message)"
        Write-Log "Playback failed: $($_.Exception.Message)" -Level ERROR
        # Don't exit - audio is saved even if playback fails
    }
}

function Invoke-Stage6-Summary {
    param([System.Diagnostics.Stopwatch]$Stopwatch)

    $Stopwatch.Stop()
    $TotalElapsed = $Stopwatch.Elapsed

    Write-Host ""
    Write-Host ("=" * 60) -ForegroundColor DarkGray
    Write-Host "  DONE  ALL STAGES COMPLETE" -ForegroundColor White
    Write-Host ("=" * 60) -ForegroundColor DarkGray
    Write-Detail "Total time:" "$($TotalElapsed.ToString('mm\:ss\.ff'))" White

    # Show saved files summary
    if ($script:SavedFiles.Count -gt 0) {
        Write-Host ""
        Write-Host "  Obsidian / SecondBrain saves:" -ForegroundColor Green
        foreach ($f in $script:SavedFiles) {
            $fileName = Split-Path $f -Leaf
            Write-Host "       [OK] $fileName" -ForegroundColor Green
        }
    }

    Write-Detail "Log:" $script:LogFile White

    Write-Log "Pipeline completed in $($TotalElapsed.TotalSeconds.ToString('F1'))s" -Level INFO
    Write-Log "Saved files: $($script:SavedFiles -join ', ')" -Level INFO

    Write-Host ""
    Write-Host "  [TOTAL: $($TotalElapsed.TotalSeconds.ToString('F1'))s]" -ForegroundColor Red
    Write-Host ""
    Write-Host "Press Enter to close..." -ForegroundColor DarkGray
    Read-Host
}

# ============================================================
#  MAIN PIPELINE ORCHESTRATOR
# ============================================================

function Invoke-Pipeline {
    <#
    .SYNOPSIS
        Run the full TTS pipeline using $PipelineConfig.
    .DESCRIPTION
        Expects $PipelineConfig hashtable with:
          Name         - Script identifier (e.g. "sanity-check")
          Title        - Display title (e.g. "Sanity Check")
          FilePrefix   - Prefix for saved files (e.g. "sanity")
          StageEmoji   - Label for LLM stage header
          StageTitle   - Title for LLM stage (e.g. "Asking xAI Grok: Sanity Check")
          SystemPrompt - System prompt for LLM
          UserPromptTemplate - User prompt template (use {CLIPBOARD} as placeholder)
          Temperature  - LLM temperature (default 0.7)
          MaxTokens    - LLM max tokens (default 300)
          BoxBorderColor - Console color for response box border (default DarkCyan)
          BoxTextColor   - Console color for response box text (default Cyan)
    #>

    $script:SavedFiles = @()
    $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    # Write log header
    Write-LogHeader

    # Stage 1: Read clipboard
    Invoke-Stage1-ReadClipboard

    # Stage 2: Validate API keys
    Invoke-Stage2-ValidateKeys

    # Stage 3: Ask LLM
    $userPrompt = $PipelineConfig.UserPromptTemplate -replace '\{CLIPBOARD\}', $script:ClipboardText
    $boxBorder = if ($PipelineConfig.BoxBorderColor) { $PipelineConfig.BoxBorderColor } else { "DarkCyan" }
    $boxText = if ($PipelineConfig.BoxTextColor) { $PipelineConfig.BoxTextColor } else { "Cyan" }

    Invoke-Stage3-AskLLM `
        -StageTitle $PipelineConfig.StageTitle `
        -StageEmoji $PipelineConfig.StageEmoji `
        -SystemPrompt $PipelineConfig.SystemPrompt `
        -UserPrompt $userPrompt `
        -Temperature ([double]$(if ($PipelineConfig.Temperature) { $PipelineConfig.Temperature } else { 0.7 })) `
        -MaxTokens ([int]$(if ($PipelineConfig.MaxTokens) { $PipelineConfig.MaxTokens } else { 300 })) `
        -BoxBorderColor $boxBorder `
        -BoxTextColor $boxText

    # Stage 4: TTS
    Invoke-Stage4-TTS

    # Stage 5: Play audio
    Invoke-Stage5-PlayAudio

    # Stage 6: Summary
    Invoke-Stage6-Summary -Stopwatch $Stopwatch
}
