@echo off
chcp 65001 >nul
echo [Doubao Bridge] 正在停止 scrcpy...

taskkill /IM scrcpy.exe /F 2>nul
if %errorlevel%==0 (
    echo [Doubao Bridge] scrcpy 已停止。
) else (
    echo [Doubao Bridge] scrcpy 未在运行。
)
