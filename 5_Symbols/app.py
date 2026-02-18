"""
TTS Application - Clipboard to Speech
Reads text from clipboard and speaks it using fal.ai, ElevenLabs, or Kokoro.
Priority: fal.ai first (fast & quality), ElevenLabs second (quality), Kokoro fallback (local).

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
FAL_KEY = os.getenv("FAL_KEY", "")

ELEVENLABS_API_KEY = os.getenv("ELEVENLABS_API_KEY", "")
VOICE_ID = os.getenv("VOICE_ID", "JBFqnCBsd6RMkjVDRZzb")  # Default: Charlie
MODEL_ID = os.getenv("MODEL_ID", "eleven_flash_v2_5")

def speak_fal(text):
    """
    Use fal.ai cloud TTS to speak the text (fast and high quality).
    Returns True on success, False on failure.
    """
    try:
        import fal_client
        import sounddevice as sd
        import numpy as np
        from io import BytesIO
        import wave
        import httpx

        if not FAL_KEY:
            print("fal.ai API key not set, skipping...")
            return False

        # Set API key as environment variable (fal_client reads from FAL_KEY)
        os.environ['FAL_KEY'] = FAL_KEY

        # Generate TTS audio using dia-tts model
        result = fal_client.run(
            "fal-ai/dia-tts",
            arguments={
                "text": text
            }
        )

        # Get audio URL from result
        audio_url = result.get("audio", {}).get("url")
        if not audio_url:
            print("No audio URL in response")
            return False

        # Download audio file
        response = httpx.get(audio_url)
        response.raise_for_status()

        # Load audio from bytes
        audio_buffer = BytesIO(response.content)
        audio_buffer.seek(0)

        # Read audio file (likely MP3 from dia-tts)
        # Try different audio formats
        try:
            with wave.open(audio_buffer, 'rb') as wf:
                sample_rate = wf.getframerate()
                audio_data = np.frombuffer(wf.readframes(wf.getnframes()), dtype=np.int16)
        except wave.Error:
            # If not WAV, try using pydub for MP3
            try:
                from pydub import AudioSegment
                from pydub.playback import play as pydub_play
                audio_buffer.seek(0)
                audio = AudioSegment.from_file(audio_buffer, format="mp3")
                pydub_play(audio)
                return True
            except ImportError:
                # If pydub not available, use mpg123 or similar
                print("Audio playback requires pydub for MP3 files")
                print("Install with: pip install pydub")
                return False

        # Play audio
        sd.play(audio_data, sample_rate)
        sd.wait()
        return True

    except Exception as e:
        print(f"fal.ai TTS Failed: {e}")
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
        from elevenlabs.play import play

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
    """Main application logic - tries fal.ai first, then ElevenLabs, then Kokoro."""
    # Get text from clipboard
    content = pyperclip.paste().strip()
    if not content:
        print("Clipboard is empty. Copy some text and try again.")
        sys.exit(1)

    # Show what we're about to speak
    preview = content[:100] + "..." if len(content) > 100 else content
    print(f"\nSpeaking: {preview}\n")

    # Priority: 1. fal.ai (fast & quality), 2. ElevenLabs (quality), 3. Kokoro (local)
    success = False

    # Try fal.ai first
    if FAL_KEY:
        print("Trying fal.ai TTS (fast and high quality)...")
        success = speak_fal(content)

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
        print("1. For fal.ai: Set FAL_KEY in .env file")
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

