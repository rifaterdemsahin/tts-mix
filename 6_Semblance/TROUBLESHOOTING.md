# Troubleshooting: Why is There No Output?

This document explains common issues that cause no audio output or errors when running TTS (Text-to-Speech) applications, particularly with the Kokoro TTS system.

## Common Error at Line 3 in app.py

When you see an error like:
```
PS C:\projects\Kokoro-82M-WebUI> python app.py
Traceback (most recent call last):
  File "C:\projects\Kokoro-82M-WebUI\app.py", line 3, in <module>
```

This typically indicates an **import error** at line 3 of your script. The most common causes are:

### 1. Missing Dependencies

**Problem:** Required Python packages are not installed.

**Solution:**
```bash
pip install kokoro pyperclip sounddevice numpy elevenlabs
```

**For Windows specifically:**
```bash
# Install espeak-ng (required by Kokoro for phoneme generation)
# Download the .msi installer from: https://github.com/espeak-ng/espeak-ng/releases
# Run the installer and ensure it's added to your PATH
```

### 2. Kokoro Package Not Found

**Problem:** The `kokoro` import fails because the package is not properly installed or is in development mode.

**Symptoms:**
- `ModuleNotFoundError: No module named 'kokoro'`
- Script crashes at `from kokoro import KPipeline`

**Solutions:**
1. Install kokoro from source:
   ```bash
   git clone https://github.com/remixer-dec/kokoro-82m
   cd kokoro-82m
   pip install -e .
   ```

2. Or install from PyPI (if available):
   ```bash
   pip install kokoro-tts
   ```

### 3. espeak-ng Not Installed or Not in PATH (Windows)

**Problem:** Kokoro requires `espeak-ng` for phoneme processing, but it's not installed or not accessible.

**Symptoms:**
- `FileNotFoundError: espeak-ng not found`
- `OSError: cannot load library 'espeak-ng.dll'`

**Solution for Windows:**
1. Download espeak-ng installer: https://github.com/espeak-ng/espeak-ng/releases
2. Install the .msi package
3. Add to PATH:
   - Default installation path: `C:\Program Files\eSpeak NG`
   - Add this to your System Environment Variables PATH
4. Restart PowerShell/Terminal
5. Verify installation:
   ```powershell
   espeak-ng --version
   ```

### 4. Audio Device Issues

**Problem:** No audio output even when the script runs without errors.

**Symptoms:**
- Script completes successfully
- No error messages
- But no sound is heard

**Solutions:**

1. **Check Default Audio Device:**
   - Ensure your speakers/headphones are set as the default audio device
   - Windows: Settings > System > Sound > Output

2. **Test sounddevice:**
   ```python
   import sounddevice as sd
   import numpy as np
   
   # Test audio output with a simple beep
   frequency = 440  # Hz
   duration = 1  # seconds
   sample_rate = 44100
   t = np.linspace(0, duration, int(sample_rate * duration))
   audio = np.sin(2 * np.pi * frequency * t)
   sd.play(audio, sample_rate)
   sd.wait()
   ```

3. **List Available Audio Devices:**
   ```python
   import sounddevice as sd
   print(sd.query_devices())
   ```

4. **Set Specific Audio Device:**
   ```python
   sd.default.device = 1  # Use device ID from query_devices()
   ```

### 5. Missing API Keys (for Cloud Fallback)

**Problem:** When local TTS fails and cloud fallback is used, but API key is missing.

**Symptoms:**
- "Cloud TTS Failed: Invalid API key"
- ElevenLabs authentication error

**Solution:**
1. Get your API key from: https://elevenlabs.io/app/settings/api-keys
2. Set it in your script:
   ```python
   ELEVENLABS_API_KEY = "your_actual_api_key_here"
   ```
3. Or use environment variable:
   ```bash
   export ELEVENLABS_API_KEY="your_actual_api_key_here"
   ```

### 6. PortAudio Issues (Windows/Mac)

**Problem:** sounddevice requires PortAudio library.

**Symptoms:**
- `OSError: PortAudio library not found`
- `ImportError: DLL load failed while importing _portaudio`

**Solution:**

**For Windows:**
```bash
# Usually installed automatically with sounddevice
pip install --upgrade sounddevice
# If issues persist, install from conda:
conda install portaudio
```

**For Mac:**
```bash
brew install portaudio
```

**For Linux:**
```bash
sudo apt-get install libportaudio2
```

## Quick Diagnostic Script

Create a file called `7_Testing_known/test_setup.py` to diagnose your setup:

```python
import sys

def test_imports():
    """Test if all required packages can be imported."""
    print("Testing imports...")
    
    try:
        import pyperclip
        print("✓ pyperclip installed")
    except ImportError as e:
        print(f"✗ pyperclip missing: {e}")
    
    try:
        import sounddevice as sd
        print("✓ sounddevice installed")
        print(f"  Default device: {sd.default.device}")
    except ImportError as e:
        print(f"✗ sounddevice missing: {e}")
    
    try:
        import numpy as np
        print("✓ numpy installed")
    except ImportError as e:
        print(f"✗ numpy missing: {e}")
    
    try:
        from kokoro import KPipeline
        print("✓ kokoro installed")
    except ImportError as e:
        print(f"✗ kokoro missing: {e}")
    
    try:
        from elevenlabs.client import ElevenLabs
        print("✓ elevenlabs installed")
    except ImportError as e:
        print(f"✗ elevenlabs missing: {e}")

def test_audio():
    """Test audio output."""
    print("\nTesting audio output...")
    try:
        import sounddevice as sd
        import numpy as np
        
        # List available devices
        print("\nAvailable audio devices:")
        print(sd.query_devices())
        
        # Play test beep
        print("\nPlaying test beep (440 Hz for 0.5 seconds)...")
        frequency = 440
        duration = 0.5
        sample_rate = 44100
        t = np.linspace(0, duration, int(sample_rate * duration))
        audio = np.sin(2 * np.pi * frequency * t) * 0.3
        sd.play(audio, sample_rate)
        sd.wait()
        print("✓ Audio test completed")
        
    except Exception as e:
        print(f"✗ Audio test failed: {e}")

def test_espeak():
    """Test if espeak-ng is available."""
    print("\nTesting espeak-ng...")
    import subprocess
    import os
    
    try:
        result = subprocess.run(['espeak-ng', '--version'], 
                              capture_output=True, text=True)
        print(f"✓ espeak-ng found: {result.stdout.strip()}")
    except FileNotFoundError:
        print("✗ espeak-ng not found in PATH")
        print("  Install from: https://github.com/espeak-ng/espeak-ng/releases")

if __name__ == "__main__":
    print("=== TTS Setup Diagnostic ===\n")
    test_imports()
    test_espeak()
    test_audio()
    print("\n=== Diagnostic Complete ===")
```

Run this script to identify missing components:
```bash
python 7_Testing_known/test_setup.py
```

## Step-by-Step Setup Guide for Windows

1. **Install Python 3.8+**
   - Download from: https://www.python.org/downloads/
   - ✓ Check "Add Python to PATH" during installation

2. **Install espeak-ng**
   - Download: https://github.com/espeak-ng/espeak-ng/releases
   - Install the .msi file
   - Verify: `espeak-ng --version`

3. **Install Python Dependencies**
   ```powershell
   pip install kokoro pyperclip sounddevice numpy elevenlabs
   ```

4. **Test Your Setup**
   ```powershell
   python 7_Testing_known/test_setup.py
   ```

5. **Run Your TTS Application**
   ```powershell
   python 5_Symbols/app.py
   ```

## Common Resolution Steps

1. **Always restart your terminal** after installing system packages (like espeak-ng)
2. **Use a virtual environment** to avoid package conflicts:
   ```bash
   python -m venv venv
   # Windows:
   .\venv\Scripts\activate
   # Mac/Linux:
   source venv/bin/activate
   ```
3. **Check Python version**: Ensure you're using Python 3.8 or higher
   ```bash
   python --version
   ```
4. **Update pip** before installing packages:
   ```bash
   python -m pip install --upgrade pip
   ```

## Still Having Issues?

If you're still experiencing problems:

1. Run the diagnostic script above
2. Check the full error traceback
3. Verify all dependencies are installed
4. Ensure your audio device is working
5. Try the test beep script to isolate audio issues

## Related Documentation

- [mix-strategy.md](../1_Real_Unknown/mix-strategy.md) - Hybrid TTS implementation guide
- [Kokoro GitHub](https://github.com/remixer-dec/kokoro-82m) - Official Kokoro repository
- [ElevenLabs API Docs](https://elevenlabs.io/docs) - Cloud TTS documentation

