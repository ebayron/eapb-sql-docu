DECLARE @dt DATETIME;
SELECT @dt = CAST(N'2019-10-01T09:54:17' AS DATETIME);

-- Back Up History
EXEC msdb.dbo.sp_delete_backuphistory @oldest_date = @dt;

-- SQL Server Agent Job History
EXEC msdb.dbo.sp_purge_jobhistory @oldest_date = @dt;

-- Maintenance Plan History
EXEC msdb.dbo.sp_maintplan_delete_log @plan_id = NULL, @subplan_id = NULL, @oldest_time = @dt;