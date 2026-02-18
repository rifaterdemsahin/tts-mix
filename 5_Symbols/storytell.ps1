# Storytell — xAI (Grok) + TTS Pipeline
#
# Pipeline:
#   1. Read clipboard text
#   2. Send to xAI Grok API: "Turn this into a short story"
#   3. Convert Grok's story to speech via ElevenLabs/fal.ai
#   4. Play audio
#
# Usage from Stream Deck:
#   Action: System > Open
#   App: powershell.exe
#   Arguments: -ExecutionPolicy Bypass -File "C:\projects\tts-mix\5_Symbols\storytell.ps1"

$PipelineConfig = @{
    Name         = "storytell"
    Title        = "Story"
    FilePrefix   = "story"
    StageEmoji   = "📖"
    StageTitle   = "Asking xAI Grok: Tell a story about this"
    SystemPrompt = "You are a gifted storyteller. Transform any topic into a compelling short narrative (3-5 sentences) that sounds great when read aloud."
    UserPromptTemplate = @"
The user copied this text:

---
{CLIPBOARD}
---

Turn this into a short, vivid story in 3-5 sentences. Use narrative style with a beginning, middle, and end. Make it engaging and easy to listen to. Respond in the same language as the text.
"@
    Temperature    = 0.9
    MaxTokens      = 400
    BoxBorderColor = "DarkMagenta"
    BoxTextColor   = "Magenta"
}

. "$PSScriptRoot\_base.ps1"
Invoke-Pipeline
