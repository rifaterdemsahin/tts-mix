"""
Test All TTS Engines - fal.ai, ElevenLabs, and Kokoro
Tests each engine individually with "Hello World" message.
"""

import os
import sys

# Set UTF-8 encoding for Windows console
if sys.platform == 'win32':
    os.system('chcp 65001 >nul 2>&1')
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    print("Warning: python-dotenv not installed")

# Load configuration
FAL_KEY = os.getenv("FAL_KEY", "")

ELEVENLABS_API_KEY = os.getenv("ELEVENLABS_API_KEY", "")
VOICE_ID = os.getenv("VOICE_ID", "JBFqnCBsd6RMkjVDRZzb")
MODEL_ID = os.getenv("MODEL_ID", "eleven_flash_v2_5")

TEST_MESSAGE = "Hello World! This is a test of text to speech."

def test_fal():
    """Test fal.ai TTS"""
    print("\n" + "="*60)
    print("TEST 1: FAL.AI TTS")
    print("="*60)
    print(f"Testing: {TEST_MESSAGE}")
    print(f"Model: dia-tts")
    print("-"*60)

    if not FAL_KEY:
        print("❌ SKIPPED: FAL_KEY not configured in .env file")
        print("   Get key from: https://fal.ai/dashboard/keys")
        return False

    try:
        print("Loading fal.ai library...")
        import fal_client
        import sounddevice as sd
        import numpy as np
        from io import BytesIO
        import wave
        import httpx

        print("✓ fal.ai library loaded")
        print(f"✓ API Key configured: {FAL_KEY[:10]}...")

        # Set API key as environment variable
        os.environ['FAL_KEY'] = FAL_KEY

        print("\nGenerating speech with fal.ai...")
        result = fal_client.run(
            "fal-ai/dia-tts",
            arguments={
                "text": TEST_MESSAGE
            }
        )

        print("✓ Speech generated successfully")

        # Get audio URL from result
        audio_url = result.get("audio", {}).get("url")
        if not audio_url:
            print("❌ No audio URL in response")
            print(f"   Response keys: {list(result.keys())}")
            return False

        print(f"✓ Audio URL received: {audio_url[:50]}...")
        print("Downloading audio...")

        # Download audio file
        response = httpx.get(audio_url)
        response.raise_for_status()

        print(f"✓ Audio downloaded: {len(response.content)} bytes")
        print("\n🔊 Playing audio from FAL.AI...")
        print("   Listen to your speakers!\n")

        # Try to play audio (MP3 format from dia-tts)
        audio_buffer = BytesIO(response.content)
        audio_buffer.seek(0)

        try:
            # Try WAV first
            with wave.open(audio_buffer, 'rb') as wf:
                sample_rate = wf.getframerate()
                audio_data = np.frombuffer(wf.readframes(wf.getnframes()), dtype=np.int16)
            sd.play(audio_data, sample_rate)
            sd.wait()
        except wave.Error:
            # Try MP3 with pydub
            try:
                from pydub import AudioSegment
                from pydub.playback import play as pydub_play
                audio_buffer.seek(0)
                audio = AudioSegment.from_file(audio_buffer, format="mp3")
                pydub_play(audio)
            except ImportError:
                print("⚠ pydub not available for MP3 playback")
                print("   Install with: pip install pydub")
                print("   Audio was generated successfully but couldn't play")
                return False

        print("✅ FAL.AI TTS TEST PASSED")
        print("   Voice quality: Fast inference, high quality, natural")
        return True

    except Exception as e:
        print(f"❌ FAL.AI TTS TEST FAILED")
        print(f"   Error: {e}")
        return False

def test_elevenlabs():
    """Test ElevenLabs TTS"""
    print("\n" + "="*60)
    print("TEST 2: ELEVENLABS TTS")
    print("="*60)
    print(f"Testing: {TEST_MESSAGE}")
    print(f"Voice ID: {VOICE_ID}")
    print(f"Model: {MODEL_ID}")
    print("-"*60)

    if not ELEVENLABS_API_KEY:
        print("❌ SKIPPED: ELEVENLABS_API_KEY not configured in .env file")
        print("   Get key from: https://elevenlabs.io/app/settings/api-keys")
        return False

    try:
        print("Loading ElevenLabs library...")
        from elevenlabs.client import ElevenLabs
        from elevenlabs.play import play

        print("✓ ElevenLabs library loaded")
        print(f"✓ API Key configured: {ELEVENLABS_API_KEY[:10]}...")

        print("\nGenerating speech with ElevenLabs...")
        client = ElevenLabs(api_key=ELEVENLABS_API_KEY)

        audio = client.text_to_speech.convert(
            text=TEST_MESSAGE,
            voice_id=VOICE_ID,
            model_id=MODEL_ID
        )

        print("✓ Speech generated successfully")
        print("\n🔊 Playing audio from ELEVENLABS...")
        print("   Listen to your speakers!\n")

        play(audio)

        print("✅ ELEVENLABS TTS TEST PASSED")
        print("   Voice quality: Natural, emotional, high quality")
        return True

    except Exception as e:
        print(f"❌ ELEVENLABS TTS TEST FAILED")
        print(f"   Error: {e}")

        if "payment_issue" in str(e):
            print("   Issue: Subscription payment required")
            print("   Fix: Complete payment at https://elevenlabs.io/usage")
        elif "401" in str(e) or "invalid" in str(e).lower():
            print("   Issue: Invalid or expired API key")
            print("   Fix: Check key at https://elevenlabs.io/app/settings/api-keys")

        return False

def test_kokoro():
    """Test Kokoro TTS"""
    print("\n" + "="*60)
    print("TEST 3: KOKORO TTS (Local)")
    print("="*60)
    print(f"Testing: {TEST_MESSAGE}")
    print(f"Voice: af_bella (American Female)")
    print(f"Language: American English")
    print("-"*60)

    try:
        print("Loading Kokoro library...")
        from kokoro import KPipeline
        import sounddevice as sd

        print("✓ Kokoro library loaded")

        print("\nInitializing Kokoro pipeline...")
        pipeline = KPipeline(lang_code='a')
        print("✓ Pipeline initialized")

        print("\nGenerating speech with Kokoro...")
        generator = pipeline(TEST_MESSAGE, voice='af_bella', speed=1)

        print("✓ Speech generated successfully")
        print("\n🔊 Playing audio from KOKORO...")
        print("   Listen to your speakers!\n")

        for i, (graphemes, phonemes, audio) in enumerate(generator):
            print(f"   Playing segment {i+1}...")
            sd.play(audio, 24000)
            sd.wait()

        print("✅ KOKORO TTS TEST PASSED")
        print("   Voice quality: Natural AI voice, offline capable")
        return True

    except Exception as e:
        print(f"❌ KOKORO TTS TEST FAILED")
        print(f"   Error: {str(e)[:100]}...")

        if "REGEX" in str(e):
            print("   Issue: Python 3.14 incompatibility (Pydantic v1)")
            print("   Fix: Use Python 3.11 or 3.12")
        elif "espeak" in str(e).lower():
            print("   Issue: espeak-ng not found")
            print("   Fix: Install espeak-ng")
        elif "No module named" in str(e):
            print("   Issue: Kokoro not installed")
            print("   Fix: pip install kokoro")

        return False

def main():
    """Run all TTS tests"""
    print("\n" + "█"*60)
    print("   TTS ENGINE COMPARISON TEST")
    print("█"*60)
    print("\nThis script will test all 3 TTS engines:")
    print("1. fal.ai (cloud, fast & high quality)")
    print("2. ElevenLabs (cloud, high quality)")
    print("3. Kokoro (local, offline)")
    print("\nEach will speak: \"" + TEST_MESSAGE + "\"")

    results = {
        "fal.ai": test_fal(),
        "ElevenLabs": test_elevenlabs(),
        "Kokoro": test_kokoro()
    }

    # Summary
    print("\n" + "="*60)
    print("TEST SUMMARY")
    print("="*60)

    for engine, passed in results.items():
        status = "✅ PASSED" if passed else "❌ FAILED"
        print(f"{engine:15} {status}")

    passed_count = sum(results.values())
    total_count = len(results)

    print("-"*60)
    print(f"Results: {passed_count}/{total_count} engines working")
    print("="*60)

    if passed_count > 0:
        print("\n✓ At least one TTS engine is working!")
        print("\nWorking engines:")
        for engine, passed in results.items():
            if passed:
                print(f"  • {engine}")

        print("\nYou can use app.py for clipboard-to-speech workflow.")
    else:
        print("\n⚠ No TTS engines are working")
        print("\nNext steps:")
        print("1. Get fal.ai API key: https://fal.ai/dashboard/keys")
        print("2. Fix ElevenLabs payment: https://elevenlabs.io/usage")
        print("3. Or use Python 3.11/3.12 for Kokoro")

    print("\nSee SETUP_SUMMARY.md for detailed setup instructions.")
    print()

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\nTest interrupted by user")
        sys.exit(0)
    except Exception as e:
        print(f"\n\nUnexpected error: {e}")
        sys.exit(1)
