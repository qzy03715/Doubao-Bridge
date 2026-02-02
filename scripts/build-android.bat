@echo off
setlocal

set "PROJECT_DIR=%~dp0.."
set "ANDROID_DIR=%PROJECT_DIR%\src\android"
set "JAVA_HOME=%PROJECT_DIR%\tools\jdk\jdk-17.0.17+10"
set "ANDROID_HOME=%PROJECT_DIR%\tools\android-sdk"
set "PATH=%JAVA_HOME%\bin;%PATH%"

echo ============================================
echo   Doubao Input - Build Android APK
echo ============================================
echo.

echo [INFO] JAVA_HOME: %JAVA_HOME%
echo [INFO] ANDROID_HOME: %ANDROID_HOME%
echo [INFO] ANDROID_DIR: %ANDROID_DIR%
echo.
echo [INFO] Building debug APK...
echo.

pushd "%ANDROID_DIR%"
call "%ANDROID_DIR%\gradlew.bat" assembleDebug --no-daemon
popd

if errorlevel 1 (
    echo.
    echo [ERROR] Build failed!
    pause
    exit /b 1
)

echo.
echo ============================================
echo   Build successful!
echo   APK: src\android\app\build\outputs\apk\debug\app-debug.apk
echo ============================================
echo.

endlocal
