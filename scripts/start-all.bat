@echo off
chcp 65001 >nul
echo ============================================
echo   Doubao Bridge - 一键启动
echo ============================================
echo.

echo [1/2] 启动 scrcpy...
call "%~dp0start-scrcpy.bat"
echo.

echo [2/2] 启动 AHK 脚本...
timeout /t 2 /nobreak >nul
call "%~dp0start-ahk.bat"
echo.

echo ============================================
echo   Doubao Bridge 已就绪！
echo   - Alt+Space: 唤起输入窗口
echo   - Ctrl+Enter: 上屏到 PC
echo ============================================
echo.
pause
