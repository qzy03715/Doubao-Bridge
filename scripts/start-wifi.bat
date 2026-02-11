@echo off
powershell -WindowStyle Minimized -Command "& '%~dp0start-scrcpy.bat'; Start-Sleep -Seconds 3; & '%~dp0start-ahk.bat'"
