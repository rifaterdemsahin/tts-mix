# ELI5 (Explain Like I'm 5) — xAI (Grok) + TTS Pipeline
#
# Pipeline:
#   1. Read clipboard text
#   2. Send to xAI Grok API: "Explain this like I'm 5 years old"
#   3. Convert Grok's explanation to speech via ElevenLabs/fal.ai
#   4. Play audio
#
# Usage from Stream Deck:
#   Action: System > Open
#   App: powershell.exe
#   Arguments: -ExecutionPolicy Bypass -File "C:\projects\tts-mix\5_Symbols\eli5.ps1"

$UserPrompt = @"
The user copied this text:

---
{CLIPBOARD}
---

Explain this like I'm 5 years old. Use the simplest words possible, a relatable analogy, and no jargon. Keep it to 2-3 short sentences. Respond in the same language as the text.
"@

$PipelineConfig = @{
    Name         = "eli5"
    Title        = "ELI5"
    FilePrefix   = "eli5"
    StageEmoji   = "[kid]"
    StageTitle   = "Asking xAI Grok: Explain Like I'm 5"
    SystemPrompt = "You explain complex topics as if speaking to a 5-year-old. Use simple words, concrete analogies, and very short sentences. Never use jargon. Keep responses to 2-3 sentences max, suitable for text-to-speech."
    UserPromptTemplate = $UserPrompt
    Temperature    = 0.7
    MaxTokens      = 250
    BoxBorderColor = "DarkGreen"
    BoxTextColor   = "Green"
}

. "$PSScriptRoot\_base.ps1"
Invoke-Pipeline
