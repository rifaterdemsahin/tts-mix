# Stream Deck Integration Guide - Text-to-Speech

Complete guide to set up a Stream Deck button that reads highlighted text using fal.ai TTS.

**Last Updated**: 2026-02-18

---

## What You'll Achieve

Press a Stream Deck button → Highlighted text is read aloud instantly using fal.ai TTS

**Use Cases**:
- Read code while programming
- Listen to documentation
- Review written content
- Accessibility

---

## Prerequisites

✅ Stream Deck hardware (Stream Deck, Stream Deck Mini, Stream Deck XL, etc.)
✅ Stream Deck software installed ([Download here](https://www.elgato.com/downloads))
✅ Python 3.11+ with this TTS project set up
✅ fal.ai API key configured in `.env` file

---

## Quick Setup (5 Minutes)

### Step 1: Verify TTS Works

First, make sure your TTS system is working:

```powershell
# Test the TTS system
cd C:\projects\tts-mix
python test_fal_quick.py
```

You should see: `✅ FAL.AI TTS TEST PASSED`

### Step 2: Create Stream Deck Button

1. **Open Stream Deck Software**
2. **Drag "System > Open" action** to an empty button slot
3. **Configure the button**:

#### Button Configuration

**Title**: `Read Text` (or any name you prefer)

**App/File**:
```
C:\Python314\python.exe
```
*(Adjust path to match your Python installation)*

**Arguments**:
```
C:\projects\tts-mix\app.py
```
*(Adjust path to match where you cloned this repo)*

**Icon**: Choose a speaker/audio icon from Stream Deck gallery

### Step 3: Test It!

1. Highlight any text (in code editor, browser, document, etc.)
2. Press `Ctrl+C` to copy to clipboard
3. Press your Stream Deck button
4. Listen to your text being read!

---

## Detailed Configuration Methods

### Method 1: Direct Python Execution (Recommended)

**Best for**: Quick setup, simple workflow

**Stream Deck Action**: System > Open

**Configuration**:
- **App/File**: `C:\Python314\python.exe`
- **Arguments**: `C:\projects\tts-mix\app.py`
- **Working Directory**: Leave empty (optional)

**Pros**:
- Simple
- Direct execution
- No extra files needed

**Cons**:
- Console window appears briefly

---

### Method 2: PowerShell Script (No Console Window)

**Best for**: Clean execution without visible console

**Step 1**: Create PowerShell script `read-clipboard.ps1`:

```powershell
# read-clipboard.ps1
# Silently runs TTS without showing console window

Start-Process -FilePath "C:\Python314\python.exe" `
    -ArgumentList "C:\projects\tts-mix\app.py" `
    -WorkingDirectory "C:\projects\tts-mix" `
    -WindowStyle Hidden
```

Save to: `C:\projects\tts-mix\read-clipboard.ps1`

**Step 2**: Configure Stream Deck button:

**Stream Deck Action**: System > Open

**Configuration**:
- **App/File**: `powershell.exe`
- **Arguments**: `-ExecutionPolicy Bypass -File "C:\projects\tts-mix\read-clipboard.ps1"`
- **Icon**: Speaker icon

**Pros**:
- No console window
- Clean user experience
- Professional

**Cons**:
- Extra file to manage
- Requires PowerShell

---

### Method 3: Batch File (Windows Native)

**Best for**: Simple Windows-native solution

**Step 1**: Create batch file `read-clipboard.bat`:

```batch
@echo off
cd /d C:\projects\tts-mix
start /min python app.py
exit
```

Save to: `C:\projects\tts-mix\read-clipboard.bat`

**Step 2**: Configure Stream Deck button:

**Stream Deck Action**: System > Open

**Configuration**:
- **App/File**: `C:\projects\tts-mix\read-clipboard.bat`
- **Arguments**: *(leave empty)*

**Pros**:
- Simple Windows solution
- Minimizes console window
- No PowerShell needed

**Cons**:
- Console window still appears briefly

---

### Method 4: Python Executable (Advanced)

**Best for**: Distribution, no Python installation needed

**Step 1**: Install PyInstaller:

```powershell
pip install pyinstaller
```

**Step 2**: Create executable:

```powershell
cd C:\projects\tts-mix

pyinstaller --onefile --noconsole --name "ReadClipboard" app.py
```

This creates: `dist\ReadClipboard.exe`

**Step 3**: Configure Stream Deck button:

**Stream Deck Action**: System > Open

**Configuration**:
- **App/File**: `C:\projects\tts-mix\dist\ReadClipboard.exe`
- **Arguments**: *(leave empty)*

**Pros**:
- No console window
- No Python needed on other machines
- Professional standalone app

**Cons**:
- Large file size (~50-100MB)
- Requires rebuilding after code changes
- Antivirus may flag it

---

## Advanced Workflows

### Auto-Copy Workflow (No Ctrl+C Needed)

Some text editors/browsers support "auto-copy on highlight". When combined with Stream Deck:

1. Highlight text → Auto-copied
2. Press Stream Deck → Instant speech

**Supported in**:
- Visual Studio Code (with extensions)
- Sublime Text (with settings)
- Linux terminal emulators (via X11 selection)

**VS Code Setup**:
Install extension: "Auto Copy" or configure `settings.json`:
```json
{
  "editor.selectionClipboard": true
}
```

### Multi-Button Setup

Create multiple Stream Deck buttons for different use cases:

| Button | Function | Arguments |
|--------|----------|-----------|
| 🔊 Read Text | Read clipboard | `app.py` |
| ⏹️ Stop Reading | Kill Python | `taskkill /F /IM python.exe` |
| 🔄 Reload Config | Restart with new settings | `app.py` |

### Hotkey Integration

Don't have Stream Deck? Use built-in hotkey:

**Windows PowerToys** (Free):
1. Install [PowerToys](https://learn.microsoft.com/en-us/windows/powertoys/)
2. Open PowerToys Keyboard Manager
3. Create shortcut: `Ctrl+Alt+S` → Run `python app.py`

**AutoHotkey** (Free):
```ahk
; read-text.ahk
^!s::  ; Ctrl+Alt+S
    Run, python.exe C:\projects\tts-mix\app.py
Return
```

---

## Troubleshooting

### Issue: "Python not found"

**Solution**: Use full path to Python:

Find your Python path:
```powershell
where python
# Output: C:\Python314\python.exe
```

Use this full path in Stream Deck configuration.

### Issue: "Module not found" errors

**Solution**: Ensure you're in the correct directory:

Update your script to include working directory:

**PowerShell**:
```powershell
Set-Location C:\projects\tts-mix
python app.py
```

**Batch**:
```batch
cd /d C:\projects\tts-mix
python app.py
```

### Issue: Console window appears briefly

**Solutions**:
1. Use Method 2 (PowerShell with `-WindowStyle Hidden`)
2. Use Method 4 (PyInstaller with `--noconsole`)
3. Accept the brief flash (happens in <1 second)

### Issue: Nothing happens when button pressed

**Debugging steps**:

1. **Test manually**:
   ```powershell
   cd C:\projects\tts-mix
   python app.py
   ```

2. **Check clipboard**:
   - Copy some text first
   - Verify clipboard has content

3. **Check .env file**:
   ```powershell
   cat .env
   # Should show FAL_KEY=your_key_here
   ```

4. **Check Python path**:
   ```powershell
   where python
   # Ensure this matches Stream Deck configuration
   ```

### Issue: "API key not found"

**Solution**: Verify `.env` file exists and contains:
```
FAL_KEY=be93d3a7-e5f9-4fd0-9ce8-4a76420a0e60:9dc0b83d7769ef175a821241230e3954
```

### Issue: Audio plays from wrong device

**Solution**: Change default audio device in Windows:
1. Right-click speaker icon → Sound settings
2. Choose correct output device
3. Or modify `app.py` to specify device

---

## Icon Recommendations

**Where to find icons**:
- Stream Deck icon gallery (built-in)
- [streamdeckicons.com](https://streamdeckicons.com)
- [nerdordie.com](https://www.nerdordie.com/product/stream-deck-icons/)
- Create custom in Photoshop/GIMP (72x72px)

**Suggested icons**:
- 🔊 Speaker with sound waves
- 📢 Megaphone
- 🎙️ Microphone
- 📖 Open book
- 🗣️ Speaking head
- ▶️ Play button

**Custom Icon**:
Create 72x72px PNG with:
- Background color: #2C3E50 (dark blue)
- Icon: White speaker symbol
- Text: "TTS" or "Read"

---

## Performance Tips

### Speed Up Launch Time

**Option 1**: Keep Python process running in background

Create `tts-server.py`:
```python
import pyperclip
import time
import keyboard  # pip install keyboard

print("TTS Server running. Press Ctrl+Shift+S to read clipboard.")

def read_clipboard():
    from app import main
    main()

keyboard.add_hotkey('ctrl+shift+s', read_clipboard)
keyboard.wait()  # Keep running
```

Run once at startup, use hotkey instead of launching new process each time.

**Option 2**: Use compiled executable (Method 4)

### Reduce Audio Latency

Modify `app.py` to use streaming (advanced):
```python
# Instead of downloading full audio then playing,
# stream audio chunks as they arrive
```

---

## Example Use Cases

### For Developers

**Scenario**: Reading code documentation

1. Highlight function documentation in VS Code
2. Press Stream Deck button
3. Listen to explanation while coding

**Button Label**: "📖 Read Docs"

### For Writers

**Scenario**: Proofreading articles

1. Highlight paragraph
2. Press Stream Deck button
3. Listen for errors/flow issues

**Button Label**: "✍️ Proofread"

### For Learning

**Scenario**: Language learning

1. Highlight foreign text
2. Press Stream Deck button
3. Hear pronunciation

**Button Label**: "🗣️ Pronounce"

### For Accessibility

**Scenario**: Vision assistance

1. Highlight any text on screen
2. Press large Stream Deck XL button
3. Hear content read aloud

**Button Label**: "👁️ Read Aloud"

---

## Integration with Other Apps

### VS Code Integration

**Extension**: Create custom VS Code command

1. Install "Command Runner" extension
2. Add to `settings.json`:
   ```json
   {
     "command-runner.commands": {
       "Read Selected Text": "python C:\\projects\\tts-mix\\app.py"
     }
   }
   ```
3. Bind to Stream Deck or keyboard shortcut

### Browser Integration

**Userscript**: Auto-copy on highlight

Install Tampermonkey, create script:
```javascript
// ==UserScript==
// @name         Auto-copy highlighted text
// @match        *://*/*
// ==/UserScript==

document.addEventListener('mouseup', function() {
    let text = window.getSelection().toString().trim();
    if (text.length > 0) {
        navigator.clipboard.writeText(text);
    }
});
```

Now just highlight + press Stream Deck (no Ctrl+C needed).

---

## Multiple TTS Engines on Stream Deck

Create different buttons for different TTS engines:

| Button | Engine | Speed | Quality | Cost |
|--------|--------|-------|---------|------|
| 🚀 Fast TTS | fal.ai | Very Fast | High | $0.04/1k chars |
| 💎 Premium TTS | ElevenLabs | Fast | Premium | $0.18/1k chars |
| 🏠 Offline TTS | Kokoro | Moderate | Good | Free |

**Setup**: Create 3 different Python scripts:
- `app-fast.py` (fal.ai only)
- `app-premium.py` (ElevenLabs only)
- `app-offline.py` (Kokoro only)

---

## Security Notes

⚠️ **API Key Protection**:
- `.env` file contains your API key
- Do NOT commit `.env` to git
- `.gitignore` already protects it
- Keep `C:\projects\tts-mix` folder private

⚠️ **Clipboard Security**:
- This app reads your clipboard
- Only activate when you want to read text
- Sensitive data (passwords, etc.) will be sent to fal.ai if in clipboard
- Consider using dedicated hotkey instead of always-running service

---

## Cost Management

**fal.ai Pricing**: $0.04 per 1,000 characters

**Usage Estimates**:
| Daily Use | Characters/day | Monthly Cost |
|-----------|----------------|--------------|
| Light (10 reads) | ~5,000 | ~$6/month |
| Moderate (50 reads) | ~25,000 | ~$30/month |
| Heavy (200 reads) | ~100,000 | ~$120/month |

**Tips to reduce costs**:
1. Use for important content only
2. Set up Kokoro (free) for casual use
3. Monitor usage at https://fal.ai/dashboard
4. Use fal.ai for quality, Kokoro for quantity

---

## Next Steps

✅ Set up your Stream Deck button
✅ Test with highlighted code
✅ Customize icon and label
✅ Create additional buttons for different use cases
✅ Share your setup with team members

**Need Help?**
- Check `SETUP_SUMMARY.md` for TTS configuration
- Run `python test_fal_quick.py` to verify setup
- See `TROUBLESHOOTING.md` for common issues

---

## Advanced: Multi-Language Support

fal.ai supports multiple languages. To add language selection:

**Create language-specific buttons**:

`read-english.ps1`:
```powershell
$env:TTS_LANGUAGE = "en"
python C:\projects\tts-mix\app.py
```

`read-spanish.ps1`:
```powershell
$env:TTS_LANGUAGE = "es"
python C:\projects\tts-mix\app.py
```

Modify `app.py` to use `TTS_LANGUAGE` environment variable.

---

**Enjoy hands-free reading with your Stream Deck! 🎧**
