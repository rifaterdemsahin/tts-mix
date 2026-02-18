# Pros & Cons — xAI (Grok) + TTS Pipeline
#
# Pipeline:
#   1. Read clipboard text
#   2. Send to xAI Grok API: "Give the key pros and cons"
#   3. Convert Grok's analysis to speech via ElevenLabs/fal.ai
#   4. Play audio
#
# Usage from Stream Deck:
#   Action: System > Open
#   App: powershell.exe
#   Arguments: -ExecutionPolicy Bypass -File "C:\projects\tts-mix\5_Symbols\pros-cons.ps1"

$UserPrompt = @"
The user copied this text:

---
{CLIPBOARD}
---

Give the 2 strongest pros and 2 strongest cons of what is described here. State each point as a brief sentence. Be balanced and specific. Respond in the same language as the text.
"@

$PipelineConfig = @{
    Name         = "pros-cons"
    Title        = "Pros & Cons"
    FilePrefix   = "proscons"
    StageEmoji   = "[+-]"
    StageTitle   = "Asking xAI Grok: Pros and Cons"
    SystemPrompt = "You are a balanced analyst. Present exactly 2 pros and 2 cons for any topic. Each point is one concise sentence. Be specific and fair. Keep phrasing natural for text-to-speech reading."
    UserPromptTemplate = $UserPrompt
    Temperature    = 0.5
    MaxTokens      = 300
    BoxBorderColor = "DarkGray"
    BoxTextColor   = "Gray"
}

. "$PSScriptRoot\_base.ps1"
Invoke-Pipeline
