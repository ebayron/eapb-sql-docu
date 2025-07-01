WAITFOR DELAY '00:01:00'

DECLARE @percent_complete VARCHAR(100) = '';

SELECT
	@percent_complete = 'Progress: ' + CAST(r.percent_complete AS VARCHAR(10)) + ' Estimate Completion Time (min): ' + CAST(r.estimated_completion_time/(1000*60) AS VARCHAR(10))
FROM sys.dm_exec_requests r 
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) s
WHERE r.command in ('BACKUP DATABASE', 'RESTORE DATABASE')

PRINT @percent_complete

GO 200