@echo off
echo [Doubao Bridge] Starting AHK script...
set "AHK_EXE=%~dp0..\tools\ahk\AutoHotkey64.exe"
set "AHK_SCRIPT=%~dp0..\src\ahk\doubao-bridge.ahk"
start "" "%AHK_EXE%" "%AHK_SCRIPT%"
echo [Doubao Bridge] AHK script started.
echo [Doubao Bridge] Hotkeys: Alt+Space to invoke, Ctrl+Enter to send
