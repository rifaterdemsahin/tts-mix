# tts-mix

A hybrid Text-to-Speech (TTS) system combining local Kokoro TTS with cloud ElevenLabs fallback.

## Documentation

- **[WINDOWS_SETUP.md](../2_Environment/WINDOWS_SETUP.md)** - Complete Windows PowerShell setup guide
- **[kokoro_setup.ps1](../2_Environment/kokoro_setup.ps1)** - Automated setup script for Windows
- **[mix-strategy.md](mix-strategy.md)** - Implementation guide for the hybrid TTS system
- **[TROUBLESHOOTING.md](../6_Semblance/TROUBLESHOOTING.md)** - Solutions for common setup and output issues
- **[test_setup.py](../7_Testing_known/test_setup.py)** - Diagnostic tool to test your TTS setup

## Quick Start

### Windows Users

1. **Automated Setup** (Recommended):
   ```powershell
   # Download and run the setup script
   Invoke-WebRequest -Uri "https://raw.githubusercontent.com/rifaterdemsahin/tts-mix/main/kokoro_setup.ps1" -OutFile "kokoro_setup.ps1"
   powershell -ExecutionPolicy Bypass -File .\kokoro_setup.ps1
   ```

2. **Manual Setup**:
   See [WINDOWS_SETUP.md](../2_Environment/WINDOWS_SETUP.md) for detailed step-by-step instructions.

### All Platforms

1. Run the diagnostic tool to check your setup:
   ```bash
   python 7_Testing_known/test_setup.py
   ```

2. If you encounter any issues, see [TROUBLESHOOTING.md](../6_Semblance/TROUBLESHOOTING.md) for detailed solutions.

## Common Issues

If you see an error like "Traceback (most recent call last): File 5_Symbols/app.py, line 3" or have no audio output, please check the [TROUBLESHOOTING.md](../6_Semblance/TROUBLESHOOTING.md) guide.
