@echo off
echo [Doubao Bridge] Stopping AHK script...
taskkill /IM AutoHotkey64.exe /F 2>nul
if %errorlevel%==0 (
    echo [Doubao Bridge] AHK script stopped.
) else (
    echo [Doubao Bridge] AHK script not running.
)
