cls

# Declare Backup Path and Drive
$path = 'S:\SQL_BACKUPS';
$drive = Get-Volume -DriveLetter $path.Substring(0, 1)

# Display files for deletion
Write-Host "These are the backup files that are older than two weeks." -ForegroundColor Yellow -BackgroundColor Green;

# Display only backup files older than two weeks
$FileList =
Get-ChildItem -Path $path -Recurse |
Where-Object {($_.lastwritetime -lt (Get-Date).AddHours(-336)) -and ($_.Extension -eq '.bak' -or $_.Extension -eq '.trn' -or $_.Extension -eq '.abf')} |
Select-Object name, lastwritetime, @{Name = "Size MB"; Expression = {[Math]::Round($_.Length / 1MB, 1)}}, DirectoryName;

# Display and sort list
$FileList | Sort-Object -Property LastWriteTime | Format-Table;

# Get the total file size to be deleted
$SizetobeDeletedMB = $FileList | Measure-Object -Property "Size MB" -Sum

# Display
Write-Host "Disk usage details" -ForegroundColor Yellow -BackgroundColor Green;

# Get Disk details
$TotalSizeGB = [Math]::Round($drive.Size / 1GB, 1)
$SpaceUsedGB = [Math]::Round(($drive.Size - $drive.SizeRemaining) / 1GB, 1)
$FreeSpaceGB = [Math]::Round($drive.SizeRemaining / 1GB, 1)
$PercentFree = [Math]::Round(($drive.SizeRemaining / $drive.Size) * 100, 7)
$SizetobeDeletedGB = [Math]::Round($SizetobeDeletedMB.Sum / 1024, 2)
$PercentFreeAfterDelete = [Math]::Round((($drive.SizeRemaining+($SizetobeDeletedGB*1024)) / $drive.Size) * 100, 7)

# Show Disk details
$DiskUsage = [ordered]@{"Total Size (GB)" = $TotalSizeGB; "Space Used (GB)" = $SpaceUsedGB; "Free Space (GB)" = $FreeSpaceGB; "% Free" = $PercentFree; "Size to be Deleted (GB)" = $SizetobeDeletedGB; "% Free after Delete" = $PercentFreeAfterDelete}
$DiskUsage2 = New-Object PSObject -Property $DiskUsage
$DiskUsage2

# Confirm deletion
if ($SizetobeDeletedGB -gt 0) {
    $confirmation = Read-Host "Do you want to proceed deleting these files?"
    if ($confirmation -eq 'Y') {
        Get-ChildItem -Path $path -Recurse |
        Where-Object {($_.lastwritetime -lt (Get-Date).AddHours(-336)) -and ($_.Extension -eq '.bak' -or $_.Extension -eq '.trn' -or $_.Extension -eq '.abf')} |
        Remove-Item -Force
    }
}
else {
    Write-Host "Nothing to delete!" -ForegroundColor Yellow -BackgroundColor Green;
}

########################################## Scratch Area ##########################################

#$DiskUsage = [PSCustomObject]@{"TotalSizeGB" = $TotalSizeGB; "SpaceUsedGB" = $SpaceUsedGB; "FreeSpaceGB" = $FreeSpaceGB; "PercentFree" = $PercentFree; "SizetobeDeletedGB" = $SizetobeDeletedGB; "PercentFreeAfterDelete" = $PercentFreeAfterDelete}
#$DiskUsage2 = $DiskUsage | foreach {(ConvertTo-Json $_.TotalSizeGB) -Replace ("}$", $((ConvertTo-Json $_.SpaceUsedGB) -Replace "^{", ",")) -Replace ("}$", $((ConvertTo-Json $_.FreeSpaceGB) -Replace "^{", ",")) -Replace ("}$", $((ConvertTo-Json $_.PercentFree) -Replace "^{", ",")) -Replace ("}$", $((ConvertTo-Json $_.TotalDeleteSizeGB) -Replace "^{", ",")) -Replace ("}$", $((ConvertTo-Json $_.PercentFreeAfterDelete) -Replace "^{", ",")) | ConvertFrom-Json} | Format-Table
#$DiskUsage2 | Format-Table;
#
#
## Get Disk details
#$DiskUsage = Get-Volume -DriveLetter C | , ;
#$DiskUsage
#
#$DiskUsage | Select-Object *

#$SourceDriveLetter = "C"
#$SourceDrive = Get-Volume -DriveLetter $SourceDriveLetter
#$SourceCapacity = [math]::Round(($SourceDrive.Size/1TB),2)

## Get all items including subdirectories
#Get-ChildItem -Path $path -Recurse
#
## View all properties of all items
#Get-ChildItem -Path $path -Recurse | Select-Object * 
#
## Show important details only like name, creation date and size
#Get-ChildItem -Path $path -Recurse | Select-Object name, lastwritetime, @{Name = "Size MB"; Expression = {[Math]::Round($_.Length / 1MB, 1)}} 
#
## Insert result into a variable
#$list = Get-ChildItem -Path $path -Recurse | Select-Object name, lastwritetime, @{Name = "Size MB"; Expression = {[Math]::Round($_.Length / 1MB, 1)}} 

#$list | measure -Property "Size MB" -Sum | Select-Object @{Name = "TotalSizeMB"; Expression = {measure -Property "Size MB" -Sum}}
#
#Get-ChildItem -Path 'C:\Users\edgar.bayron\Music\Edgar\test\' -Recurse |
#Where-Object {$_.lastwritetime -lt (Get-Date).AddHours(-336)} |
#Remove-Item -Confirm # Removes all files older than 336hours(2 weeks) (with confirmation)
#
#Get-ChildItem -Path 'C:\Users\edgar.bayron\Music\Edgar\test\' -Recurse |
#Where-Object {$_.lastwritetime -lt (Get-Date).AddHours(-336)} |
#Select-Object name, lastwritetime, @{Name = "Size MB"; Expression = {[Math]::Round($_.Length / 1MB, 1)}}
#
#Get-ChildItem -Path 'C:\Users\edgar.bayron\Music\Edgar\test\' -Recurse |
#Where-Object {$_.lastwritetime -lt (Get-Date).AddHours(-336)} |
#Remove-Item -WhatIf
#
#Get-ChildItem -Path 'C:\Users\edgar.bayron\Music\Edgar\test\' -Recurse |
#Where-Object {$_.lastwritetime -lt (Get-Date).AddHours(-336)} |
#Remove-Item -Confirm
#
#$file1 = Get-ChildItem C:\Users\edgar.bayron\Music\Edgar\test\dir1\dir3 | Where-Object name -eq 'FULL new (orig) - Copy.bak'
#$file1.LastWriteTime = (Get-Date)
#$file2 = Get-ChildItem C:\Users\edgar.bayron\Music\Edgar\test\dir1\dir3 | Where-Object name -eq 'FULL new 1 (orig) - Copy.bak'
#$file3 = Get-ChildItem C:\Users\edgar.bayron\Music\Edgar\test\dir1\dir3 | Where-Object name -eq 'FULL old 2 (orig) - Copy.bak'






