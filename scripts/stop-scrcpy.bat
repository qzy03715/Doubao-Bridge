@echo off
echo [Doubao Bridge] Stopping scrcpy...
taskkill /IM scrcpy.exe /F 2>nul
if %errorlevel%==0 (
    echo [Doubao Bridge] scrcpy stopped.
) else (
    echo [Doubao Bridge] scrcpy not running.
)
