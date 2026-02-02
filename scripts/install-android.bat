@echo off
setlocal

set "PROJECT_DIR=%~dp0.."
set "ADB=%PROJECT_DIR%\tools\adb\adb.exe"
set "APK_PATH=%PROJECT_DIR%\src\android\app\build\outputs\apk\debug\app-debug.apk"

echo ============================================
echo   Doubao Input - Install to Device
echo ============================================
echo.

if not exist "%APK_PATH%" (
    echo [ERROR] APK not found: %APK_PATH%
    echo [ERROR] Please run build-android.bat first.
    pause
    exit /b 1
)

echo [INFO] Checking device connection...
"%ADB%" devices

echo.
echo [INFO] Installing APK...
"%ADB%" install -r "%APK_PATH%"

if errorlevel 1 (
    echo.
    echo [ERROR] Installation failed!
    pause
    exit /b 1
)

echo.
echo [INFO] Launching app...
"%ADB%" shell am start -n com.doubao.bridge/.MainActivity

echo.
echo ============================================
echo   Installation successful!
echo   App launched on device.
echo ============================================
echo.

endlocal
