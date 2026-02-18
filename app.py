"""
Example TTS Application
This is a reference implementation showing proper imports and error handling.
"""

import pyperclip  # Common error point if not installed - see TROUBLESHOOTING.md
import os
import sys

# --- CONFIGURATION ---
ELEVENLABS_API_KEY = "YOUR_API_KEY_HERE"
VOICE_ID = "JBFqnCBsd6RMkjVDRZzb"  # Default: Charlie
USE_LOCAL_FIRST = True

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
    Returns True on success, False on failure.
    """
    try:
        from elevenlabs.client import ElevenLabs
        from elevenlabs import play
        
        client = ElevenLabs(api_key=ELEVENLABS_API_KEY)
        audio = client.text_to_speech.convert(
            text=text,
            voice_id=VOICE_ID,
            model_id="eleven_flash_v2_5"  # Low latency model
        )
        play(audio)
        return True
    except Exception as e:
        print(f"Cloud TTS Failed: {e}")
        return False

def main():
    """Main application logic."""
    # Get text from clipboard
    content = pyperclip.paste().strip()
    if not content:
        print("Clipboard empty.")
        sys.exit(1)

    print(f"Speaking: {content[:50]}...")
    
    # Try local first, then fallback to cloud
    success = False
    if USE_LOCAL_FIRST:
        print("Attempting local TTS (Kokoro)...")
        success = speak_local(content)
    
    if not success:
        print("Falling back to ElevenLabs...")
        if ELEVENLABS_API_KEY == "YOUR_API_KEY_HERE":
            print("ERROR: Please set your ElevenLabs API key in the script")
            sys.exit(1)
        speak_cloud(content)

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
