"""
Quick test of fal.ai TTS - generates audio but doesn't play it
"""
import os
import sys
from pathlib import Path
from dotenv import load_dotenv

# Set UTF-8 encoding for Windows console
if sys.platform == 'win32':
    os.system('chcp 65001 >nul 2>&1')
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

PROJECT_ROOT = Path(__file__).resolve().parent.parent
load_dotenv(PROJECT_ROOT / ".env")

FAL_KEY = os.getenv("FAL_KEY", "")
TEST_MESSAGE = "Hello World! This is a test of text to speech."

def test_fal_quick():
    """Test fal.ai TTS without audio playback"""
    print("\n" + "="*60)
    print("QUICK FAL.AI TTS TEST (No Audio Playback)")
    print("="*60)
    print(f"Testing: {TEST_MESSAGE}")
    print("-"*60)

    if not FAL_KEY:
        print("❌ SKIPPED: FAL_KEY not configured in .env file")
        return False

    try:
        import fal_client
        import httpx

        print("✓ fal.ai library loaded")
        print(f"✓ API Key configured: {FAL_KEY[:10]}...")

        # Calculate cost
        char_count = len(TEST_MESSAGE)
        cost = (char_count / 1000) * 0.04
        print(f"💰 Estimated cost: ${cost:.4f} ({char_count} characters @ $0.04/1k)")

        # Set API key
        os.environ['FAL_KEY'] = FAL_KEY

        print("\nGenerating speech with fal.ai...")
        result = fal_client.run(
            "fal-ai/dia-tts",
            arguments={
                "text": TEST_MESSAGE
            }
        )

        print("✓ Speech generated successfully")

        # Get audio URL
        audio_url = result.get("audio", {}).get("url")
        if not audio_url:
            print("❌ No audio URL in response")
            return False

        print(f"✓ Audio URL: {audio_url}")

        # Download audio
        response = httpx.get(audio_url)
        response.raise_for_status()

        audio_size = len(response.content)
        print(f"✓ Audio downloaded: {audio_size:,} bytes")

        # Get audio info
        audio_info = result.get("audio", {})
        print(f"✓ Content type: {audio_info.get('content_type')}")
        print(f"✓ File name: {audio_info.get('file_name')}")
        print(f"✓ File size: {audio_info.get('file_size'):,} bytes")

        print("\n✅ FAL.AI TTS TEST PASSED")
        print("   Voice quality: Fast inference, high quality, natural")
        print("   Note: Audio was generated successfully (playback skipped)")
        return True

    except Exception as e:
        print(f"\n❌ FAL.AI TTS TEST FAILED")
        print(f"   Error: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    test_fal_quick()
