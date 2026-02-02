@echo off
chcp 65001 >nul
echo ============================================
echo   Doubao Bridge - 一键停止
echo ============================================
echo.

echo [1/2] 停止 AHK 脚本...
call "%~dp0stop-ahk.bat"
echo.

echo [2/2] 停止 scrcpy...
call "%~dp0stop-scrcpy.bat"
echo.

echo ============================================
echo   Doubao Bridge 已停止。
echo ============================================
echo.
pause
