@echo off
echo ============================================
echo   Doubao Bridge - Start All
echo ============================================
echo.
echo [1/2] Starting scrcpy...
call "%~dp0start-scrcpy.bat"
echo.
echo [2/2] Starting AHK script...
timeout /t 2 /nobreak >nul
call "%~dp0start-ahk.bat"
echo.
echo ============================================
echo   Doubao Bridge Ready!
echo   - Alt+Space: Invoke input window
echo   - Ctrl+Enter: Send to PC
echo ============================================
echo.
pause
