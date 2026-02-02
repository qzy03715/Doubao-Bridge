@echo off
setlocal

set "PROJECT_DIR=%~dp0.."
set "JAVA_HOME=%PROJECT_DIR%\tools\jdk\jdk-17.0.17+10"
set "ANDROID_HOME=%PROJECT_DIR%\tools\android-sdk"
set "PATH=%JAVA_HOME%\bin;%PATH%"

echo ============================================
echo   Android SDK Setup
echo ============================================
echo.
echo JAVA_HOME: %JAVA_HOME%
echo ANDROID_HOME: %ANDROID_HOME%
echo.

echo [1/3] Accepting all licenses...
for /f "tokens=*" %%i in ('echo y^&echo y^&echo y^&echo y^&echo y^&echo y^&echo y^&echo y') do (
    echo %%i
)
(echo y & echo y & echo y & echo y & echo y & echo y & echo y & echo y) | "%ANDROID_HOME%\cmdline-tools\latest\bin\sdkmanager.bat" --sdk_root="%ANDROID_HOME%" --licenses

echo.
echo [2/3] Installing platforms;android-34...
(echo y) | "%ANDROID_HOME%\cmdline-tools\latest\bin\sdkmanager.bat" --sdk_root="%ANDROID_HOME%" "platforms;android-34"

echo.
echo [3/3] Installing build-tools;34.0.0...
(echo y) | "%ANDROID_HOME%\cmdline-tools\latest\bin\sdkmanager.bat" --sdk_root="%ANDROID_HOME%" "build-tools;34.0.0"

echo.
echo ============================================
echo   Android SDK Setup Complete!
echo ============================================
echo.

endlocal
