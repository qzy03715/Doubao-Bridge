# Update config.json with WiFi IP address
# Usage: powershell -File update-wifi-config.ps1 -ConfigFile "path" -PhoneIP "192.168.x.x"
param(
    [string]$ConfigFile,
    [string]$PhoneIP
)

$c = Get-Content $ConfigFile -Raw -Encoding UTF8
$c = $c -replace '"scrcpyTitle":\s*"[^"]*"', "`"scrcpyTitle`": `"${PhoneIP}:5555`""
$c = $c -replace '"ip":\s*"[^"]*"', "`"ip`": `"${PhoneIP}`""
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($ConfigFile, $c, $utf8NoBom)
