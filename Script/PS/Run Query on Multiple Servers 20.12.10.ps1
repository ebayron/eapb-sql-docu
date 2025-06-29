Import-Module SQLSERVER

# $VerbosePreference = 'Continue'

$Servers = @(   
    '.\INSTANCE01'
)

$Servers

Write-Host "`nAbove are the list of server/instances that will be affected. Do you want syspolicy_purge_history job to be disabled or not?`n" -ForegroundColor Green -BackgroundColor Black

Write-Host "`t1 - Enable`n`t2 - Disable`n" -ForegroundColor Yellow

$RunOption = Read-Host "Enter your selection"

Write-Host "`n"

switch($RunOption)
    {
        1 {$JobStatus='Enable'; Write-Host 'Enabling job.'}
        2 {$JobStatus='Disable'; Write-Host 'Disabling job.'}
        default {Write-Host 'Invalid Entry'; Exit}
    }

Switch($JobStatus)
    {
        'Enable' {$Command='EXEC msdb.dbo.sp_syspolicy_purge_history'}
        'Disable' {$Command='--EXEC msdb.dbo.sp_syspolicy_purge_history'}
    }

$Query = 
    "
    EXEC msdb.dbo.sp_update_jobstep
	@job_name='syspolicy_purge_history',
	@step_id=2,
	@command='$Command'
    "

$Cred = Get-Credential -Credential 'sa'

foreach ($CurrentServer in $Servers)
    {
        Write-Host "Working on $CurrentServer"
        $ExecQuery = @{ServerInstance = $CurrentServer; Query=$Query; Credential=$Cred; ErrorAction='Continue'}
        Invoke-Sqlcmd @ExecQuery
    }