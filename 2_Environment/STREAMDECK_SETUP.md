# Stream Deck Setup for Clipboard TTS

This guide shows how to trigger text-to-speech from your Stream Deck button with clipboard content.

## Quick Setup

### Step 1: Get ElevenLabs API Key

1. Go to https://elevenlabs.io/app/settings/api-keys
2. Sign up or log in
3. Create a new API key
4. Copy the key

### Step 2: Configure Environment

```powershell
# In project directory
cd C:\projects\tts-mix

# Copy sample .env file
copy .env.sample .env

# Edit .env file and paste your API key
notepad .env
```

**Edit .env**:
```env
ELEVENLABS_API_KEY=sk_your_actual_api_key_here
VOICE_ID=JBFqnCBsd6RMkjVDRZzb
MODEL_ID=eleven_flash_v2_5
USE_CLOUD_FIRST=true
```

### Step 3: Test Manually

```powershell
# Copy some text to clipboard (Ctrl+C)
# Then run:
python 5_Symbols/app.py
```

You should hear your text spoken with natural voice!

### Step 4: Stream Deck Button Configuration

**Option A: Using System > Open (Recommended)**

1. **Open Stream Deck software**
2. **Drag "System > Open"** to a button
3. **Configure**:
   - **App/File**: `C:\Python314\python.exe`
    - **Arguments**: `"C:\projects\tts-mix\5_Symbols\app.py"`
   - **Title**: "Speak Clipboard"
   - **Icon**: Choose microphone or speaker icon

**Option B: Using PowerShell Script**

1. Create `speak.ps1`:
```powershell
# speak.ps1
Set-Location "C:\projects\tts-mix"
& "C:\Python314\python.exe" "5_Symbols\app.py"
```

2. **Stream Deck Configuration**:
   - **Action**: System > Open
   - **App/File**: `powershell.exe`
   - **Arguments**: `-ExecutionPolicy Bypass -File "C:\projects\tts-mix\speak.ps1"`
   - **Title**: "Speak Clipboard"

**Option C: Using Batch File**

1. Create `speak.bat`:
```batch
@echo off
cd /d C:\projects\tts-mix
C:\Python314\python.exe 5_Symbols\app.py
pause
```

2. **Stream Deck Configuration**:
   - **Action**: System > Open
   - **App/File**: `C:\projects\tts-mix\speak.bat`
   - **Title**: "Speak Clipboard"

---

## Usage Workflow

### Basic Use:
1. **Copy text** (Ctrl+C or right-click > Copy)
2. **Press Stream Deck button**
3. **Hear natural speech** via ElevenLabs

### What Happens:
```
[Copy Text] → [Press Button] → [Python reads clipboard]
  → [Sends to ElevenLabs] → [Plays audio] → [Done!]
```

### Examples:

**Read an article**:
1. Select paragraph
2. Ctrl+C
3. Press button
4. Listen while doing other tasks

**Proofread your writing**:
1. Copy your text
2. Press button
3. Hear how it sounds
4. Catch errors by ear

**Learn pronunciation**:
1. Copy foreign words
2. Press button
3. Hear correct pronunciation

---

## Advanced Configuration

### Multiple Voices

Create different buttons for different voices:

**Button 1: Male Voice (Charlie)**
```powershell
# speak_male.ps1
$env:VOICE_ID="JBFqnCBsd6RMkjVDRZzb"
& python 5_Symbols/app.py
```

**Button 2: Female Voice (Rachel)**
```powershell
# speak_female.ps1
$env:VOICE_ID="21m00Tcm4TlvDq8ikWAM"
& python 5_Symbols/app.py
```

**Button 3: British Accent (Charlotte)**
```powershell
# speak_british.ps1
$env:VOICE_ID="XB0fDUnXU5powFXDhCwa"
& python 5_Symbols/app.py
```

### Popular ElevenLabs Voice IDs

| Voice | ID | Description |
|-------|----|-|
| Charlie | JBFqnCBsd6RMkjVDRZzb | Casual, friendly male |
| Rachel | 21m00Tcm4TlvDq8ikWAM | Calm, female narrator |
| Clyde | 2EiwWnXFnvU5JabPnv8n | Strong, masculine |
| Nicole | piTKgcLEGmPE4e6mEKli | Warm, pleasant female |
| Charlotte | XB0fDUnXU5powFXDhCwa | British, sophisticated |
| Adam | pNInz6obpgDQGcFmaJgB | Deep, professional male |

Find more at: https://elevenlabs.io/voice-library

### Speed Control

Edit `5_Symbols/app.py` to add speed parameter:
```python
audio = client.text_to_speech.convert(
    text=text,
    voice_id=VOICE_ID,
    model_id=MODEL_ID,
    voice_settings={
        "speed": 1.0,  # 0.5 = slower, 1.5 = faster
        "stability": 0.5,
        "similarity_boost": 0.75
    }
)
```

---

## Troubleshooting

### Button does nothing

**Check:**
1. Python path correct: `where python`
2. App path correct: `C:\projects\tts-mix\5_Symbols\app.py` exists
3. Test manually first: `python 5_Symbols/app.py`

### "API key not set" error

**Fix:**
1. Verify `.env` file exists (not `.env.sample`)
2. Check API key is correct
3. No quotes around key in .env file
4. Restart terminal after editing .env

### "Clipboard empty" error

**Fix:**
1. Copy text **before** pressing button
2. Verify clipboard has content: `powershell -c "Get-Clipboard"`

### Audio not playing

**Fix:**
1. Check volume is up
2. Test: `python 7_Testing_known/test_simple.py` (should hear beep)
3. Verify speaker is default device

### Slow response

**Options:**
1. Use `MODEL_ID=eleven_flash_v2_5` (fastest)
2. Pre-load by running once: `python 5_Symbols/app.py` (keeps imports cached)
3. Consider espeak-ng for instant (robotic) feedback

---

## Stream Deck Icon Suggestions

### Built-in Icons:
- Microphone
- Speaker
- Sound wave
- Play button
- Voice command

### Custom Icons:
Create 72x72 or 144x144 PNG with:
- Speech bubble
- "TTS" text
- Voice wave animation
- ElevenLabs logo (if permitted)

---

## Cost Considerations

### ElevenLabs Pricing (as of 2024):

**Free Tier**:
- 10,000 characters/month
- ~1,700 words
- ~10-20 short texts per day

**Paid Tiers**:
- Starter: $5/month - 30,000 chars
- Creator: $22/month - 100,000 chars
- Pro: $99/month - 500,000 chars

**Usage Tips**:
1. Monitor usage at https://elevenlabs.io/usage
2. For testing: Use shorter text samples
3. For frequent use: Consider paid tier
4. For heavy use: Local Kokoro (requires Python 3.11/3.12)

---

## Multi-Button Layouts

### Suggested Stream Deck Layout:

```
┌─────────┬─────────┬─────────┐
│  Speak  │  Male   │ Female  │
│ Default │  Voice  │  Voice  │
├─────────┼─────────┼─────────┤
│ British │  Fast   │  Slow   │
│ Accent  │  Speed  │  Speed  │
├─────────┼─────────┼─────────┤
│  Stop   │  Test   │ Usage   │
│  Audio  │  Setup  │  Stats  │
└─────────┴─────────┴─────────┘
```

### Button Configurations:

**Stop Audio** (if needed):
```powershell
Stop-Process -Name "python" -Force
```

**Test Setup**:
```powershell
python C:\projects\tts-mix\7_Testing_known\test_simple.py
```

**Usage Stats**:
```powershell
Start-Process "https://elevenlabs.io/usage"
```

---

## Keyboard Shortcuts Alternative

If no Stream Deck, use AutoHotkey:

```ahk
; speak_clipboard.ahk
^!s::  ; Ctrl+Alt+S
{
    Run, C:\Python314\python.exe "C:\projects\tts-mix\5_Symbols\app.py"
}
```

Install AutoHotkey from https://www.autohotkey.com/

---

## Integration with Other Apps

### VS Code:
Use task or keyboard shortcut to trigger `python 5_Symbols/app.py`

### Browser:
Use browser extension to copy selected text, then trigger button

### Discord/Slack:
Copy message text, press button to hear it read aloud

### Email:
Copy email body, press button for audio version

---

## Performance Optimization

### Reduce Latency:

1. **Keep Python running**:
```python
# Modified app.py for daemon mode
while True:
    input("Press Enter to speak clipboard...")
    main()
```

2. **Preload imports**:
```powershell
# Faster subsequent calls
python -c "import elevenlabs; from dotenv import load_dotenv"
python 5_Symbols/app.py
```

3. **Use fastest model**:
```env
MODEL_ID=eleven_flash_v2_5  # Lowest latency
```

---

## Security Best Practices

### Protect Your API Key:

1. ✓ **DO**: Use `.env` file (excluded from git)
2. ✓ **DO**: Keep `.env` in `.gitignore`
3. ✓ **DO**: Use environment variables
4. ✗ **DON'T**: Commit API keys to git
5. ✗ **DON'T**: Share `.env` file
6. ✗ **DON'T**: Hard-code keys in scripts

### If Key Compromised:
1. Delete key at https://elevenlabs.io/app/settings/api-keys
2. Generate new key
3. Update `.env` file

---

## Quick Reference

### File Locations:
- **App**: `C:\projects\tts-mix\5_Symbols\app.py`
- **Config**: `C:\projects\tts-mix\.env`
- **Python**: `C:\Python314\python.exe` (adjust to your path)

### Commands:
```powershell
# Run app
python 5_Symbols/app.py

# Test setup
python 7_Testing_known/test_simple.py

# Check API key
cat .env | Select-String "ELEVENLABS_API_KEY"

# View usage
Start-Process "https://elevenlabs.io/usage"
```

### Support:
- ElevenLabs: https://elevenlabs.io/docs
- Project Issues: https://github.com/rifaterdemsahin/tts-mix/issues

---

**Ready to use!** Copy text, press button, hear natural speech with emotions.
