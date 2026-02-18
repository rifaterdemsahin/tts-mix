# Action Items — xAI (Grok) + TTS Pipeline
#
# Pipeline:
#   1. Read clipboard text
#   2. Send to xAI Grok API: "Extract action items"
#   3. Convert Grok's list to speech via ElevenLabs/fal.ai
#   4. Play audio
#
# Usage from Stream Deck:
#   Action: System > Open
#   App: powershell.exe
#   Arguments: -ExecutionPolicy Bypass -File "C:\projects\tts-mix\5_Symbols\action-items.ps1"

$UserPrompt = @"
The user copied this text:

---
{CLIPBOARD}
---

Extract the concrete action items from this text. List up to 4 specific, imperative tasks that need to be done. If there are no clear action items, say so in one sentence. Read each item naturally as a short sentence. Respond in the same language as the text.
"@

$PipelineConfig = @{
    Name         = "action-items"
    Title        = "Action Items"
    FilePrefix   = "actions"
    StageEmoji   = "[!]"
    StageTitle   = "Asking xAI Grok: Extract Action Items"
    SystemPrompt = "You extract clear, actionable tasks from any text. Format each as a brief imperative sentence (e.g. 'Send the report to the team'). Maximum 4 items. Keep phrasing natural for text-to-speech."
    UserPromptTemplate = $UserPrompt
    Temperature    = 0.3
    MaxTokens      = 200
    BoxBorderColor = "DarkRed"
    BoxTextColor   = "Red"
}

. "$PSScriptRoot\_base.ps1"
Invoke-Pipeline
