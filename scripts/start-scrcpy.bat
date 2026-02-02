@echo off
echo [Doubao Bridge] Starting scrcpy...
cd /d "C:\Users\Derpy\Desktop\scrcpy-win64-v3.3.3"
start "" scrcpy.exe -K --shortcut-mod=ralt --max-fps 165 -b 20M -w
echo [Doubao Bridge] scrcpy started.
