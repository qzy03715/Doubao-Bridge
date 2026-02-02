@echo off
echo ============================================
echo   Doubao Bridge - Stop All
echo ============================================
echo.
echo [1/2] Stopping AHK script...
call "%~dp0stop-ahk.bat"
echo.
echo [2/2] Stopping scrcpy...
call "%~dp0stop-scrcpy.bat"
echo.
echo ============================================
echo   Doubao Bridge Stopped.
echo ============================================
echo.
pause
