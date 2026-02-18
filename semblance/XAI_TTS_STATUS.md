# xAI TTS Status Report

**Date**: 2026-02-18
**API Key**: xai-[REDACTED]

## Summary

**xAI does NOT currently offer a simple REST API for Text-to-Speech (TTS).**

The API key you have is valid for xAI's services, but cannot be used for the simple clipboard-to-speech workflow in this project.

## What xAI Offers

### Currently Available (December 2025 - Present)

1. **Grok Voice Agent API** (WebSocket-based)
   - Endpoint: `wss://api.x.ai/v1/realtime`
   - Real-time bidirectional voice conversations
   - Pricing: $0.05/minute
   - Use cases: Voice assistants, phone agents, IVR systems
   - 5 voice personalities: Ara, Rex, Sal, Eve, Leo
   - 100+ languages supported
   - Time-to-first-audio: <1 second

2. **Chat/Text Completion API** (REST)
   - Endpoint: `https://api.x.ai/v1`
   - Compatible with OpenAI API format
   - Models: grok-beta, grok-vision-beta
   - Use cases: Text generation, chat completion

### Coming Soon

xAI has announced they will launch **standalone TTS and STT APIs** in the coming weeks, which will provide:
- Dedicated text-to-speech endpoints (similar to OpenAI's `/audio/speech`)
- Dedicated speech-to-text endpoints
- Improved pronunciation and latency

## Why xAI Can't Replace Groq in Current Setup

### Current App Architecture

Our `app.py` uses a simple workflow:
```python
1. Read text from clipboard
2. Send to TTS API (single HTTP request)
3. Receive audio file
4. Play audio locally
```

### xAI Voice Agent API Requirements

The Voice Agent API requires:
```python
1. WebSocket connection to wss://api.x.ai/v1/realtime
2. Authentication handshake
3. Send configuration (model, voice, audio format)
4. Stream text input
5. Receive streaming audio chunks
6. Real-time audio playback during streaming
7. Maintain connection state
```

This is fundamentally different architecture - designed for **conversational AI** not **simple TTS**.

## Comparison: Simple TTS vs Voice Agent

| Feature | Simple TTS (Groq/ElevenLabs) | xAI Voice Agent |
|---------|------------------------------|-----------------|
| Protocol | REST (HTTP) | WebSocket |
| Connection | One request per speech | Persistent connection |
| Complexity | 5-10 lines of code | 100+ lines of code |
| Use Case | Text → Audio conversion | Interactive conversations |
| Latency | 1-3 seconds total | <1s to first audio, then streaming |
| Best For | Clipboard reader, notifications | Phone calls, chatbots |

## What You Can Do Now

### Option A: Wait for xAI Standalone TTS API (Recommended if you prefer xAI)
- Expected: "Next few weeks" from December 2025
- Will provide simple REST endpoint like Groq/OpenAI
- Your xAI API key will likely work with it

### Option B: Get Groq API Key (Immediate Solution)
- URL: https://console.groq.com/keys
- Free tier available
- Keys start with `gsk_`
- Simple REST API (works with current code)
- Very fast inference

### Option C: Fix ElevenLabs Payment
- URL: https://elevenlabs.io/usage
- Your API key is valid
- Just needs payment completion
- Highest quality natural voice

### Option D: Implement xAI Voice Agent (Complex)
- Requires major code rewrite
- WebSocket client implementation
- Streaming audio handling
- Not recommended for simple clipboard-to-speech use case

## Implementation Comparison

### Simple TTS (Current Code - 15 lines)
```python
from groq import Groq
client = Groq(api_key=api_key)

response = client.audio.speech.create(
    model="canopylabs/orpheus-v1-english",
    voice="troy",
    input=text
)

# Save and play audio
audio_buffer = BytesIO()
for chunk in response.iter_bytes():
    audio_buffer.write(chunk)
sd.play(audio_data, sample_rate)
```

### xAI Voice Agent (Required - 100+ lines)
```python
import asyncio
import websockets
import json
import base64

async def text_to_speech(text, api_key):
    uri = "wss://api.x.ai/v1/realtime"

    async with websockets.connect(uri) as websocket:
        # 1. Send authentication
        await websocket.send(json.dumps({
            "type": "session.update",
            "session": {
                "authorization": f"Bearer {api_key}",
                "modalities": ["text", "audio"],
                "voice": "ara"
            }
        }))

        # 2. Send text input
        await websocket.send(json.dumps({
            "type": "conversation.item.create",
            "item": {
                "type": "message",
                "role": "user",
                "content": [{"type": "input_text", "text": text}]
            }
        }))

        # 3. Request audio generation
        await websocket.send(json.dumps({
            "type": "response.create"
        }))

        # 4. Receive and handle streaming audio chunks
        audio_chunks = []
        async for message in websocket:
            data = json.loads(message)
            if data["type"] == "response.audio.delta":
                # Decode base64 audio chunk
                chunk = base64.b64decode(data["delta"])
                audio_chunks.append(chunk)
                # Stream to audio device in real-time
            elif data["type"] == "response.done":
                break

        # 5. Play complete audio
        # ... additional audio handling code ...

# Run async
asyncio.run(text_to_speech("Hello World", api_key))
```

## Recommendation

**Use Groq for now**, then switch to xAI's standalone TTS API when it launches.

Why Groq:
1. Free tier available
2. Works with current code (zero changes needed except API key)
3. Very fast inference (competitive with xAI)
4. Simple REST API
5. Good voice quality

Your xAI key is valuable - save it for when their standalone TTS API launches or for conversational AI use cases.

## Test Results

When attempting to use xAI key with Groq API:
```
❌ FAILED
Error: Invalid API Key (401)
Reason: xAI keys (start with "xai-") are incompatible with Groq API (requires "gsk-")
```

This is expected - they are different companies with different API systems.

## References

- xAI Voice Agent API: https://docs.x.ai/docs/guides/voice/agent
- xAI API Reference: https://docs.x.ai/docs/api-reference
- Groq TTS Docs: https://console.groq.com/docs/text-to-speech
- xAI Announcement: https://x.ai/news/grok-voice-agent-api
