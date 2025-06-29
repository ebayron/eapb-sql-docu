<#
.SYNOPSIS
An easy way of re-running of SQL Server Jobs.

.DESCRIPTION
This PowerShell script is applicable every time you receive an failed job alert from T-Bad and the only is to re-run the job.

This will save time since you just run this script on your local machine and input some parameters

Script Flow:
- You only need to specify server name and job name.
- Shows the last successful and failed job run.
- Shows the logs of that alert to decide if it's pratical to re-run the job.
- Script will enter a loop state until the job successfully run/failed/cancelled.
- If re-running the job failed/cancelled, that's the only time to check the job remotely or through SSMS.

.NOTES
Author: Edgar Allan Bayron

For security purposes, if using the script first time, run below script to generate your credentials:
   $Path = "C:\PowerShell\Cred.txt"
   (Get-Credential).Password | ConvertFrom-SecureString | Out-File $Path
#>

cls
Import-Module SqlServer

$Path = "C:\PowerShell\Cred.txt"
$User = "tbad"
$Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (Get-Content $Path | ConvertTo-SecureString)

$Svr = Read-Host "Enter server name"
$Job = Read-Host "Enter job name"

Write-Host "`r"
Write-Host "Basic Job Info and Schedule:" -ForegroundColor Yellow -BackgroundColor Green;

$QueryHash = @"
	SELECT
	    j.[name],
	    js.next_run_date,
	    js.next_run_time,
	    s.active_start_time
    FROM msdb.dbo.sysjobs j
    INNER JOIN msdb.dbo.sysjobschedules js ON j.job_id = js.job_id
    INNER JOIN msdb.dbo.sysschedules s ON js.schedule_id = s.schedule_id
    WHERE j.[name] = '$Job'
"@

$Result = Invoke-SqlCmd -ServerInstance $Svr -Credential $Cred -Query $QueryHash
$Result | FT

Write-Host "`r"
Write-Host "Last Successful and Failed Run:" -ForegroundColor Yellow -BackgroundColor Green;
 
$QueryHash = @"
	SELECT
        'Success' AS [LastStatus],
		MAX(CAST(STUFF(STUFF(CAST(h.run_date as varchar),7,0,'-'),5,0,'-') + ' ' + STUFF(STUFF(REPLACE(STR(h.run_time,6,0),' ','0'),5,0,':'),3,0,':') as datetime)) AS [Date]
	FROM msdb.dbo.sysjobs j
	INNER JOIN msdb.dbo.sysjobhistory h ON h.job_id = j.job_id
		AND h.step_id = 0
	WHERE j.[name] = '$Job'
        AND h.run_status = 1
	GROUP BY j.[name]
    UNION ALL
    SELECT
            CASE h.run_status
                WHEN 0 THEN 'Failed'
                WHEN 3 THEN 'Cancelled'
                ELSE 'Unknown'
			END,
		    MAX(CAST(STUFF(STUFF(CAST(h.run_date as varchar),7,0,'-'),5,0,'-') + ' ' + STUFF(STUFF(REPLACE(STR(h.run_time,6,0),' ','0'),5,0,':'),3,0,':') as datetime))
	    FROM msdb.dbo.sysjobs j
	    INNER JOIN msdb.dbo.sysjobhistory h ON h.job_id = j.job_id
		    AND h.step_id = 0
	    WHERE j.[name] = '$Job'
            AND h.run_status IN (0, 3)
	    GROUP BY j.[name],  CASE h.run_status
            WHEN 0 THEN 'Failed'
            WHEN 3 THEN 'Cancelled'
            ELSE 'Unknown'
			END
"@

$Result = Invoke-SqlCmd -ServerInstance $Svr -Credential $Cred -Query $QueryHash
$Result | FT

Write-Host "`r"
Write-Host "Log of the latest job run:" -ForegroundColor Yellow -BackgroundColor Green;

$QueryHash = @"
	SELECT TOP 1 
        h.run_status, 
        h.message
    FROM msdb.dbo.sysjobs j
    INNER JOIN msdb.dbo.sysjobhistory h ON j.job_id = h.job_id
    WHERE j.name = '$Job'
	    AND h.step_id <> 0
    ORDER BY h.instance_id DESC
"@

$Result = Invoke-SqlCmd -ServerInstance $Svr -Credential $Cred -Query $QueryHash
Write-Host "`r"
$Result.Message | Format-List

Write-Host "`r"
Write-Host "Comment:" -ForegroundColor Yellow -BackgroundColor Green;

Function TrackJobProgress {

$QueryHash = @"
	SELECT 
     ISNULL(h.[run_status], 4) AS [RunStatus]
    FROM [msdb].[dbo].[sysjobs] j
    INNER JOIN [msdb].[dbo].[sysjobactivity] a ON j.job_id = a.job_id
    INNER JOIN (--Get the latest session that ISN'T NULL. It should always have a run_requested_date
        SELECT
            [Session_ID] = MAX([session_id])
        FROM msdb.dbo.[sysjobactivity] a1
        INNER JOIN msdb.dbo.sysjobs j1 ON [j1].[job_id] = [a1].[job_id]
        WHERE j1.name = '$Job'
            AND a1.[run_requested_date] IS NOT NULL
        ) s ON [s].[Session_ID] = [a].[session_id]
    LEFT JOIN [msdb].[dbo].[sysjobhistory] h ON a.job_history_id = h.instance_id
    WHERE j.name = '$Job'
"@

$i = 4
While ($i -eq 2 -or $i -eq 4)
    {
        $Result = Invoke-SqlCmd -ServerInstance $Svr -Credential $Cred -Query $QueryHash
        Switch($Result.RunStatus) {
        0 {Write-Host "Failed:" (Get-Date)}
        1 {Write-Host "Succeeded:" (Get-Date)}
        2 {Write-Host "Retry:" (Get-Date)}
        3 {Write-Host "Cancelled:" (Get-Date)}
        4 {Write-Host "In Progress:" (Get-Date)}
        }
        $i = $Result.RunStatus
        Start-Sleep -Seconds 30 # This can be adjusted for better monitoring
    }

$QueryHash = @"
    SELECT TOP 1 
        h.run_status, 
        h.message
    FROM msdb.dbo.sysjobs j
    INNER JOIN msdb.dbo.sysjobhistory h ON j.job_id = h.job_id
    WHERE j.name = '$Job'
	    AND h.step_id <> 0
        ORDER BY h.instance_id DESC
"@

$Result = Invoke-SqlCmd -ServerInstance $Svr -Credential $Cred -Query $QueryHash
Write-Host "`r"
$Result.Message | Format-List

if ($Result.run_status -ne 1) {
    
    Write-Host "`r"
    $YN = Read-Host "Do you want to re-run job?"

    if ($YN -eq "Y") {
        $Query = "EXEC msdb.dbo.sp_start_job '$Job'"
        Invoke-SqlCmd -ServerInstance $Svr -Credential $Cred -Query $Query
        
        TrackJobProgress
    }   
}

}

Write-Host "`r"

if ($Result.run_status -eq 2) {
    
    Write-Host "Job is currently in Retry status. Tracking progress:" 
   
    TrackJobProgress

}
elseif ($Result.Message -Like "*The step failed*") {
    $YN = Read-Host "Do you want to re-run job?"
    Write-Host "`r"

    if ($YN -eq "Y") {

        $Query = "EXEC msdb.dbo.sp_start_job '$Job'"
        Invoke-SqlCmd -ServerInstance $Svr -Credential $Cred -Query $Query
        
        TrackJobProgress

    }
    else {Write-Host "Exiting."}
}
elseif ($Result.Message -Like "*The step was cancelled*") {
    $YN = Read-Host "Do you want to re-run job?"
    Write-Host "`r"

    if ($YN -eq "Y") {

        $Query = "EXEC msdb.dbo.sp_start_job '$Job'"
        Invoke-SqlCmd -ServerInstance $Svr -Credential $Cred -Query $Query
        
        TrackJobProgress

    }
    else {Write-Host "Exiting."}
}
else {
    Write-Host("Last job already succeeded. Nothing to do. If you received an alert regarding a job error but last job succeeded, it is possible that the job has a retry step.")
     # There is a scenario where a job is running every 5 minutes (failing on step 2) and upon executing the PS script to check the job status, it sees the currently running job's step which succeeded (on step 1).
}