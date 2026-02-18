# Test: sanity-check.ps1 pipeline
# Sets clipboard to a test string and runs the script end-to-end.
# Terminal stays open so you can inspect output.

Write-Host ""
Write-Host ("=" * 60) -ForegroundColor DarkCyan
Write-Host "  🧪  TEST: sanity-check.ps1" -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor DarkCyan

# ─── Set clipboard to test text ───────────────────────────
$TestText = "The Earth revolves around the Sun once every 365.25 days. Therefore, a year on Earth is exactly 365 days and we never need leap years."
Set-Clipboard -Value $TestText

Write-Host ""
Write-Host "  📋  Clipboard set to test text:" -ForegroundColor Yellow
Write-Host "       $TestText" -ForegroundColor DarkYellow
Write-Host ""
Write-Host "  ▶️   Launching sanity-check.ps1..." -ForegroundColor Green
Write-Host ""

# ─── Run the script ───────────────────────────────────────
$ScriptPath = Join-Path (Split-Path -Parent $PSScriptRoot) "5_Symbols\sanity-check.ps1"

if (-not (Test-Path $ScriptPath)) {
    Write-Host "  ❌  Script not found: $ScriptPath" -ForegroundColor Red
    Write-Host "`nPress Enter to close..." -ForegroundColor DarkGray
    Read-Host
    exit 1
}

& powershell.exe -ExecutionPolicy Bypass -File $ScriptPath

Write-Host ""
Write-Host ("=" * 60) -ForegroundColor DarkCyan
Write-Host "  🏁  TEST COMPLETE" -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor DarkCyan
Write-Host ""
Write-Host "Press Enter to close..." -ForegroundColor DarkGray
Read-Host
