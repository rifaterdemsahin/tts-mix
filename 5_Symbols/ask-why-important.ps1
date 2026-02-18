# Ask Why Important — xAI (Grok) + TTS Pipeline
#
# Pipeline:
#   1. Read clipboard text
#   2. Send to xAI Grok API: "Why is this important?"
#   3. Convert Grok's answer to speech via ElevenLabs/fal.ai
#   4. Play audio
#
# Usage from Stream Deck:
#   Action: System > Open
#   App: powershell.exe
#   Arguments: -ExecutionPolicy Bypass -File "C:\projects\tts-mix\5_Symbols\ask-why-important.ps1"

$PipelineConfig = @{
    Name         = "ask-why-important"
    Title        = "Why Is This Important?"
    FilePrefix   = "why"
    StageEmoji   = "🧠"
    StageTitle   = "Asking xAI Grok: Why is this important?"
    SystemPrompt = "You are a concise, insightful analyst. Keep responses brief (2-3 sentences max) and suitable for text-to-speech reading."
    UserPromptTemplate = @"
The user copied this text:

---
{CLIPBOARD}
---

Explain in 2-3 concise sentences why this is important. Be insightful and direct. Respond in the same language as the text.
"@
    Temperature    = 0.7
    MaxTokens      = 300
    BoxBorderColor = "DarkCyan"
    BoxTextColor   = "Cyan"
}

. "$PSScriptRoot\_base.ps1"
Invoke-Pipeline
