# tts-mix

**AI-powered clipboard-to-speech automation for Stream Deck.** Copy any text, press a button, and hear an AI-generated analysis read aloud instantly.

## What This Does

You highlight text anywhere on your screen, press a **Stream Deck button**, and within seconds you hear an AI voice reading back a targeted analysis of that text. Each button triggers a different "thinking lens" powered by xAI Grok and fal.ai text-to-speech.

### The Pipeline (every button press)

```
Copy text (Ctrl+C)  -->  Press Stream Deck button
      |
      v
  Read clipboard
      |
      v
  Send to xAI Grok (LLM) with a specific prompt
      |  (fallback: OpenRouter / Gemini)
      v
  Convert AI response to speech via fal.ai TTS
      |  (fallback: ElevenLabs)
      v
  Play audio + save to Obsidian SecondBrain
```

### Available Stream Deck Buttons (14 pipelines)

| Button | Script | What It Does |
|--------|--------|-------------|
| Sanity Check | `sanity-check.ps1` | "Does this make sense? Any logic errors?" |
| Explain | `explain.ps1` | "Explain this in 2-3 sentences" |
| Why Important | `ask-why-important.ps1` | "Why does this matter?" |
| TLDR | `tldr.ps1` | "Summarize in one sentence" |
| ELI5 | `eli5.ps1` | "Explain like I'm 5 years old" |
| Story | `storytell.ps1` | "Turn this into a short story" |
| Devil's Advocate | `devil-advocate.ps1` | "Give the strongest counterargument" |
| Pros & Cons | `pros-cons.ps1` | "2 pros, 2 cons" |
| Action Items | `action-items.ps1` | "Extract the action items" |
| Risk Radar | `risk-radar.ps1` | "Spot risks and red flags" |
| Reframe | `reframe.ps1` | "Reframe as a positive opportunity" |
| Motivate | `motivate.ps1` | "Give a motivational take" |
| Haiku | `haiku.ps1` | "Write a haiku about this" |
| Tweet This | `tweet-this.ps1` | "Compress to a punchy tweet" |

### Stream Deck Button Setup (30 seconds per button)

1. Open Stream Deck software
2. Drag **System > Open** to a button slot
3. Configure:
   - **App/File**: `powershell.exe`
   - **Arguments**: `-ExecutionPolicy Bypass -File "C:\projects\tts-mix\5_Symbols\<script>.ps1"`
4. Choose an icon and you're done

For the simple clipboard reader (no AI analysis, just reads text aloud):
- **Arguments**: `-ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\projects\tts-mix\5_Symbols\read-clipboard-silent.ps1"`

## Architecture

All 14 pipeline scripts are thin wrappers (~35 lines each) that define a prompt and config, then call the shared engine:

```
Pipeline script (e.g. sanity-check.ps1)
    |
    |  defines $PipelineConfig + $UserPrompt
    |  dot-sources _base.ps1
    v
_base.ps1  (centralized engine, ~630 lines)
    |-- Logging       --> 7_Testing_known/logs/{pipeline}_{timestamp}.log
    |-- .env loading   --> loads API keys from .env
    |-- Stage 1        --> Read clipboard
    |-- Stage 2        --> Validate API keys
    |-- Stage 3        --> LLM call (xAI Grok -> OpenRouter fallback)
    |-- Stage 4        --> TTS (ElevenLabs -> fal.ai fallback)
    |-- Stage 5        --> Play audio
    |-- Stage 6        --> Summary + save to SecondBrain
```

### APIs Used

| Service | Purpose | Key |
|---------|---------|-----|
| xAI Grok (`grok-3-mini-fast`) | Primary LLM | `XAI_API_KEY` |
| OpenRouter (`gemini-2.0-flash-001`) | Fallback LLM | `OPENROUTER_API_KEY` |
| fal.ai (`dia-tts`) | Primary TTS | `FAL_KEY` |
| ElevenLabs (`eleven_flash_v2_5`) | Fallback TTS | `ELEVENLABS_API_KEY` |

## Quick Start

### Prerequisites

- Windows with PowerShell 5.1+
- Stream Deck hardware + software
- API keys for xAI and fal.ai (minimum)

### Setup

1. Clone the repo and create `.env`:
   ```
   XAI_API_KEY=xai-...
   FAL_KEY=...
   OPENROUTER_API_KEY=...        # optional fallback
   ELEVENLABS_API_KEY=sk_...     # optional fallback
   VOICE_ID=JBFqnCBsd6RMkjVDRZzb
   MODEL_ID=eleven_flash_v2_5
   ```

2. Test a pipeline manually:
   ```powershell
   # Copy some text to clipboard first, then:
   powershell -ExecutionPolicy Bypass -File "5_Symbols\sanity-check.ps1"
   ```

3. Wire up Stream Deck buttons (see table above)

## Documentation

| Doc | Location |
|-----|----------|
| Objectives & Key Results | [1_Real_Unknown/OKR.md](OKR.md) |
| Current Status | [1_Real_Unknown/CURRENT_STATUS.md](CURRENT_STATUS.md) |
| Mix Strategy | [1_Real_Unknown/mix-strategy.md](mix-strategy.md) |
| Environment Setup | [2_Environment/WINDOWS_SETUP.md](../2_Environment/WINDOWS_SETUP.md) |
| Stream Deck Integration | [4_Formula/STREAMDECK_INTEGRATION.md](../4_Formula/STREAMDECK_INTEGRATION.md) |
| Stream Deck Quick Start | [4_Formula/STREAMDECK_QUICKSTART.md](../4_Formula/STREAMDECK_QUICKSTART.md) |
| Troubleshooting | [6_Semblance/TROUBLESHOOTING.md](../6_Semblance/TROUBLESHOOTING.md) |

## Workspace Structure

```
1_Real_Unknown/    Objectives, OKRs, strategy, project status
2_Environment/     Setup scripts, install docs, environment config
3_Simulation/      UI examples and implementation notes
4_Formula/         Guides and how-to procedures
5_Symbols/         Source code (all pipeline scripts + _base.ps1 engine)
6_Semblance/       Error logs, troubleshooting, fix records
7_Testing_known/   Tests, validation, and debug logs
```
