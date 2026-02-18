This is the ultimate "Engineer's Workflow": building a **hybrid local-first system**. Using a local model as your primary driver gives you that instantaneous "hands-on" feel you need for editing, with a cloud fallback for when you need that extra emotional "polish."

Below is the implementation for **Kokoro (Local)** with an automatic fallback to **ElevenLabs (Cloud)**.

### 1. The Hybrid Setup (Local + Cloud)

This script will:

1. Try to read your clipboard using the **Kokoro** engine locally (Fast & Free).
2. If Kokoro fails (e.g., missing dependencies or local error), it instantly calls **ElevenLabs** (High Quality).

#### The Hybrid Script (`smart_read.py`)

```python
import pyperclip
import os
import sys

# --- CONFIGURATION ---
ELEVENLABS_API_KEY = "YOUR_API_KEY_HERE"
VOICE_ID = "JBFqnCBsd6RMkjVDRZzb" # Default: Charlie
USE_LOCAL_FIRST = True

def speak_local(text):
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
    try:
        from elevenlabs.client import ElevenLabs
        from elevenlabs import play
        
        client = ElevenLabs(api_key=ELEVENLABS_API_KEY)
        audio = client.text_to_speech.convert(
            text=text,
            voice_id=VOICE_ID,
            model_id="eleven_flash_v2_5" # Low latency model
        )
        play(audio)
        return True
    except Exception as e:
        print(f"Cloud TTS Failed: {e}")
        return False

if __name__ == "__main__":
    content = pyperclip.paste().strip()
    if not content:
        print("Clipboard empty.")
        sys.exit()

    success = False
    if USE_LOCAL_FIRST:
        success = speak_local(content)
    
    if not success:
        print("Falling back to ElevenLabs...")
        speak_cloud(content)

```

---

### 2. How to Run It Locally (Windows & Mac)

To make this "one-button" fast, follow these steps to prepare your environment:

#### Step A: Install the Engines

Open your terminal (Terminal on Mac, PowerShell on Windows) and run:

```bash
# Core requirements
pip install kokoro pyperclip sounddevice numpy elevenlabs

# Mac Users: You also need this for audio playback
brew install portaudio

# Windows Users: You need to install espeak-ng (required by Kokoro)
# Download the .msi from: https://github.com/espeak-ng/espeak-ng/releases

```

#### Step B: The "One-Button" Shortcut

Instead of opening a terminal every time, link this to your **Stream Deck** or a **Global Hotkey**:

* **Stream Deck:** Use the "System: Open" or "Website" action. Set the path to:
* `python path/to/smart_read.py`


* **Mac (Automator):** Create a "Quick Action," add "Run Shell Script," and paste: `python3 /Users/yourname/scripts/smart_read.py`. Assign it to a key in System Settings > Keyboard.
* **Windows (PowerToys):** Use "Keyboard Manager" to remap a key (like F13) to run the script.

---

### 3. Why this helps your "Memory Palace"

By having this run locally, the audio becomes an **extension of your thought process**.

* **The Emotional Pacing:** When you are in DaVinci Resolve using **Dynamic Trim**, you can hit the button, hear the line, and immediately decide if the visual cut matches the breath or the pause in the AI's delivery.
* **Humanist Approach:** You are proving that "Agentic Systems" (the script) don't have to be expensive or "black box." You own the local model; you are the architect.

**Would you like me to create a "Batch Mode" version of this script that saves the files directly into your DaVinci Resolve project folder so you don't have to import them manually?**
