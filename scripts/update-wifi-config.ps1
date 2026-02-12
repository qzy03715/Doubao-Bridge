# Update config.json with WiFi IP address
# Usage: powershell -File update-wifi-config.ps1 -ConfigFile "path" -PhoneIP "192.168.x.x"
# Note: Only updates device.ip. scrcpyTitle stays unchanged because scrcpy
#       always uses the device model name as window title regardless of connection method.
param(
    [string]$ConfigFile,
    [string]$PhoneIP
)

$c = Get-Content $ConfigFile -Raw -Encoding UTF8
$c = $c -replace '"ip":\s*"[^"]*"', "`"ip`": `"${PhoneIP}`""
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($ConfigFile, $c, $utf8NoBom)
