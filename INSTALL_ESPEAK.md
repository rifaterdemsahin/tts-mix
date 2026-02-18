# espeak-ng Installation Guide for Windows

espeak-ng is a **required dependency** for Kokoro TTS. It provides phoneme processing for text-to-speech conversion.

## Quick Installation (Recommended)

### Option 1: Using Winget (Windows 10/11)

```powershell
winget install eSpeak-NG.eSpeak-NG
```

**Package Details:**
- **ID**: eSpeak-NG.eSpeak-NG
- **Version**: 1.52.0
- **Source**: winget (official Microsoft repository)

### Option 2: Using Chocolatey

```powershell
choco install espeak-ng
```

**Package Details:**
- **Package**: espeak-ng
- **Version**: 1.52.0
- **Status**: Approved by Chocolatey moderators

### Option 3: Manual Installation

1. Download the latest installer from GitHub:
   https://github.com/espeak-ng/espeak-ng/releases

2. Run the `.msi` installer (e.g., `espeak-ng-X64.msi`)

3. During installation, ensure "Add to PATH" is checked

4. Restart PowerShell/Terminal

## Verification

After installation, verify espeak-ng is accessible:

```powershell
espeak-ng --version
```

**Expected output:**
```
eSpeak NG text-to-speech: 1.52.0
Data Path: C:\Program Files\eSpeak NG
```

## Troubleshooting

### Issue: "espeak-ng: command not found"

**Solution 1: Restart Terminal**
```powershell
# Close and reopen PowerShell/Terminal
# Then try again
espeak-ng --version
```

**Solution 2: Manually Add to PATH**

1. Open **System Properties** → **Environment Variables**
2. Under **System variables**, find **Path**
3. Click **Edit** → **New**
4. Add: `C:\Program Files\eSpeak NG`
5. Click **OK** to save
6. Restart PowerShell/Terminal

**Solution 3: Use Full Path**
```powershell
# If PATH not working, use full path
& "C:\Program Files\eSpeak NG\espeak-ng.exe" --version
```

### Issue: Installation Fails

**For Winget:**
```powershell
# Update winget sources
winget source update

# Try again
winget install eSpeak-NG.eSpeak-NG
```

**For Chocolatey:**
```powershell
# Update chocolatey
choco upgrade chocolatey

# Try again
choco install espeak-ng
```

## Testing espeak-ng

### Basic Test
```powershell
espeak-ng "Hello World"
```
You should hear the text spoken.

### Test with Kokoro
After installation, run the diagnostic:
```powershell
python test_setup.py
```

Expected output:
```
✓ espeak-ng found: eSpeak NG text-to-speech: 1.52.0
```

## Why espeak-ng is Required

Kokoro TTS uses espeak-ng for:
1. **Text normalization** - Converting text to phonetic representation
2. **Phoneme generation** - Breaking down words into speech sounds
3. **IPA (International Phonetic Alphabet) conversion**

Without espeak-ng, Kokoro cannot:
- Process text input
- Generate phonemes
- Synthesize speech

## Comparison of Installation Methods

| Method | Pros | Cons |
|--------|------|------|
| **Winget** | Official MS tool, No admin needed* | Windows 10+ only |
| **Chocolatey** | Popular, well-maintained | Requires Chocolatey setup |
| **Manual .msi** | Always works, Simple | Manual updates needed |

\* Some winget operations may require admin depending on system configuration

## Recommended Installation Order

1. **Install espeak-ng** (this guide)
2. **Install Python packages**: `pip install kokoro sounddevice num2words`
3. **Run diagnostics**: `python test_setup.py`
4. **Test Kokoro**: `python test_simple.py`

## Integration with Kokoro

Once espeak-ng is installed, Kokoro will automatically detect and use it:

```python
from kokoro import KPipeline

# Kokoro uses espeak-ng internally
pipeline = KPipeline(lang_code='a')  # 'a' for American English
audio = pipeline("Hello World", voice='af_bella')
```

No additional configuration needed!

## Additional Resources

- **Official espeak-ng GitHub**: https://github.com/espeak-ng/espeak-ng
- **Documentation**: https://github.com/espeak-ng/espeak-ng/blob/master/docs/guide.md
- **Supported Languages**: https://github.com/espeak-ng/espeak-ng/blob/master/docs/languages.md

## Quick Reference Commands

```powershell
# Install (choose one)
winget install eSpeak-NG.eSpeak-NG
choco install espeak-ng

# Verify installation
espeak-ng --version

# Test voice output
espeak-ng "This is a test"

# List available voices
espeak-ng --voices

# Run full diagnostic
python test_setup.py
```

---

**Note**: After installing espeak-ng, you'll still need to address the Python 3.14 compatibility issue with Kokoro (see FIX_REPORT.md for details). Consider using Python 3.11 or 3.12 for full compatibility.
