"""
TTS Setup Diagnostic Script

This script tests your Text-to-Speech setup and identifies missing components.
Run this before using the TTS application to ensure all dependencies are installed.

Usage:
    python test_setup.py
"""

import sys
import os

# Set UTF-8 encoding for Windows console
if sys.platform == 'win32':
    os.system('chcp 65001 >nul 2>&1')
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

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
        print("  Install: pip install kokoro-tts")
        print("  Or from source: https://github.com/remixer-dec/kokoro-82m")
    
    try:
        from elevenlabs.client import ElevenLabs
        print("✓ elevenlabs installed")
    except ImportError as e:
        print(f"✗ elevenlabs missing: {e}")
        print("  Install: pip install elevenlabs")

def test_audio():
    """Test audio output."""
    print("\nTesting audio output...")
    try:
        import sounddevice as sd
        import numpy as np
        
        # List available devices
        print("\nAvailable audio devices:")
        devices = sd.query_devices()
        print(devices)
        
        # Play test beep
        print("\nPlaying test beep (440 Hz for 0.5 seconds)...")
        print("You should hear a short beep sound.")
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
                              capture_output=True, text=True, timeout=5)
        if result.returncode == 0:
            print(f"✓ espeak-ng found: {result.stdout.strip()}")
        else:
            print(f"✗ espeak-ng error: {result.stderr}")
    except FileNotFoundError:
        print("✗ espeak-ng not found in PATH")
        print("  Windows: Download from https://github.com/espeak-ng/espeak-ng/releases")
        print("  Mac: brew install espeak-ng")
        print("  Linux: sudo apt-get install espeak-ng")
    except subprocess.TimeoutExpired:
        print("✗ espeak-ng command timed out")
    except Exception as e:
        print(f"✗ espeak-ng test failed: {e}")

def test_environment():
    """Test environment and Python version."""
    print("\nTesting environment...")
    print(f"✓ Python version: {sys.version}")
    print(f"✓ Python executable: {sys.executable}")
    
    # Check if running in virtual environment
    if hasattr(sys, 'real_prefix') or (hasattr(sys, 'base_prefix') and sys.base_prefix != sys.prefix):
        print("✓ Running in virtual environment")
    else:
        print("⚠ Not running in virtual environment (recommended to use one)")

if __name__ == "__main__":
    print("=" * 50)
    print("TTS Setup Diagnostic Tool")
    print("=" * 50)
    print()
    
    test_environment()
    test_imports()
    test_espeak()
    test_audio()
    
    print()
    print("=" * 50)
    print("Diagnostic Complete")
    print("=" * 50)
    print()
    print("Next steps:")
    print("1. Install any missing dependencies listed above")
    print("2. Restart your terminal/PowerShell")
    print("3. Run this test again to verify")
    print("4. Check TROUBLESHOOTING.md for detailed solutions")

