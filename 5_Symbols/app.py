"""
TTS Application - Clipboard to Speech
Reads text from clipboard and speaks it using fal.ai, ElevenLabs, or Kokoro.
Priority: fal.ai first (fast & quality), ElevenLabs second (quality), Kokoro fallback (local).

Usage:
1. Copy text to clipboard
2. Run: python 5_Symbols/app.py
3. Trigger from Stream Deck button for quick access
"""

import pyperclip
import os
import sys
import time
import threading
from pathlib import Path
from datetime import datetime

# Downloads folder for saving audio files
DOWNLOADS_DIR = Path.home() / "Downloads"

# Load environment variables from .env file
try:
    from dotenv import load_dotenv
    project_root = Path(__file__).resolve().parent.parent
    load_dotenv(project_root / ".env")
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

        # Calculate cost (fal.ai dia-tts: $0.04 per 1000 characters)
        char_count = len(text)
        cost = (char_count / 1000) * 0.04
        print(f"💰 Cost: ${cost:.4f} ({char_count} characters @ $0.04/1k chars)")

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

        # Save audio to Downloads folder
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        save_path = DOWNLOADS_DIR / f"tts_fal_{timestamp}.mp3"
        save_path.write_bytes(response.content)
        print(f"💾 Saved: {save_path}")

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
        
        import numpy as np
        all_audio = []
        for i, (gs, ps, audio) in enumerate(generator):
            all_audio.append(audio)
            sd.play(audio, 24000)
            sd.wait()

        # Save combined audio to Downloads folder
        import scipy.io.wavfile as wavfile
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        save_path = DOWNLOADS_DIR / f"tts_kokoro_{timestamp}.wav"
        combined = np.concatenate(all_audio)
        wavfile.write(str(save_path), 24000, (combined * 32767).astype(np.int16))
        print(f"💾 Saved: {save_path}")
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

        # Save audio to Downloads folder
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        save_path = DOWNLOADS_DIR / f"tts_elevenlabs_{timestamp}.mp3"
        audio_bytes = b"".join(audio)
        save_path.write_bytes(audio_bytes)
        print(f"💾 Saved: {save_path}")

        # Play the saved file
        from pydub import AudioSegment
        from pydub.playback import play as pydub_play
        audio_segment = AudioSegment.from_file(str(save_path), format="mp3")
        pydub_play(audio_segment)
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
    word_count = len(content.split())
    char_count = len(content)
    est_reading_min = word_count / 150  # ~150 words per minute for TTS
    print(f"\nSpeaking: {preview}")
    print(f"   📝 {word_count} words, {char_count} chars (~{est_reading_min:.1f} min estimated)\n")

    # Priority: 1. fal.ai (fast & quality), 2. ElevenLabs (quality), 3. Kokoro (local)
    success = False
    overall_start = time.time()
    start_time = overall_start

    # Try fal.ai first
    if FAL_KEY:
        print("=" * 60)
        print("🟡 STARTING TTS — fal.ai (dia-tts)")
        print(f"   ⏱️  Started at {time.strftime('%H:%M:%S')}")
        print("=" * 60)
        success = speak_fal(content)
        if success:
            elapsed = time.time() - start_time
            print(f"\n🟢 SENT — Audio delivered in {elapsed:.1f}s")

    # Fallback to ElevenLabs
    if not success and ELEVENLABS_API_KEY:
        start_time = time.time()
        print("\n" + "=" * 60)
        print("🟡 STARTING TTS — ElevenLabs")
        print(f"   Voice: {VOICE_ID}")
        print(f"   Model: {MODEL_ID}")
        print(f"   ⏱️  Started at {time.strftime('%H:%M:%S')}")
        print("=" * 60)
        success = speak_cloud(content)
        if success:
            elapsed = time.time() - start_time
            print(f"\n🟢 SENT — Audio delivered in {elapsed:.1f}s")

    # Fallback to Kokoro
    if not success:
        start_time = time.time()
        print("\n" + "=" * 60)
        print("🟡 STARTING TTS — Kokoro (Local/Offline)")
        print("   Voice: af_bella (American Female)")
        print(f"   ⏱️  Started at {time.strftime('%H:%M:%S')}")
        print("=" * 60)
        success = speak_local(content)
        if success:
            elapsed = time.time() - start_time
            print(f"\n🟢 SENT — Audio delivered in {elapsed:.1f}s")

    if not success:
        print("\n" + "=" * 60)
        print("❌ ERROR: All TTS methods failed")
        print("=" * 60)
        print("1. For fal.ai: Set FAL_KEY in .env file")
        print("2. For ElevenLabs: Set ELEVENLABS_API_KEY in .env file")
        print("3. For Kokoro: Use Python 3.11/3.12 (not 3.14)")
        sys.exit(1)

    print("\n" + "=" * 60)
    total_elapsed = time.time() - overall_start
    mins, secs = divmod(total_elapsed, 60)
    if mins >= 1:
        print(f"✅ Speech completed successfully!  ⏱️ Total: {int(mins)}m {secs:.0f}s")
    else:
        print(f"✅ Speech completed successfully!  ⏱️ Total: {total_elapsed:.1f}s")
    print("=" * 60)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nInterrupted by user")
    except Exception as e:
        print(f"Unexpected error: {e}")
        print("\nRun 'python 7_Testing_known/test_setup.py' to diagnose your setup")
        print("See 6_Semblance/TROUBLESHOOTING.md for detailed solutions")
    finally:
        print("\n" + "-" * 60)
        print("Press Enter to close (auto-closes in 5 minutes)...")
        # Auto-close after 5 minutes using a daemon timer
        timer = threading.Timer(300, lambda: os._exit(0))
        timer.daemon = True
        timer.start()
        try:
            input()
        except EOFError:
            time.sleep(300)
        sys.exit(0)

