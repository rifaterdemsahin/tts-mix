# Objectives and Key Results (OKRs)

**Project**: tts-mix — AI-Powered Clipboard-to-Speech Automation
**Date**: 2026-02-18

---

## Objective 1: Instant AI audio feedback from any text on screen

**Why**: Reduce friction between reading and understanding. Instead of context-switching to ChatGPT or reading walls of text, hear a targeted AI analysis by pressing one button.

| # | Key Result | Status |
|---|-----------|--------|
| 1.1 | 14 pipeline scripts wired to Stream Deck, each applying a different AI lens | Done |
| 1.2 | End-to-end latency under 10 seconds (clipboard to audio playback) | Done |
| 1.3 | Every button press produces a spoken response or a clear on-screen error | Done |
| 1.4 | All pipelines use centralized `_base.ps1` engine (zero code duplication) | Done |

---

## Objective 2: Resilient multi-provider architecture with automatic fallback

**Why**: No single API should be a single point of failure. If xAI is down, OpenRouter takes over. If ElevenLabs payment lapses, fal.ai speaks instead.

| # | Key Result | Status |
|---|-----------|--------|
| 2.1 | LLM tier: xAI Grok (primary) with OpenRouter/Gemini fallback | Done |
| 2.2 | TTS tier: ElevenLabs (primary) with fal.ai dia-tts fallback | Done |
| 2.3 | Fallback triggers automatically on HTTP error — no user action needed | Done |
| 2.4 | Provider used is logged per run for cost/reliability tracking | Done |

---

## Objective 3: Full observability via centralized debug logging

**Why**: When a pipeline fails silently, there's no way to debug. Every run must leave a trace.

| # | Key Result | Status |
|---|-----------|--------|
| 3.1 | Every pipeline run writes a timestamped log to `7_Testing_known/logs/` | Done |
| 3.2 | Logs include: API calls, response times, token counts, errors, saved files | Done |
| 3.3 | Errors display on screen AND log to file (dual output) | Done |
| 3.4 | Global error trap catches unhandled exceptions and keeps terminal open | Done |

---

## Objective 4: Knowledge capture — every AI response saved to Obsidian

**Why**: AI insights are ephemeral if only heard once. Saving to SecondBrain makes them searchable and reusable.

| # | Key Result | Status |
|---|-----------|--------|
| 4.1 | Each pipeline saves a markdown file to SecondBrain (`F:\secondbrain_v4\`) | Done |
| 4.2 | Each pipeline saves the generated audio file to SecondBrain | Done |
| 4.3 | Files named with pipeline prefix + timestamp for easy sorting | Done |

---

## Objective 5: One-button setup for new Stream Deck buttons

**Why**: Adding a new "thinking lens" should take minutes, not hours.

| # | Key Result | Status |
|---|-----------|--------|
| 5.1 | Adding a new pipeline = one ~35-line PS1 file with prompt + config | Done |
| 5.2 | Stream Deck button config is 3 fields (app, arguments, icon) | Done |
| 5.3 | Documentation covers setup end-to-end | Done |

---

## Known Blockers / Future Work

| Item | Status | Notes |
|------|--------|-------|
| Kokoro local TTS | Blocked | Python 3.14 incompatible with Pydantic v1 (needed by spacy/misaki). Requires Python 3.11 or 3.12. |
| ElevenLabs subscription | Expired | 401 payment error. fal.ai is the active TTS engine. |
| espeak-ng | Not installed | Required for Kokoro. Not needed while using cloud TTS. |

---

## Pipeline Inventory (14 active)

| Pipeline | Script | Lens | Temp |
|----------|--------|------|------|
| Sanity Check | `sanity-check.ps1` | Logic & error check | 0.5 |
| Explain | `explain.ps1` | Clear explanation | 0.7 |
| Why Important | `ask-why-important.ps1` | Significance analysis | 0.7 |
| TLDR | `tldr.ps1` | One-sentence summary | 0.3 |
| ELI5 | `eli5.ps1` | Simple analogy | 0.7 |
| Story | `storytell.ps1` | Narrative retelling | 0.9 |
| Devil's Advocate | `devil-advocate.ps1` | Counterargument | 0.8 |
| Pros & Cons | `pros-cons.ps1` | Balanced analysis | 0.5 |
| Action Items | `action-items.ps1` | Task extraction | 0.3 |
| Risk Radar | `risk-radar.ps1` | Risk identification | 0.5 |
| Reframe | `reframe.ps1` | Positive reframe | 0.8 |
| Motivate | `motivate.ps1` | Motivational take | 0.9 |
| Haiku | `haiku.ps1` | Poetic distillation | 0.9 |
| Tweet This | `tweet-this.ps1` | Social media compression | 0.9 |
