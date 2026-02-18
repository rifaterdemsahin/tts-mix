# TLDR — xAI (Grok) + TTS Pipeline
#
# Pipeline:
#   1. Read clipboard text
#   2. Send to xAI Grok API: "Summarize in one sentence"
#   3. Convert Grok's summary to speech via ElevenLabs/fal.ai
#   4. Play audio
#
# Usage from Stream Deck:
#   Action: System > Open
#   App: powershell.exe
#   Arguments: -ExecutionPolicy Bypass -File "C:\projects\tts-mix\5_Symbols\tldr.ps1"

$UserPrompt = @"
The user copied this text:

---
{CLIPBOARD}
---

Summarize this in exactly one clear, complete sentence. Capture the single most important idea. Respond in the same language as the text.
"@

$PipelineConfig = @{
    Name         = "tldr"
    Title        = "TLDR"
    FilePrefix   = "tldr"
    StageEmoji   = "[>>]"
    StageTitle   = "Asking xAI Grok: TLDR Summary"
    SystemPrompt = "You are a master summarizer. Distill any content to a single, precise sentence that captures the core idea. Never use more than one sentence. Keep it suitable for text-to-speech."
    UserPromptTemplate = $UserPrompt
    Temperature    = 0.3
    MaxTokens      = 100
    BoxBorderColor = "DarkBlue"
    BoxTextColor   = "Blue"
}

. "$PSScriptRoot\_base.ps1"
Invoke-Pipeline
