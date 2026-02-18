"""
Quick test of ElevenLabs API configuration
"""

import os
from pathlib import Path
from dotenv import load_dotenv

# Load .env
PROJECT_ROOT = Path(__file__).resolve().parent.parent
load_dotenv(PROJECT_ROOT / ".env")

# Check configuration
api_key = os.getenv("ELEVENLABS_API_KEY")
voice_id = os.getenv("VOICE_ID")
model_id = os.getenv("MODEL_ID")

print("ElevenLabs Configuration:")
print(f"  API Key: {api_key[:20]}...{api_key[-10:] if api_key else 'NOT SET'}")
print(f"  Voice ID: {voice_id}")
print(f"  Model ID: {model_id}")
print()

if not api_key or api_key == "YOUR_API_KEY_HERE":
    print("ERROR: API key not configured")
    exit(1)

# Test API connection
print("Testing ElevenLabs API...")
try:
    from elevenlabs.client import ElevenLabs

    client = ElevenLabs(api_key=api_key)

    # Try to generate a short audio
    print("Generating test audio: 'Hello World'")
    audio = client.text_to_speech.convert(
        text="Hello World",
        voice_id=voice_id,
        model_id=model_id
    )

    # Check if we got audio data
    audio_data = b"".join(audio)
    print(f"Success! Generated {len(audio_data)} bytes of audio")
    print()
    print("Your ElevenLabs setup is working!")
    print("You can now use: python 5_Symbols/app.py")

except Exception as e:
    print(f"ERROR: {e}")
    print()
    print("Troubleshooting:")
    print("1. Check your API key is valid")
    print("2. Verify internet connection")
    print("3. Check ElevenLabs usage: https://elevenlabs.io/usage")
