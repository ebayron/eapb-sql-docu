SELECT TOP 100
	DB_NAME(database_id) AS DatabaseName,
	OBJECT_NAME(object_id,database_id) AS ProcedureName,
	cached_time,
	last_execution_time,
	execution_count,
	total_elapsed_time/execution_count AS avg_elapsed_time, -- microseconds
	[type_desc]
FROM sys.dm_exec_procedure_stats
	WHERE OBJECT_NAME(object_id,database_id) = 'IC_InsertOrUpdateProspectiveContactsByXML'
ORDER BY avg_elapsed_time;