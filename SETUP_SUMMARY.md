# TTS Setup Summary - Current Status

**Date**: 2026-02-18

## What We've Built

Updated app.py with **3-tier fallback system**: Groq → ElevenLabs → Kokoro

## Current Issues Found

### 1. API Key Problems

**Groq**:
```
Error: Invalid API Key
Key provided: xai-[REDACTED]
```
- This key starts with "xai-" (suggests xAI/Grok, not Groq)
- Groq keys typically start with "gsk_"
- Get correct key from: https://console.groq.com/keys

**ElevenLabs**:
```
Error: payment_issue
Message: Your subscription has a failed or incomplete payment
```
- Need to complete payment at: https://elevenlabs.io/usage
- API key is valid but subscription inactive

### 2. Python 3.14 Incompatibility

**Kokoro**: Still blocked by Pydantic v1 issue (as expected)

---

## What Works

- ✓ **App structure** - 3-tier fallback implemented
- ✓ **Groq TTS function** - Ready, just needs valid API key
- ✓ **ElevenLabs function** - Ready, just needs active subscription
- ✓ **Kokoro function** - Needs Python 3.11/3.12
- ✓ **Stream Deck integration** - Button configuration ready
- ✓ **Clipboard to speech** - Workflow implemented

---

## To Get TTS Working - Choose One:

### Option A: Use Groq (Fastest)
1. **Get Groq API key** from https://console.groq.com/keys
   - Sign up/login
   - Create new API key (starts with "gsk_")
2. **Update .env**:
   ```
   GROQ_API_KEY=gsk_your_actual_groq_key_here
   ```
3. **Test**: `python app.py`

### Option B: Fix ElevenLabs Payment
1. **Go to** https://elevenlabs.io/usage
2. **Complete payment** for subscription
3. **Test**: `python app.py`

### Option C: Use Python 3.11/3.12 for Kokoro
1. **Install Python 3.11**: `winget install Python.Python.3.11`
2. **Create venv**: `py -3.11 -m venv venv`
3. **Activate**: `.\venv\Scripts\Activate.ps1`
4. **Install packages**: `pip install kokoro sounddevice pyperclip`
5. **Test**: `python app.py`

---

## Quick Fix: Get Groq Working

**Groq is the easiest and fastest option:**

1. Visit https://console.groq.com/
2. Sign up (free account)
3. Go to API Keys section
4. Create new key
5. Copy key (starts with `gsk_`)
6. Update `.env`:
   ```
   GROQ_API_KEY=gsk_your_key_here
   ```
7. Run: `python app.py`

**Groq Benefits**:
- Free tier available
- Very fast TTS
- No payment issues
- Works with Python 3.14
- Good voice quality

---

## Key Confusion: xAI vs Groq

The API key you provided starts with `xai-`, which is for **xAI** (formerly Twitter/X's AI company).

**xAI (Grok)**:
- Different company (Elon Musk's AI company)
- Has Grok Voice Agent API (WebSocket-based)
- No simple REST TTS API yet
- Your key starts with: `xai-` (not compatible with Groq)

**Groq**:
- Different company (AI inference company)
- Has simple REST TTS API
- Keys start with `gsk_`
- What our app is configured for

You have two options:
1. **Get Groq API key** (recommended - simpler TTS API)
2. **Or** I can update the app to use xAI Grok Voice Agent (more complex WebSocket API)

---

## Files Created/Updated

| File | Status | Purpose |
|------|--------|---------|
| app.py | Updated | 3-tier TTS (Groq→ElevenLabs→Kokoro) |
| .env | Updated | Has xAI key (need Groq key) |
| .gitignore | Created | Protects .env from git |
| .env.sample | Needs update | Add Groq config |
| test_elevenlabs.py | Created | Tests ElevenLabs API |
| STREAMDECK_SETUP.md | Created | Stream Deck guide |

---

## Next Steps (Pick One Path)

### Path 1: Quick Win with Groq (Recommended)
```powershell
# 1. Get Groq API key from console.groq.com
# 2. Update .env file
GROQ_API_KEY=gsk_your_actual_key

# 3. Test
python app.py
```
**Time**: 5 minutes
**Result**: Working TTS with natural voice

### Path 2: Fix ElevenLabs
```powershell
# 1. Go to elevenlabs.io/usage
# 2. Complete payment
# 3. Test
python app.py
```
**Time**: Depends on payment processing
**Result**: High-quality natural voice with emotions

### Path 3: Use xAI Grok Voice Agent
```
Requires more complex implementation (WebSocket API)
Not a simple REST endpoint
Let me know if you want this
```

---

## Test Commands

**Test with text from clipboard**:
```powershell
echo "Hello from TTS" | clip
python app.py
```

**Quick Groq test** (once you have key):
```python
from groq import Groq
client = Groq(api_key="your_key")
response = client.audio.speech.create(
    model="canopylabs/orpheus-v1-english",
    voice="troy",
    input="Hello World"
)
# Should return audio stream
```

---

## Recommended Action

**Get Groq working first** - it's the fastest path to working TTS:

1. Sign up at https://console.groq.com/
2. Get API key (free tier available)
3. Update GROQ_API_KEY in .env
4. Run `python app.py`

Then you'll have working natural TTS from your Stream Deck button!

---

**Current Priority**: Get valid Groq API key to unlock TTS functionality.
