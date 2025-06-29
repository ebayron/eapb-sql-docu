# Generate List

Get-WMIObject Win32_Product | Where Name -Like "*SQL*2019*" | Format-Table IdentifyingNumber, Name, Version  -AutoSize

# Uninstall

msiexec /x {...]