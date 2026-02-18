# Haiku — xAI (Grok) + TTS Pipeline
#
# Pipeline:
#   1. Read clipboard text
#   2. Send to xAI Grok API: "Transform this into a haiku"
#   3. Convert Grok's haiku to speech via ElevenLabs/fal.ai
#   4. Play audio
#
# Usage from Stream Deck:
#   Action: System > Open
#   App: powershell.exe
#   Arguments: -ExecutionPolicy Bypass -File "C:\projects\tts-mix\5_Symbols\haiku.ps1"

$UserPrompt = @"
The user copied this text:

---
{CLIPBOARD}
---

Write a haiku (5-7-5 syllables) that captures the essence of this text. Read the three lines naturally with brief pauses. Then add one sentence explaining what the haiku means. Respond in the same language as the text.
"@

$PipelineConfig = @{
    Name         = "haiku"
    Title        = "Haiku"
    FilePrefix   = "haiku"
    StageEmoji   = "[~]"
    StageTitle   = "Asking xAI Grok: Write a Haiku"
    SystemPrompt = "You compose haiku poetry (5-7-5 syllables) that distills the essence of any topic. After the haiku, add exactly one sentence explaining its meaning. Keep phrasing natural and beautiful when read aloud."
    UserPromptTemplate = $UserPrompt
    Temperature    = 0.9
    MaxTokens      = 150
    BoxBorderColor = "Gray"
    BoxTextColor   = "White"
}

. "$PSScriptRoot\_base.ps1"
Invoke-Pipeline
