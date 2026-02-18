# Devil's Advocate — xAI (Grok) + TTS Pipeline
#
# Pipeline:
#   1. Read clipboard text
#   2. Send to xAI Grok API: "Give the strongest counterargument"
#   3. Convert Grok's challenge to speech via ElevenLabs/fal.ai
#   4. Play audio
#
# Usage from Stream Deck:
#   Action: System > Open
#   App: powershell.exe
#   Arguments: -ExecutionPolicy Bypass -File "C:\projects\tts-mix\5_Symbols\devil-advocate.ps1"

$UserPrompt = @"
The user copied this text:

---
{CLIPBOARD}
---

Play devil's advocate. Give the strongest possible counterargument or opposing perspective to what is stated here. Be direct, sharp, and persuasive. 2-3 sentences. Respond in the same language as the text.
"@

$PipelineConfig = @{
    Name         = "devil-advocate"
    Title        = "Devil's Advocate"
    FilePrefix   = "devil"
    StageEmoji   = "[<>]"
    StageTitle   = "Asking xAI Grok: Devil's Advocate"
    SystemPrompt = "You are a sharp devil's advocate. Present the strongest possible counterargument to any position. Be persuasive, direct, and challenge assumptions without being rude. Keep it to 2-3 sentences for text-to-speech."
    UserPromptTemplate = $UserPrompt
    Temperature    = 0.8
    MaxTokens      = 300
    BoxBorderColor = "Red"
    BoxTextColor   = "Yellow"
}

. "$PSScriptRoot\_base.ps1"
Invoke-Pipeline
