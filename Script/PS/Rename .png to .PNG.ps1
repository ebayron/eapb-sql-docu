## On Windows, since the file system is case-insensitive, simply renaming .png to .PNG doesn’t trigger a rename unless the name changes more than just the case.
## To work around this, we can force PowerShell to rename it twice: first to a temporary extension (like .temp), and then back to .PNG. 


Get-ChildItem -Recurse -Filter *.png | ForEach-Object {
    $original = $_.FullName
    $temp = [System.IO.Path]::ChangeExtension($original, ".temp")
    $target = [System.IO.Path]::ChangeExtension($original, ".PNG")

    Rename-Item -Path $original -NewName ([System.IO.Path]::GetFileName($temp))
    Rename-Item -Path $temp -NewName ([System.IO.Path]::GetFileName($target))
}
