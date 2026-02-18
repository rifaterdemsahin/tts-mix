# Tweet This — xAI (Grok) + TTS Pipeline
#
# Pipeline:
#   1. Read clipboard text
#   2. Send to xAI Grok API: "Compress to tweet-length"
#   3. Convert Grok's tweet to speech via ElevenLabs/fal.ai
#   4. Play audio
#
# Usage from Stream Deck:
#   Action: System > Open
#   App: powershell.exe
#   Arguments: -ExecutionPolicy Bypass -File "C:\projects\tts-mix\5_Symbols\tweet-this.ps1"

$UserPrompt = @"
The user copied this text:

---
{CLIPBOARD}
---

Rewrite this as a punchy, memorable social media post under 200 characters. No hashtags. Make it sharp and shareable. Respond in the same language as the text.
"@

$PipelineConfig = @{
    Name         = "tweet-this"
    Title        = "Tweet This"
    FilePrefix   = "tweet"
    StageEmoji   = "[T]"
    StageTitle   = "Asking xAI Grok: Tweet This"
    SystemPrompt = "You write punchy, shareable social media posts. Compress any content to under 200 characters. No hashtags. Make it memorable and quotable. Keep phrasing natural for text-to-speech."
    UserPromptTemplate = $UserPrompt
    Temperature    = 0.9
    MaxTokens      = 100
    BoxBorderColor = "Blue"
    BoxTextColor   = "Cyan"
}

. "$PSScriptRoot\_base.ps1"
Invoke-Pipeline
