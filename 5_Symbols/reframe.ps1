# Reframe — xAI (Grok) + TTS Pipeline
#
# Pipeline:
#   1. Read clipboard text
#   2. Send to xAI Grok API: "Reframe this as a positive opportunity"
#   3. Convert Grok's reframe to speech via ElevenLabs/fal.ai
#   4. Play audio
#
# Usage from Stream Deck:
#   Action: System > Open
#   App: powershell.exe
#   Arguments: -ExecutionPolicy Bypass -File "C:\projects\tts-mix\5_Symbols\reframe.ps1"

$UserPrompt = @"
The user copied this text:

---
{CLIPBOARD}
---

Reframe this from a positive, growth-oriented perspective. Find the silver lining, the hidden opportunity, or the lesson. Keep it grounded and genuine, not cheesy. 2-3 sentences. Respond in the same language as the text.
"@

$PipelineConfig = @{
    Name         = "reframe"
    Title        = "Reframe"
    FilePrefix   = "reframe"
    StageEmoji   = "[+]"
    StageTitle   = "Asking xAI Grok: Reframe as Opportunity"
    SystemPrompt = "You reframe challenges as opportunities. Take any situation and reveal the genuine silver lining or growth angle. Be authentic and grounded — never hollow or preachy. 2-3 sentences, suitable for text-to-speech."
    UserPromptTemplate = $UserPrompt
    Temperature    = 0.8
    MaxTokens      = 250
    BoxBorderColor = "Green"
    BoxTextColor   = "White"
}

. "$PSScriptRoot\_base.ps1"
Invoke-Pipeline
