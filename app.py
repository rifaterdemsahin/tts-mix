"""
TTS Application - Clipboard to Speech
Reads text from clipboard and speaks it using Groq, ElevenLabs, or Kokoro.
Priority: Groq first (fast), ElevenLabs second (quality), Kokoro fallback (local).

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
GROQ_API_KEY = os.getenv("GROQ_API_KEY", "")
GROQ_VOICE = os.getenv("GROQ_VOICE", "troy")  # troy, austin, etc.
GROQ_MODEL = os.getenv("GROQ_MODEL", "canopylabs/orpheus-v1-english")

ELEVENLABS_API_KEY = os.getenv("ELEVENLABS_API_KEY", "")
VOICE_ID = os.getenv("VOICE_ID", "JBFqnCBsd6RMkjVDRZzb")  # Default: Charlie
MODEL_ID = os.getenv("MODEL_ID", "eleven_flash_v2_5")

def speak_groq(text):
    """
    Use Groq cloud TTS to speak the text (fast and free).
    Returns True on success, False on failure.
    """
    try:
        from groq import Groq
        import sounddevice as sd
        import numpy as np
        from io import BytesIO
        import wave

        if not GROQ_API_KEY:
            print("Groq API key not set, skipping...")
            return False

        client = Groq(api_key=GROQ_API_KEY)

        # Generate TTS audio
        response = client.audio.speech.create(
            model=GROQ_MODEL,
            voice=GROQ_VOICE,
            input=text
        )

        # Save to BytesIO buffer
        audio_buffer = BytesIO()
        for chunk in response.iter_bytes():
            audio_buffer.write(chunk)

        # Read WAV from buffer
        audio_buffer.seek(0)
        with wave.open(audio_buffer, 'rb') as wf:
            sample_rate = wf.getframerate()
            audio_data = np.frombuffer(wf.readframes(wf.getnframes()), dtype=np.int16)

        # Play audio
        sd.play(audio_data, sample_rate)
        sd.wait()
        return True

    except Exception as e:
        print(f"Groq TTS Failed: {e}")
        return False

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
    """Main application logic - tries Groq first, then ElevenLabs, then Kokoro."""
    # Get text from clipboard
    content = pyperclip.paste().strip()
    if not content:
        print("Clipboard is empty. Copy some text and try again.")
        sys.exit(1)

    # Show what we're about to speak
    preview = content[:100] + "..." if len(content) > 100 else content
    print(f"\nSpeaking: {preview}\n")

    # Priority: 1. Groq (fast), 2. ElevenLabs (quality), 3. Kokoro (local)
    success = False

    # Try Groq first
    if GROQ_API_KEY:
        print("Trying Groq TTS (fast and free)...")
        success = speak_groq(content)

    # Fallback to ElevenLabs
    if not success and ELEVENLABS_API_KEY:
        print("\nTrying ElevenLabs TTS (natural voice with emotions)...")
        success = speak_cloud(content)

    # Fallback to Kokoro
    if not success:
        print("\nTrying local TTS (Kokoro)...")
        success = speak_local(content)

    if not success:
        print("\nERROR: All TTS methods failed")
        print("1. For Groq: Set GROQ_API_KEY in .env file")
        print("2. For ElevenLabs: Set ELEVENLABS_API_KEY in .env file")
        print("3. For Kokoro: Use Python 3.11/3.12 (not 3.14)")
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

