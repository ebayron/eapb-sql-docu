Get-Service -name '*TELEMETRY*' | Select-Object -property name, DisplayName, Status, starttype | Format-Table -AutoSize
Get-Service -name '*TELEMETRY*' | Where-Object {$_.StartType -ne "Disabled"} | Set-Service -StartupType Disabled
Get-Service -name '*TELEMETRY*' | Where-Object {$_.StartType -ne "Stopped"} | Stop-Service
Get-Service -name '*TELEMETRY*' | Select-Object -property name, DisplayName, Status, starttype | Format-Table -AutoSize