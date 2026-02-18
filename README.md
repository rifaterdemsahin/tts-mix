# tts-mix

A hybrid Text-to-Speech (TTS) system combining local Kokoro TTS with cloud ElevenLabs fallback.

## Documentation

- **[mix-strategy.md](mix-strategy.md)** - Implementation guide for the hybrid TTS system
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Solutions for common setup and output issues
- **[test_setup.py](test_setup.py)** - Diagnostic tool to test your TTS setup

## Quick Start

1. Run the diagnostic tool to check your setup:
   ```bash
   python test_setup.py
   ```

2. If you encounter any issues, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for detailed solutions.

## Common Issues

If you see an error like "Traceback (most recent call last): File app.py, line 3" or have no audio output, please check the [TROUBLESHOOTING.md](TROUBLESHOOTING.md) guide.
