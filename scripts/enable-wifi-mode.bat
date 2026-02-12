@echo off
setlocal enabledelayedexpansion

echo ============================================
echo   Doubao Bridge - Enable Wi-Fi Mode
echo ============================================
echo.
echo [INFO] This script enables wireless adb mode.
echo [INFO] Make sure your phone is connected via USB.
echo.

set "PROJECT_DIR=%~dp0.."
set "ADB=%PROJECT_DIR%\tools\adb\adb.exe"
set "CONFIG_FILE=%PROJECT_DIR%\src\ahk\config.json"

:: Step 1: Check adb device
echo [1/4] Checking USB device connection...
"%ADB%" devices | findstr /R /C:"device$" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] No USB device found!
    echo [ERROR] Please connect your phone via USB and enable USB debugging.
    pause
    exit /b 1
)
echo [OK] USB device detected.
echo.

:: Step 2: Get phone WiFi IP (BEFORE tcpip, while USB is stable)
echo [2/4] Detecting phone WiFi IP address...
set "PHONE_IP="
set "TMPFILE=%TEMP%\doubao_wifi_ip.tmp"
"%ADB%" shell ip -f inet addr show wlan0 > "!TMPFILE!" 2>nul

if not exist "!TMPFILE!" (
    echo [ERROR] Could not detect WiFi IP!
    echo [ERROR] Make sure your phone is connected to WiFi.
    pause
    exit /b 1
)

:: Parse IP from "inet 192.168.x.x/24 ..." format
for /f "tokens=2" %%a in ('findstr "inet " "!TMPFILE!"') do set "IP_WITH_MASK=%%a"
del "!TMPFILE!" 2>nul

if not defined IP_WITH_MASK (
    echo [ERROR] Could not detect WiFi IP!
    echo [ERROR] Make sure your phone is connected to WiFi.
    pause
    exit /b 1
)
for /f "tokens=1 delims=/" %%a in ("!IP_WITH_MASK!") do set "PHONE_IP=%%a"

if not defined PHONE_IP (
    echo [ERROR] Failed to parse IP address!
    pause
    exit /b 1
)
echo [OK] Phone WiFi IP: !PHONE_IP!
echo.

:: Step 3: Enable TCP/IP mode (after IP is obtained)
echo [3/4] Enabling wireless adb mode (tcpip 5555)...
"%ADB%" tcpip 5555 >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Failed to enable tcpip mode!
    pause
    exit /b 1
)
echo [OK] Wireless adb mode enabled on port 5555.
echo.

:: Step 4: Update config.json
echo [4/4] Updating config.json...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0update-wifi-config.ps1" -ConfigFile "!CONFIG_FILE!" -PhoneIP "!PHONE_IP!"

if errorlevel 1 (
    echo [ERROR] Failed to update config.json!
    pause
    exit /b 1
)
echo [OK] config.json updated successfully.

echo.
echo ============================================
echo   Wi-Fi Mode Enabled Successfully!
echo ============================================
echo.
echo   Phone IP : !PHONE_IP!
echo   ADB Port : 5555
echo   Title    : !PHONE_IP!:5555
echo.
echo   You can now unplug the USB cable.
echo   Use start-wifi.bat to launch Doubao Bridge.
echo.
echo   NOTE: This setting persists until phone reboot.
echo         After reboot, run this script again.
echo ============================================
echo.
pause
endlocal
