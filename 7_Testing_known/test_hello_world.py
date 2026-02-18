"""
Simple Kokoro TTS Test - Hello World

This script tests if Kokoro TTS is working by saying "Hello World".
"""

import sys
import os

# Set UTF-8 encoding for Windows console
if sys.platform == 'win32':
    os.system('chcp 65001 >nul 2>&1')
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

def test_kokoro_hello_world():
    """Test Kokoro TTS with a simple Hello World message."""
    try:
        print("Testing Kokoro TTS...")
        print("Attempting to import Kokoro...")

        from kokoro import KPipeline
        import sounddevice as sd

        print("✓ Kokoro imported successfully")
        print("\nInitializing Kokoro pipeline...")

        # Initialize Kokoro with American English
        pipeline = KPipeline(lang_code='a')
        print("✓ Pipeline initialized")

        # Text to speak
        text = "Hello World! This is Kokoro Text to Speech working successfully."
        print(f"\nSpeaking: '{text}'")
        print("Please listen to your speakers...\n")

        # Generate and play audio
        generator = pipeline(text, voice='af_bella', speed=1.0)

        for i, (graphemes, phonemes, audio) in enumerate(generator):
            print(f"  Playing segment {i+1}...")
            sd.play(audio, 24000)
            sd.wait()

        print("\n✓ Hello World test completed successfully!")
        print("✓ Kokoro TTS is working!")
        return True

    except ImportError as e:
        print(f"\n✗ Import Error: {e}")
        print("\nTroubleshooting:")
        print("1. Install kokoro: pip install kokoro --no-deps")
        print("2. Install dependencies: pip install misaki huggingface-hub loguru num2words")
        print("3. Install sounddevice: pip install sounddevice")
        return False

    except Exception as e:
        print(f"\n✗ Error: {e}")
        print("\nPossible issues:")
        print("1. espeak-ng not installed (required for phoneme processing)")
        print("2. No audio output device available")
        print("3. Check 6_Semblance/TROUBLESHOOTING.md for detailed solutions")
        return False

if __name__ == "__main__":
    print("=" * 60)
    print("Kokoro TTS - Hello World Test")
    print("=" * 60)
    print()

    success = test_kokoro_hello_world()

    print()
    print("=" * 60)

    if success:
        print("TEST PASSED: Kokoro TTS is working!")
        sys.exit(0)
    else:
        print("TEST FAILED: Please check errors above")
        sys.exit(1)
