@echo off
chcp 65001 >nul
echo [Doubao Bridge] 正在启动 AHK 脚本...

set "AHK_EXE=%~dp0..\tools\ahk\AutoHotkey64.exe"
set "AHK_SCRIPT=%~dp0..\src\ahk\doubao-bridge.ahk"

start "" "%AHK_EXE%" "%AHK_SCRIPT%"

echo [Doubao Bridge] AHK 脚本已启动。
echo [Doubao Bridge] 快捷键: Alt+Space 唤起 | Ctrl+Enter 上屏
