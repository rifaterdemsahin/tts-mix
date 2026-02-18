# ElevenLabs Playback Fix — ffmpeg Not Found

**Date:** 2026-02-18  
**Status:** FIXED

## Error

When ElevenLabs successfully generated audio, playback failed because pydub requires ffmpeg/ffprobe to decode MP3 files.

### Error Log 1 — Turkish text (`*Bu kucaklaşma milyonlarca kelimeye bedeldir…`)

```
┌──────────────────────────────────────────────────────────┐
│ *Bu kucaklaşma milyonlarca kelimeye bedeldir…            │
└──────────────────────────────────────────────────────────┘
   📝 5 words, 45 chars (~0.0 min estimated)

============================================================
🟡 STARTING TTS — ElevenLabs (Primary)
   Voice: JBFqnCBsd6RMkjVDRZzb
   Model: eleven_flash_v2_5
   ⏱️  Started at 21:12:12
============================================================
C:\Python314\Lib\site-packages\elevenlabs\core\pydantic_utilities.py:13: UserWarning: Core Pydantic V1 functionality isn't compatible with Python 3.14 or greater.
  from pydantic.v1.datetime_parse import parse_date as parse_date
💾 Saved: C:\Users\Pexabo\Downloads\tts_elevenlabs_20260218_211213.mp3
C:\Python314\Lib\site-packages\pydub\utils.py:170: RuntimeWarning: Couldn't find ffmpeg or avconv - defaulting to ffmpeg, but may not work
C:\Python314\Lib\site-packages\pydub\utils.py:198: RuntimeWarning: Couldn't find ffprobe or avprobe - defaulting to ffprobe, but may not work
ElevenLabs TTS Failed: [WinError 2] The system cannot find the file specified
```

**Result:** Fell back to fal.ai (dia-tts) which worked.

### Error Log 2 — Heart emoji (`❤️`)

```
┌──────────────────────────────────────────────────────────┐
│ ❤️                                                       │
└──────────────────────────────────────────────────────────┘
   📝 1 words, 2 chars (~0.0 min estimated)

============================================================
🟡 STARTING TTS — ElevenLabs (Primary)
   Voice: JBFqnCBsd6RMkjVDRZzb
   Model: eleven_flash_v2_5
   ⏱️  Started at 21:13:50
============================================================
💾 Saved: C:\Users\Pexabo\Downloads\tts_elevenlabs_20260218_211351.mp3

🟢 SENT — Audio delivered in 5.5s

============================================================
✅ Speech completed successfully!  ⏱️ Total: 5.5s
============================================================
```

**Result:** Succeeded after fix was applied. ElevenLabs handled the emoji.

## Root Cause

`pydub` uses ffmpeg/ffprobe as external executables to decode MP3 files. ffmpeg was not installed on the system, causing `[WinError 2] The system cannot find the file specified`.

## Fix Applied

Replaced pydub-based MP3 playback in `speak_cloud()` with Windows built-in `System.Windows.Media.MediaPlayer` (WPF/PresentationCore). This plays MP3 files natively on Windows without needing ffmpeg.

### Before (broken)
```python
from pydub import AudioSegment
from pydub.playback import play as pydub_play
audio_segment = AudioSegment.from_file(str(save_path), format="mp3")
pydub_play(audio_segment)
```

### After (fixed)
```python
import subprocess
subprocess.Popen(
    ["powershell", "-WindowStyle", "Hidden", "-Command",
     f'Add-Type -AssemblyName presentationCore; '
     f'$player = New-Object System.Windows.Media.MediaPlayer; '
     f'$player.Open([Uri]"{save_path}"); '
     f'Start-Sleep -Milliseconds 500; '
     f'$player.Play(); '
     f'Start-Sleep -Milliseconds ([math]::Ceiling($player.NaturalDuration.TimeSpan.TotalMilliseconds) + 1000); '
     f'$player.Close()'],
    creationflags=0x08000000  # CREATE_NO_WINDOW
).wait()
```

## Remaining Warning (non-blocking)

```
UserWarning: Core Pydantic V1 functionality isn't compatible with Python 3.14 or greater.
```

This is a warning from the ElevenLabs SDK using Pydantic V1 on Python 3.14. It does not affect functionality.
