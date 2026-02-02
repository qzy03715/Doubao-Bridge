@echo off
chcp 65001 >nul
echo [Doubao Bridge] 正在停止 AHK 脚本...

taskkill /IM AutoHotkey64.exe /F 2>nul
if %errorlevel%==0 (
    echo [Doubao Bridge] AHK 脚本已停止。
) else (
    echo [Doubao Bridge] AHK 脚本未在运行。
)
