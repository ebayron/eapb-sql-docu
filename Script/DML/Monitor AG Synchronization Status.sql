-- run on secondary node
SELECT
	[object_name],
	[counter_name],
	([cntr_value]/1024.0) cntr_value_MB
FROM sys.dm_os_performance_counters
WHERE [object_name] LIKE '%Database Replica%'
AND [counter_name] = 'Log remaining for undo'
