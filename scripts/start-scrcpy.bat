@echo off
setlocal

set "PROJECT_DIR=%~dp0.."
set "SCRCPY_DIR=%PROJECT_DIR%\tools\scrcpy"
set "ADB=%PROJECT_DIR%\tools\adb\adb.exe"
set "CONFIG_FILE=%PROJECT_DIR%\src\ahk\config.json"

echo [Doubao Bridge] Starting scrcpy...

if not exist "%SCRCPY_DIR%\scrcpy.exe" (
    echo [ERROR] scrcpy.exe not found in: %SCRCPY_DIR%
    echo [ERROR] Please copy scrcpy files to tools\scrcpy\
    pause
    exit /b 1
)

:: Read device.ip from config.json
set "DEVICE_IP="
for /f "delims=" %%i in ('powershell -NoProfile -Command "(Get-Content '%CONFIG_FILE%' | ConvertFrom-Json).device.ip"') do set "DEVICE_IP=%%i"

:: If IP is configured, connect via WiFi
if not "%DEVICE_IP%"=="" (
    echo [Doubao Bridge] WiFi mode - connecting to %DEVICE_IP%:5555...
    "%ADB%" connect %DEVICE_IP%:5555
    timeout /t 2 /nobreak >nul
    echo [Doubao Bridge] WiFi connection established.
) else (
    echo [Doubao Bridge] USB mode - using wired connection.
)

cd /d "%SCRCPY_DIR%"
cscript //nologo scrcpy-noconsole.vbs -K --shortcut-mod=ralt -w --window-height 720
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
