@echo off
setlocal

set "PROJECT_DIR=%~dp0.."
set "ADB=%PROJECT_DIR%\tools\adb\adb.exe"
set "CONFIG_FILE=%PROJECT_DIR%\src\ahk\config.json"

echo [Doubao Bridge] Stopping scrcpy...
taskkill /IM scrcpy.exe /F 2>nul
if %errorlevel%==0 (
    echo [Doubao Bridge] scrcpy stopped.
) else (
    echo [Doubao Bridge] scrcpy not running.
)

:: Disconnect WiFi adb if IP is configured
set "DEVICE_IP="
for /f "delims=" %%i in ('powershell -NoProfile -Command "(Get-Content '%CONFIG_FILE%' | ConvertFrom-Json).device.ip"') do set "DEVICE_IP=%%i"

if not "%DEVICE_IP%"=="" (
    echo [Doubao Bridge] Disconnecting WiFi adb (%DEVICE_IP%:5555)...
    "%ADB%" disconnect %DEVICE_IP%:5555 >nul 2>&1
    echo [Doubao Bridge] WiFi adb disconnected.
)

endlocal
