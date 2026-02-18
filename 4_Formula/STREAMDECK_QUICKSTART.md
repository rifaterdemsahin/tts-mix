# Stream Deck Quick Start - Read Clipboard with TTS

**Set up a Stream Deck button to read highlighted text in under 2 minutes!**

---

## The Fastest Setup (30 Seconds)

### Step 1: Configure Stream Deck Button

1. **Open Stream Deck software**
2. **Drag "System > Open"** action to an empty button
3. **Configure**:

```
Action: System > Open
App/File: powershell.exe
Arguments: -ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\projects\tts-mix\read-clipboard-silent.ps1"
Title: 🔊 Read Text
```

4. **Choose an icon** (speaker, microphone, or book)

### Step 2: Use It!

1. Highlight any text (code, article, email, etc.)
2. Press `Ctrl+C` to copy
3. Press your Stream Deck button
4. Listen! 🎧

**Done!** Your text will be read aloud using fal.ai's natural voice.

---

## Two Script Options

### Option 1: Silent Version (Recommended)

**Script**: `read-clipboard-silent.ps1`

**Pros**:
- ✅ No popup messages
- ✅ Clean, professional experience
- ✅ No console window flash
- ✅ Silent errors (just doesn't speak if issue)

**Stream Deck Config**:
```
Arguments: -ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\projects\tts-mix\read-clipboard-silent.ps1"
```

### Option 2: With Error Messages

**Script**: `read-clipboard.ps1`

**Pros**:
- ✅ Shows helpful error messages
- ✅ Tells you if clipboard is empty
- ✅ Guides you to fix issues
- ✅ Good for troubleshooting

**Stream Deck Config**:
```
Arguments: -ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\projects\tts-mix\read-clipboard.ps1"
```

---

## How It Works

```
You press button
    ↓
PowerShell script runs
    ↓
Checks clipboard has text
    ↓
Finds Python installation automatically
    ↓
Runs 5_Symbols/app.py
    ↓
Downloads audio from fal.ai
    ↓
Plays through speakers
    ↓
Done! 🎵
```

---

## What the Scripts Do

### Automatic Python Detection

The script automatically finds Python in these locations:
- `C:\Python314\python.exe`
- `C:\Python313\python.exe`
- `C:\Python312\python.exe`
- `C:\Python311\python.exe`
- `C:\Python310\python.exe`
- System PATH

**No manual configuration needed!**

### Smart Error Handling

**Silent version**:
- Empty clipboard → Does nothing
- Python not found → Does nothing
- API error → Does nothing

**Verbose version**:
- Empty clipboard → Shows popup: "Please copy text first"
- Python not found → Shows popup with installation link
- API error → Shows popup with troubleshooting steps

---

## Workflow Examples

### For Developers

**Reading documentation**:
```
1. Find function in docs
2. Highlight explanation
3. Ctrl+C
4. Press Stream Deck button
5. Keep coding while listening
```

### For Writers

**Proofreading**:
```
1. Write paragraph
2. Highlight it
3. Ctrl+C
4. Press Stream Deck button
5. Listen for awkward phrasing
```

### For Learners

**Study materials**:
```
1. Find important paragraph
2. Highlight
3. Ctrl+C
4. Press Stream Deck button
5. Listen while taking notes
```

---

## Advanced: Auto-Copy Setup

**Skip the Ctrl+C step!** Some apps can auto-copy when you highlight.

### VS Code (with extension)

1. Install "Auto Copy" extension
2. Settings → Search "auto copy"
3. Enable "Auto Copy On Select"

Now just highlight → press Stream Deck!

### Browser (with Tampermonkey)

Create userscript:
```javascript
// Auto-copy on text selection
document.addEventListener('mouseup', function() {
    let text = window.getSelection().toString().trim();
    if (text.length > 0) {
        navigator.clipboard.writeText(text);
    }
});
```

Now just highlight → press Stream Deck!

---

## Testing the Scripts

### Test from PowerShell

```powershell
# Navigate to project
cd C:\projects\tts-mix

# Test silent version
.\read-clipboard-silent.ps1

# Test verbose version
.\read-clipboard.ps1
```

### Test from Stream Deck

1. Copy this text: "Hello World, this is a test"
2. Press your Stream Deck button
3. You should hear the text spoken

---

## Troubleshooting

### Button does nothing

**Check**:
1. Copy some text first (`Ctrl+C`)
2. Verify clipboard: `Get-Clipboard` in PowerShell
3. Test script manually: `.\read-clipboard.ps1`

### "Python not found" error

**Fix**:
1. Find Python: `where python` in PowerShell
2. Edit script, update `$PythonPaths` array with your path
3. Or install Python: `winget install Python.Python.3.11`

### "App.py not found" error

**Fix**:
1. Verify path in Stream Deck config matches your installation
2. Update script if you moved the project folder

### No audio plays

**Fix**:
1. Test manually: `python 7_Testing_known/test_fal_quick.py`
2. Check .env file has `FAL_KEY=your_api_key`
3. Verify speakers are working
4. Check volume is up

### API key errors

**Fix**:
1. Check `.env` file exists (not `.env.sample`)
2. Verify `FAL_KEY` is set correctly
3. Test: `python 7_Testing_known/test_fal_quick.py`
4. Get key from: https://fal.ai/dashboard/keys

---

## Multiple Buttons Setup

Create different buttons for different use cases:

### Button 1: Read Text (fal.ai)
```
Script: read-clipboard-silent.ps1
Icon: 🔊 Speaker
Title: Read Text
```

### Button 2: Read with Status
```
Script: read-clipboard.ps1
Icon: 📢 Megaphone
Title: Read (Debug)
```

### Button 3: Stop Reading
```
Action: System > Open
App: taskkill
Arguments: /F /IM python.exe
Icon: ⏹️ Stop
Title: Stop TTS
```

---

## Customization

### Change Voice Speed

Edit `5_Symbols/app.py`, add to fal.ai arguments:
```python
arguments={
    "text": text,
    "speed": 1.2  # 1.0 = normal, 1.5 = faster, 0.8 = slower
}
```

### Change TTS Engine Priority

Edit `.env` file:
```
# Option 1: Use only fal.ai
FAL_KEY=your_key_here
ELEVENLABS_API_KEY=

# Option 2: Use only ElevenLabs
FAL_KEY=
ELEVENLABS_API_KEY=your_key_here
```

The app automatically tries engines in order until one works.

---

## Performance Tips

### Faster Launch

**Pre-warm Python**:
Create a background service that keeps Python loaded. This makes subsequent calls instant.

### Reduce Latency

The script is already optimized:
- ✅ No console window (`-WindowStyle Hidden`)
- ✅ Direct Python execution
- ✅ Minimal error checking in silent mode
- ✅ Auto-detects Python path

**Typical timing**:
- Script launch: ~200ms
- API call: ~1-2 seconds
- Total: ~2-3 seconds from button press to audio

---

## Security Notes

⚠️ **Clipboard Data**:
- This script reads whatever is in your clipboard
- If you copy passwords/secrets, they may be sent to fal.ai
- Only press the button when you want to read safe content

⚠️ **API Key**:
- Stored in `.env` file
- Not committed to git (protected by `.gitignore`)
- Keep your project folder private

---

## Cost Tracking

**fal.ai pricing**: $0.04 per 1,000 characters

**Estimate your usage**:
| Usage | Chars/day | Monthly Cost |
|-------|-----------|--------------|
| Light (5 reads, 500 chars each) | 2,500 | ~$3/month |
| Medium (20 reads, 500 chars each) | 10,000 | ~$12/month |
| Heavy (100 reads, 500 chars each) | 50,000 | ~$60/month |

**Track usage**: https://fal.ai/dashboard

---

## What's Next?

✅ You now have a working Stream Deck TTS button!

**More features**:
- See `STREAMDECK_INTEGRATION.md` for advanced setups
- Check `2_Environment/SETUP_SUMMARY.md` for other TTS engines
- Read `6_Semblance/TROUBLESHOOTING.md` if issues arise

**Enjoy hands-free reading! 🎧📖**

---

## Quick Reference

### Stream Deck Config (Copy-Paste)

**Silent Version** (Recommended):
```
Action: System > Open
App/File: powershell.exe
Arguments: -ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\projects\tts-mix\read-clipboard-silent.ps1"
```

**With Error Messages**:
```
Action: System > Open
App/File: powershell.exe
Arguments: -ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\projects\tts-mix\read-clipboard.ps1"
```

### Manual Test Commands

```powershell
# Test clipboard → TTS
echo "Test message" | clip
.\read-clipboard-silent.ps1

# Test fal.ai API
python 7_Testing_known/test_fal_quick.py

# Test full TTS
python 5_Symbols/app.py
```
