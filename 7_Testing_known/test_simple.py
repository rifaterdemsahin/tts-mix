"""
Simple Audio Test - Hello World

Tests basic audio output without Kokoro TTS dependencies.
This verifies sounddevice is working before testing Kokoro.
"""

import sys
import os

# Set UTF-8 encoding for Windows console
if sys.platform == 'win32':
    os.system('chcp 65001 >nul 2>&1')
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

def test_basic_audio():
    """Test basic audio output with a simple beep."""
    try:
        print("Testing basic audio output...")
        import sounddevice as sd
        import numpy as np

        print("✓ sounddevice imported successfully")

        # Generate a simple beep
        frequency = 440  # A4 note
        duration = 1.0  # seconds
        sample_rate = 44100

        t = np.linspace(0, duration, int(sample_rate * duration))
        audio = np.sin(2 * np.pi * frequency * t) * 0.3

        print(f"\nPlaying {frequency} Hz beep for {duration} second...")
        print("Listen to your speakers!\n")

        sd.play(audio, sample_rate)
        sd.wait()

        print("✓ Audio test completed!")
        return True

    except Exception as e:
        print(f"✗ Error: {e}")
        return False

def test_kokoro_status():
    """Check Kokoro installation status without running it."""
    print("\nChecking Kokoro installation...")

    packages = {
        'sounddevice': 'Audio output',
        'numpy': 'Numerical processing',
        'num2words': 'Number to words conversion',
    }

    for package, description in packages.items():
        try:
            __import__(package)
            print(f"  ✓ {package:15} - {description}")
        except ImportError:
            print(f"  ✗ {package:15} - {description} (NOT INSTALLED)")

    # Test kokoro separately with error handling
    print(f"\n  Testing Kokoro (may fail with Python 3.14)...")
    try:
        import kokoro
        print(f"  ✓ {'kokoro':15} - Kokoro TTS engine")
    except ImportError as e:
        print(f"  ✗ {'kokoro':15} - NOT INSTALLED: {e}")
    except Exception as e:
        print(f"  ✗ {'kokoro':15} - INCOMPATIBLE: {str(e)[:50]}...")
        print(f"     Issue: Python 3.14 not fully supported by spacy/pydantic")
        print(f"     Recommendation: Use Python 3.11 or 3.12 for full compatibility")

    print("\nChecking espeak-ng...")
    import subprocess
    try:
        result = subprocess.run(['espeak-ng', '--version'],
                              capture_output=True, text=True, timeout=5)
        if result.returncode == 0:
            version = result.stdout.strip().split('\n')[0]
            print(f"  ✓ espeak-ng found: {version}")
        else:
            print(f"  ✗ espeak-ng error")
    except FileNotFoundError:
        print(f"  ✗ espeak-ng NOT FOUND (required for Kokoro)")
        print(f"     Download from: https://github.com/espeak-ng/espeak-ng/releases")
    except Exception as e:
        print(f"  ✗ espeak-ng check failed: {e}")

if __name__ == "__main__":
    print("=" * 60)
    print("Simple Audio & Kokoro Status Test")
    print("=" * 60)
    print()

    # Test basic audio first
    audio_success = test_basic_audio()

    # Check Kokoro status
    test_kokoro_status()

    print()
    print("=" * 60)

    if audio_success:
        print("AUDIO TEST PASSED: Your audio system is working!")
        print()
        print("Next steps:")
        print("1. Install espeak-ng manually (see above)")
        print("2. Run 'python test_setup.py' for full diagnostic")
        print("3. Try 'python app.py' to test Kokoro TTS")
        sys.exit(0)
    else:
        print("AUDIO TEST FAILED: Check your audio setup")
        sys.exit(1)
