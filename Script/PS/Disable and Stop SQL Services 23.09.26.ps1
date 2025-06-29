################################################################################################################################################
<# Enable and Start #>
	
Get-Service -Name MSSQLSERVER 		| Set-Service -StartupType Automatic
Get-Service -Name MSSQLSERVER 		| Start-Service
Get-Service -Name SQLSERVERAGENT 	| Set-Service -StartupType Automatic
Get-Service -Name SQLSERVERAGENT 	| Start-Service
Get-Service -Name SQLBrowser 		| Set-Service -StartupType Automatic
Get-Service -Name SQLBrowser 		| Start-Service

# COR
Get-Service -Name MSSQL`$INUSER | Set-Service -StartupType Automatic
Get-Service -Name SQLAgent`$INUSER | Set-Service -StartupType Automatic
Get-Service -Name MSSQL`$INUSER | Start-Service
Get-Service -Name SQLAgent`$INUSER | Start-Service

# DWA
#Get-Service -Name MsDtsServer120 | Set-Service -StartupType Automatic
#Get-Service -Name MsDtsServer140 | Set-Service -StartupType Automatic
#Get-Service -Name MsDtsServer120 | Start-Service
#Get-Service -Name MsDtsServer140 | Start-Service

################################################################################################################################################

<# Disable and stop all sql services
Get-Service -DisplayName *sql* -DependentServices | Stop-Service -PassThru
Get-Service -DisplayName *sql* | Stop-Service -PassThru
Get-Service -DisplayName *sql* | Set-Service -StartupType disabled
#>

<# Sample of stop/disable of service
Get-Service -Name SQLBrowser | Set-Service -StartupType disabled
Get-Service -Name MsDtsServer120 | Stop-Service -PassThru -Force
#>