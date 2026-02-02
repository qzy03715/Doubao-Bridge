@echo off
setlocal
set "PROJECT_DIR=%~dp0.."
set "ADB=%PROJECT_DIR%\tools\adb\adb.exe"

echo [Doubao Bridge] Starting scrcpy...
cd /d "C:\Users\Derpy\Desktop\scrcpy-win64-v3.3.3"
start "" scrcpy.exe -K --shortcut-mod=ralt --max-fps 165 -b 20M -w
echo [Doubao Bridge] scrcpy started.

echo [Doubao Bridge] Launching Doubao Input app...
timeout /t 2 /nobreak >nul
"%ADB%" shell am start -n com.doubao.bridge/.MainActivity 2>nul
if errorlevel 1 (
    echo [Doubao Bridge] Note: Doubao Input app not installed yet.
) else (
    echo [Doubao Bridge] Doubao Input app launched.
)
endlocal
