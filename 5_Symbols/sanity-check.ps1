# Sanity Check — xAI (Grok) + TTS Pipeline
#
# Pipeline:
#   1. Read clipboard text
#   2. Send to xAI Grok API: "Does this make sense / is this sane?"
#   3. Convert Grok's answer to speech via ElevenLabs/fal.ai
#   4. Play audio
#
# Usage from Stream Deck:
#   Action: System > Open
#   App: powershell.exe
#   Arguments: -ExecutionPolicy Bypass -File "C:\projects\tts-mix\5_Symbols\sanity-check.ps1"

$PipelineConfig = @{
    Name         = "sanity-check"
    Title        = "Sanity Check"
    FilePrefix   = "sanity"
    StageEmoji   = "🧠"
    StageTitle   = "Asking xAI Grok: Sanity Check"
    SystemPrompt = "You are a sharp, critical thinker performing sanity checks. Keep responses brief (2-3 sentences max) and suitable for text-to-speech reading."
    UserPromptTemplate = @"
The user copied this text:

---
{CLIPBOARD}
---

Perform a sanity check on this. Does it make sense? Is the logic sound? Are there any obvious errors, contradictions, or red flags? Respond in 2-3 concise sentences. Be direct and honest. Respond in the same language as the text.
"@
    Temperature    = 0.5
    MaxTokens      = 300
    BoxBorderColor = "DarkCyan"
    BoxTextColor   = "Cyan"
}

. "$PSScriptRoot\_base.ps1"
Invoke-Pipeline
