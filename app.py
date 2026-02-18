"""
TTS Application - Clipboard to Speech
Reads text from clipboard and speaks it using ElevenLabs (cloud) or Kokoro (local).
Priority: ElevenLabs first for best quality, then fallback to local.

Usage:
1. Copy text to clipboard
2. Run: python app.py
3. Trigger from Stream Deck button for quick access
"""

import pyperclip
import os
import sys
from pathlib import Path

# Load environment variables from .env file
try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    print("Warning: python-dotenv not installed. Install with: pip install python-dotenv")
    print("Using environment variables or defaults...")

# --- CONFIGURATION FROM .ENV ---
ELEVENLABS_API_KEY = os.getenv("ELEVENLABS_API_KEY", "YOUR_API_KEY_HERE")
VOICE_ID = os.getenv("VOICE_ID", "JBFqnCBsd6RMkjVDRZzb")  # Default: Charlie
MODEL_ID = os.getenv("MODEL_ID", "eleven_flash_v2_5")
USE_CLOUD_FIRST = os.getenv("USE_CLOUD_FIRST", "true").lower() == "true"

def speak_local(text):
    """
    Use local Kokoro TTS to speak the text.
    Returns True on success, False on failure.
    """
    try:
        from kokoro import KPipeline
        import sounddevice as sd
        
        # 'a' for American English, 'b' for British
        pipeline = KPipeline(lang_code='a') 
        generator = pipeline(text, voice='af_bella', speed=1, split_pattern=r'\n+')
        
        for i, (gs, ps, audio) in enumerate(generator):
            sd.play(audio, 24000)
            sd.wait()
        return True
    except Exception as e:
        print(f"Local TTS Failed: {e}")
        return False

def speak_cloud(text):
    """
    Use ElevenLabs cloud TTS to speak the text.
    Best quality, natural voice with emotions.
    Returns True on success, False on failure.
    """
    try:
        from elevenlabs.client import ElevenLabs
        from elevenlabs import play

        if ELEVENLABS_API_KEY == "YOUR_API_KEY_HERE" or not ELEVENLABS_API_KEY:
            print("ERROR: ElevenLabs API key not set")
            print("1. Copy .env.sample to .env")
            print("2. Add your API key from https://elevenlabs.io/app/settings/api-keys")
            return False

        client = ElevenLabs(api_key=ELEVENLABS_API_KEY)
        audio = client.text_to_speech.convert(
            text=text,
            voice_id=VOICE_ID,
            model_id=MODEL_ID
        )
        play(audio)
        return True
    except Exception as e:
        print(f"ElevenLabs TTS Failed: {e}")
        return False

def main():
    """Main application logic - prioritizes ElevenLabs for best quality."""
    # Get text from clipboard
    content = pyperclip.paste().strip()
    if not content:
        print("Clipboard is empty. Copy some text and try again.")
        sys.exit(1)

    # Show what we're about to speak
    preview = content[:100] + "..." if len(content) > 100 else content
    print(f"\nSpeaking: {preview}\n")

    # Try cloud first (ElevenLabs - best quality), then fallback to local
    success = False

    if USE_CLOUD_FIRST:
        print("Using ElevenLabs cloud TTS (natural voice with emotions)...")
        success = speak_cloud(content)

        if not success:
            print("\nFalling back to local TTS (Kokoro)...")
            success = speak_local(content)
    else:
        print("Attempting local TTS (Kokoro)...")
        success = speak_local(content)

        if not success:
            print("\nFalling back to ElevenLabs...")
            success = speak_cloud(content)

    if not success:
        print("\nERROR: All TTS methods failed")
        print("1. For ElevenLabs: Set API key in .env file")
        print("2. For Kokoro: Use Python 3.11/3.12 (not 3.14)")
        sys.exit(1)

    print("\n✓ Speech completed successfully!")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nInterrupted by user")
        sys.exit(0)
    except Exception as e:
        print(f"Unexpected error: {e}")
        print("\nRun 'python test_setup.py' to diagnose your setup")
        print("See TROUBLESHOOTING.md for detailed solutions")
        sys.exit(1)

