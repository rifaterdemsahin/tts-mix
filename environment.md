# Environment Setup

## Kokoro TTS on Windows

I think you mean **Kokoro TTS** (not "Cocoro") — an open-weight 82M parameter TTS model. Here are your options for Windows:

---

### Option 1: Portable (Easiest — No Python Required)

The [Kokoro-TTS-Portable](https://github.com/DrStr4Nge147/Kokoro-TTS-Portable) package is self-contained and works on any Windows PC.

1. Download the release from the GitHub page
2. Extract the zip
3. Run the included `.bat` launcher
4. No Python, no pip, no global installs needed
5. Auto-detects CUDA if you have an NVIDIA GPU

---

### Option 2: WebUI (Gradio Interface)

```cmd
git clone https://github.com/NeuralFalconYT/Kokoro-82M-WebUI.git
cd Kokoro-82M-WebUI
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
python app.py
```

Then open `http://localhost:7860` in your browser.

---

### Option 3: CLI via pip

```cmd
pip install git+https://github.com/nazdridoy/kokoro-tts
```

You also need these two model files in your working directory:
- `kokoro-v1.0.onnx`
- `voices-v1.0.bin`

Both can be downloaded from [Hugging Face (hexgrad/Kokoro-82M)](https://huggingface.co/hexgrad/Kokoro-82M).

Then run:
```cmd
kokoro-tts "Hello world" -v af_heart -o output.wav
```

---

### Prerequisites (for Options 2 & 3)

- Python 3.10+ — [python.org](https://python.org)
- Git — [git-scm.com](https://git-scm.com)
- (Optional) CUDA for GPU acceleration

---

**Recommendation:** Start with Option 1 (Portable) if you want the fastest setup, or Option 2 (WebUI) if you want a nice browser interface.

### Sources

- [Kokoro-TTS-Portable (GitHub)](https://github.com/DrStr4Nge147/Kokoro-TTS-Portable)
- [Kokoro-TTS-Local (GitHub)](https://github.com/PierrunoYT/Kokoro-TTS-Local)
- [Kokoro CLI Tool (GitHub)](https://github.com/nazdridoy/kokoro-tts)
- [Step-by-step tutorial (aleksandarhaber.com)](https://aleksandarhaber.com/kokoro-82m-install-and-run-locally-fast-small-and-free-text-to-speech-tts-ai-model-kokoro-82m/)
- [WebUI install guide (sonusahani.com)](https://sonusahani.com/blogs/kokoro-tts-webui-install-locally)
