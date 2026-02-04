@echo off
setlocal

set "PROJECT_DIR=%~dp0.."
set "SCRCPY_DIR=%PROJECT_DIR%\tools\scrcpy"
set "ADB=%PROJECT_DIR%\tools\adb\adb.exe"

echo [Doubao Bridge] Starting scrcpy...

if not exist "%SCRCPY_DIR%\scrcpy.exe" (
    echo [ERROR] scrcpy.exe not found in: %SCRCPY_DIR%
    echo [ERROR] Please copy scrcpy files to tools\scrcpy\
    pause
    exit /b 1
)

cd /d "%SCRCPY_DIR%"
cscript //nologo scrcpy-noconsole.vbs -K --shortcut-mod=ralt --max-fps 165 -b 20M -w --window-height 720
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
