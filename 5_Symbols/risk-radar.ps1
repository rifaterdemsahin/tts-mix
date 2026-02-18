# Risk Radar — xAI (Grok) + TTS Pipeline
#
# Pipeline:
#   1. Read clipboard text
#   2. Send to xAI Grok API: "Identify risks and red flags"
#   3. Convert Grok's analysis to speech via ElevenLabs/fal.ai
#   4. Play audio
#
# Usage from Stream Deck:
#   Action: System > Open
#   App: powershell.exe
#   Arguments: -ExecutionPolicy Bypass -File "C:\projects\tts-mix\5_Symbols\risk-radar.ps1"

$UserPrompt = @"
The user copied this text:

---
{CLIPBOARD}
---

Scan this for risks, pitfalls, blind spots, or red flags. Name up to 3 specific concerns and why they matter. Be concise and direct. Respond in the same language as the text.
"@

$PipelineConfig = @{
    Name         = "risk-radar"
    Title        = "Risk Radar"
    FilePrefix   = "risk"
    StageEmoji   = "[!]"
    StageTitle   = "Asking xAI Grok: Risk Radar"
    SystemPrompt = "You are a risk analyst. Identify the most important risks, pitfalls, and blind spots in any text. Be specific and concise — up to 3 concerns, each in 1-2 sentences. Keep phrasing natural for text-to-speech."
    UserPromptTemplate = $UserPrompt
    Temperature    = 0.5
    MaxTokens      = 300
    BoxBorderColor = "DarkYellow"
    BoxTextColor   = "Yellow"
}

. "$PSScriptRoot\_base.ps1"
Invoke-Pipeline
