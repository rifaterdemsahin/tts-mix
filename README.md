# tts-mix

A hybrid Text-to-Speech (TTS) system combining local Kokoro TTS with cloud ElevenLabs fallback.

## Documentation

- **[WINDOWS_SETUP.md](WINDOWS_SETUP.md)** - Complete Windows PowerShell setup guide
- **[kokoro_setup.ps1](kokoro_setup.ps1)** - Automated setup script for Windows
- **[mix-strategy.md](mix-strategy.md)** - Implementation guide for the hybrid TTS system
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Solutions for common setup and output issues
- **[test_setup.py](test_setup.py)** - Diagnostic tool to test your TTS setup

## Quick Start

### Windows Users

1. **Automated Setup** (Recommended):
   ```powershell
   # Download and run the setup script
   Invoke-WebRequest -Uri "https://raw.githubusercontent.com/rifaterdemsahin/tts-mix/main/kokoro_setup.ps1" -OutFile "kokoro_setup.ps1"
   powershell -ExecutionPolicy Bypass -File .\kokoro_setup.ps1
   ```

2. **Manual Setup**:
   See [WINDOWS_SETUP.md](WINDOWS_SETUP.md) for detailed step-by-step instructions.

### All Platforms

1. Run the diagnostic tool to check your setup:
   ```bash
   python test_setup.py
   ```

2. If you encounter any issues, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for detailed solutions.

## Common Issues

If you see an error like "Traceback (most recent call last): File app.py, line 3" or have no audio output, please check the [TROUBLESHOOTING.md](TROUBLESHOOTING.md) guide.
