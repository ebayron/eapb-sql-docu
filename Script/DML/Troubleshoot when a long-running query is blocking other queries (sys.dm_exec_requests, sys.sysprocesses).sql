-- troubleshoot when a long-running query is blocking other queries
-- https://www.brentozar.com/archive/2008/11/stackoverflows-sql-2008-fts-issue-solved/

DECLARE @temp INT
DECLARE @parent INT
DECLARE @final INT

SET @parent = 0

WHILE (@parent = 0)
BEGIN
	SELECT @parent = blocked FROM sys.sysprocesses WHERE lastwaittype = 'LCK_M_SCH_M' AND waittime > 30000
	WAITFOR DELAY '00:00:01';
END

WHILE (@parent <> 0)
BEGIN
	SET @final = @parent
	SELECT @temp = blocked FROM sys.sysprocesses WHERE spid = @parent
	SET @parent = @temp
END

SELECT *
FROM sys.sysprocesses WHERE spid = @final

SELECT *
FROM sys.dm_exec_requests er
CROSS APPLY sys.dm_exec_sql_text(er.plan_handle) st
WHERE er.session_id = @final

SELECT *
FROM sys.dm_exec_requests er
CROSS APPLY sys.dm_exec_query_plan(er.plan_handle) st
WHERE er.session_id = @final
