## Error: PackageManagement\Install-Package : The following commands are already available on this system:'.... This module 'SqlServer' may override the existing commands. If you still want to install this module 'SqlServer', use -AllowClobber parameter.
## Solution: Install-Module -Name SqlServer -AllowClobber
## Error: Invoke-Sqlcmd : A connection was successfully established with the server, but then an error occurred during the login process. ...The certificate chain was issued by an authority that is not trusted.)
## Solution: Invoke-Sqlcmd ... -TrustServerCertificate # https://learn.microsoft.com/en-us/sql/connect/ado-net/introduction-microsoft-data-sqlclient-namespace?view=sql-server-ver15#breaking-changes-in-40

## PROs:
## This can be re-run
## This can be executed in Powershell at your desktop and not inside SSMS (right-click > Start Powershell)
## CONs:
## If you manually deleted/rename/moved a folder inside Reg Server while this script was just ran and session is still open, restart your PowerShell_ISE.exe first in order to reflect it in SQLSERVER:\SQLRegistration\Database Engine Server Group before re-running or else it will detect the old folder setup prior deletion/rename/move. This is due to caching issue of PowerShell_ISE. The fix is to run this script inside SSMS (right-click > Start Powershell)) #does PS 7 corrects this?

# TEST TABLE
#  CREATE TABLE [dbo].[ServerList](
#	[ServerName] [varchar](40) NOT NULL,
#	[Region] [varchar](20) NOT NULL,
#	[Side] [char](1) NULL,
#	[Environment] [char](3) NULL
# ) ON [PRIMARY]


cls
Set-Location "C:\" # Just in case you have to re-run this script on the same PS session, this is to reset the path.

Import-Module SqlServer # Load the SQLServer module into current PS session. This provides cmdlets and functionality for managing and interacting data with SQL Server.

# CONNECT AND LOAD DATA

$ServerInstance = "."
$Database = "master"
$Username = "sa"
$Password = "P@ssw0rd" # In the future, change this into input parameter

try {
    $SQLAll = Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -Query "SELECT ServerName, Region, Side, Environment FROM dbo.ServerList" -Username $Username -Password $Password -TrustServerCertificate # Get serverlist and to know which group/folder they belong
    $SQLRegion = Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -Query "SELECT DISTINCT Region FROM dbo.ServerList" -Username $Username -Password $Password -TrustServerCertificate # Get Region which will become the main group/folder.
    $SQLEnvironment = Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -Query "SELECT DISTINCT Environment FROM dbo.ServerList" -Username $Username -Password $Password -TrustServerCertificate # Get Environment which will become the main subgroup/subfolder.
} catch {
    Write-Host "Error connecting to SQL Server: $($_.Exception.Message)" -ForegroundColor Red
    return }

# GO TO THE REGISTERED SERVERS DATABASE ENGINE GROUP ROOT FOLDER

Set-Location "SQLSERVER:\SQLRegistration\Database Engine Server Group" # Go to the Registered Servers Database Engine group root folder

# CREATE NG FOLDER (it will be the base folder for this list of servers)

if (-not (Test-Path "NG")) { 
    try { New-Item -Path "sqlserver:\SQLRegistration\Database Engine Server Group\NG" }
    catch {
        Write-Host "Error connecting to SQL Server: $($_.Exception.Message)" -ForegroundColor Red
        return }}

# CREATE MAIN GROUP (AWS, Data Center, Europe, Canada, etc)

foreach ($rowloop1 in $SQLRegion) {
    $RegionFolder = $rowloop1["Region"]
    Set-Location "SQLSERVER:\SQLRegistration\Database Engine Server Group\NG" # NG folder should already exists no matter what at this point and location should go back here every loop
    if (-not (Test-Path $RegionFolder)) { 
        
        try { # if region folder does not exists, create it together with the sub folders
            New-Item -Path "SQLSERVER:\SQLRegistration\Database Engine Server Group\NG\$RegionFolder"
            New-Item -Path "SQLSERVER:\SQLRegistration\Database Engine Server Group\NG\$RegionFolder\COR"
            New-Item -Path "SQLSERVER:\SQLRegistration\Database Engine Server Group\NG\$RegionFolder\DWA"
            New-Item -Path "SQLSERVER:\SQLRegistration\Database Engine Server Group\NG\$RegionFolder\BIT"
            New-Item -Path "SQLSERVER:\SQLRegistration\Database Engine Server Group\NG\$RegionFolder\COR\A"
            New-Item -Path "SQLSERVER:\SQLRegistration\Database Engine Server Group\NG\$RegionFolder\DWA\A"
            New-Item -Path "SQLSERVER:\SQLRegistration\Database Engine Server Group\NG\$RegionFolder\BIT\A"
            New-Item -Path "SQLSERVER:\SQLRegistration\Database Engine Server Group\NG\$RegionFolder\COR\B"
            New-Item -Path "SQLSERVER:\SQLRegistration\Database Engine Server Group\NG\$RegionFolder\DWA\B"
            New-Item -Path "SQLSERVER:\SQLRegistration\Database Engine Server Group\NG\$RegionFolder\BIT\B"
            Write-Host "Region folder '$RegionFolder' created." -ForegroundColor Green }
        catch {
            Write-Host "There is an error in creating $RegionFolder : $($_.Exception.Message)" -ForegroundColor Red
            return }
    }

# SINCE THE REGION FOLDER ALREADY EXISTS, IT WILL NOW THEN CHECK ITS SUBFOLDERS (COR, DWA, BIT)
    else {
        try { 

            Write-Host "Region folder '$RegionFolder' already exists." -ForegroundColor Yellow
            
            # if subfolders do not exists, create, if exists, go to it and check the subfolder under it (A&B folders) if exists, if not, create
            # CREATE SUB GROUPS
            foreach ($rowloop2 in $SQLEnvironment) {
                $EnvironmentFolder = $rowloop2["Environment"]
                Set-Location "SQLSERVER:\SQLRegistration\Database Engine Server Group\NG\$RegionFolder"
                if (-not (Test-Path $EnvironmentFolder)) {
                    New-Item -Path "SQLSERVER:\SQLRegistration\Database Engine Server Group\NG\$RegionFolder\$EnvironmentFolder"
                    Write-Host "Sub folder $EnvironmentFolder for main group '$RegionFolder' created." -ForegroundColor Green
                }

# SINCE THE ENVIRONMENT FOLDER ALREADY EXISTS, IT WILL NOW THEN CHECK ITS SUBFOLDERS (A and B)
                Set-Location "SQLSERVER:\SQLRegistration\Database Engine Server Group\NG\$RegionFolder\$EnvironmentFolder"
                    if (-not (Test-Path "A")) {
                        New-Item -Path "SQLSERVER:\SQLRegistration\Database Engine Server Group\NG\$RegionFolder\$EnvironmentFolder\A"
                        Write-Host "Sub folder A for Sub folder $EnvironmentFolder for main group '$RegionFolder' created." -ForegroundColor Green
                        }
                    if (-not (Test-Path "B")) {
                        New-Item -Path "SQLSERVER:\SQLRegistration\Database Engine Server Group\NG\$RegionFolder\$EnvironmentFolder\B"
                        Write-Host "Sub folder B for Sub folder $EnvironmentFolder for main group '$RegionFolder' created." -ForegroundColor Green
                        }
            }
        }
        catch {
            $CurrentLocation = Get-Location
            # Write-Host "There is an error in creating folder under SQLSERVER:\SQLRegistration\Database Engine Server Group\NG\$Region : $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "There is an error in creating folder under $CurrentLocation : $($_.Exception.Message)" -ForegroundColor Red
            return }
    }

}

# POPULATE GROUPS WITH SERVER LIST

$sides = 'A', 'B'

# FIRST IS TO LOOP EVERY REGION

foreach ($RowLoop3 in $SQLRegion) { # AWS, DC, CANADA, etc
    $RegionLoop = $RowLoop3.Region

# THEN FOR EACH REGION, IT WILL LOOP FOR EACH ENVIRONMENT

    foreach ($RowLoop4 in $SQLEnvironment) { # COR, BIT, DWA, etc
        $EnvironmentLoop = $RowLoop4.Environment

# THEN FOR EACH ENVIRONMENT, IT WILL LOOP FOR EACH A AND B

        foreach ($RowLoop5 in $sides) { # A or B
            $Side = $RowLoop5

# THE RETRIEVED DATA EARLIER WILL BE FILTERED BASED ON THE LOOP's CURRENT REGION, ENVIRONMENT, AND SIDE

            $CurrentListSet = $SQLAll | Where-Object {$_.Region -eq $RegionLoop -and $_.Environment -eq $EnvironmentLoop -and $_.Side -eq $Side} | Select-Object -ExpandProperty ServerName # due to filtering, this variable is now an object, not anymore a hashtable or a dictonary; -expandproperty will force a literal string instead of something like this (@{ServerName=LAX-C16BIT01}.ServerName)

# IF ONLY THERE WAS DATA RETRIEVED, PROCEED (although there should be no chance that this will be null as created folders are based on the table data itself)
        
            if($CurrentListSet -ne $null){

                # $CurrentListSet is the list of servers in the table
                # $ListofServer is the list of servers in the Registered Server's current folder

# SET LOCATION BASED ON THE CURRENT LOOP's REGION/ENVIRONMENT/SIDE IN ORDER TO CHECK IF THE LIST IN THE TABLE EXISTS.

                Set-Location "SQLSERVER:\SQLRegistration\Database Engine Server Group\NG\$RegionLoop\$EnvironmentLoop\$Side"
                $path = Get-Location
                $ListofServer = Get-ChildItem -Path $path | Select-Object -ExpandProperty Name

                foreach ($RowLoop6 in $CurrentListSet) {
                    $CheckThisServer = $RowLoop6

# IF NOT EXISTS, ADD IT IN THE REGISTERED SERVER

                    if (-not ($ListofServer -contains $CheckThisServer)) {
                        try {
                            New-Item -Name $(encode-sqlname $CheckThisServer) -path $path -ItemType Registration -Value("Server=$CheckThisServer;Authentication=SqlAuthentication;user id=$username;Password=$password;encrypt=optional"); # newer version of SSMS requires encrypt in the GUI    
                            Write-Host "$CheckThisServer added under $path." -ForegroundColor Green
                        } catch {Write-Host "There is an error in creating $CheckThisServer under $path : $($_.Exception.Message)" -ForegroundColor Red}
                    }
                }
            } 
        }

    }
}