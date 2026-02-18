# Motivate — xAI (Grok) + TTS Pipeline
#
# Pipeline:
#   1. Read clipboard text
#   2. Send to xAI Grok API: "Deliver a motivational take on this"
#   3. Convert Grok's speech to audio via ElevenLabs/fal.ai
#   4. Play audio
#
# Usage from Stream Deck:
#   Action: System > Open
#   App: powershell.exe
#   Arguments: -ExecutionPolicy Bypass -File "C:\projects\tts-mix\5_Symbols\motivate.ps1"

$UserPrompt = @"
The user copied this text:

---
{CLIPBOARD}
---

Give a motivational, energizing take on this. Make the listener feel capable and fired up. Keep it personal, powerful, and genuine — not generic. 3-4 sentences. Respond in the same language as the text.
"@

$PipelineConfig = @{
    Name         = "motivate"
    Title        = "Motivate"
    FilePrefix   = "motivate"
    StageEmoji   = "[^]"
    StageTitle   = "Asking xAI Grok: Motivational Take"
    SystemPrompt = "You are an energizing motivational coach. Take any topic and deliver an inspiring, personal, and powerful message that makes the listener feel capable. 3-4 sentences max. Avoid cliches. Keep it great for text-to-speech."
    UserPromptTemplate = $UserPrompt
    Temperature    = 0.9
    MaxTokens      = 350
    BoxBorderColor = "Yellow"
    BoxTextColor   = "White"
}

. "$PSScriptRoot\_base.ps1"
Invoke-Pipeline
