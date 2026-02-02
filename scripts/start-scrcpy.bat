@echo off
chcp 65001 >nul
echo [Doubao Bridge] 正在启动 scrcpy...

cd /d "C:\Users\Derpy\Desktop\scrcpy-win64-v3.3.3"
start "" scrcpy.exe -K --shortcut-mod=ralt --max-fps 165 -b 20M -w

echo [Doubao Bridge] scrcpy 已启动。
