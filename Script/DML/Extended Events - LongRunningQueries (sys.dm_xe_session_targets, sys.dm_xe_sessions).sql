/*
USE AdventureWorks2016;

SELECT TOP 95000000 *
FROM Production.TransactionHistoryArchive
CROSS JOIN Production.TransactionHistory; -- executes around 33 minutes
*/

IF OBJECT_ID('tempdb..#XE_LongRunCompletedQueries') IS NOT NULL
DROP TABLE #XE_LongRunCompletedQueries
SELECT CAST(target_data as xml) AS targetdata
INTO #XE_LongRunCompletedQueries
FROM sys.dm_xe_session_targets xet
INNER JOIN sys.dm_xe_sessions xes ON xes.address = xet.event_session_address
WHERE xes.name = 'XE_LongRunCompletedQueries'

SELECT xed.event_data.value('(@timestamp)[1]', 'datetime2') AS datetime_utc,
CONVERT(datetime2,SWITCHOFFSET(CONVERT(datetimeoffset,xed.event_data.value('(@timestamp)[1]', 'datetime2')),DATENAME(TzOffset, SYSDATETIMEOFFSET()))) AS datetime_local,
xed.event_data.value('(@name)[1]', 'varchar(50)') AS event_type,
xed.event_data.value('(data[@name="statement"]/value)[1]', 'varchar(max)') AS statement,
CAST(((xed.event_data.value('(data[@name="duration"]/value)[1]', 'bigint')/1000)/1000)/60.00 AS DECIMAL(9, 2)) AS duration_min,
CAST(((xed.event_data.value('(data[@name="cpu_time"]/value)[1]', 'bigint')/1000)/1000)/60.00 AS DECIMAL(9, 2)) AS cpu_time_min,
xed.event_data.value('(data[@name="physical_reads"]/value)[1]', 'bigint') AS physical_reads,
xed.event_data.value('(data[@name="logical_reads"]/value)[1]', 'bigint') AS logical_reads,
xed.event_data.value('(data[@name="writes"]/value)[1]', 'bigint') AS writes,
xed.event_data.value('(data[@name="row_count"]/value)[1]', 'bigint') AS row_count,
xed.event_data.value('(action[@name="database_name"]/value)[1]', 'varchar(255)') AS database_name,
xed.event_data.value('(action[@name="client_hostname"]/value)[1]', 'varchar(255)') AS client_hostname,
xed.event_data.value('(action[@name="client_app_name"]/value)[1]', 'varchar(255)') AS client_app_name
FROM #XE_LongRunCompletedQueries
CROSS APPLY targetdata.nodes('//RingBufferTarget/event') AS xed (event_data)
WHERE 1=1
/* refine your search further than the XE session's filter
AND xed.event_data.value('(data[@name="statement"]/value)[1]', 'varchar(max)') = 'EXEC spDemoSproc'
--*/
/* find queries within a time range
AND xed.event_data.value('(@timestamp)[1]', 'datetime2') > CAST('20170925 09:57 AM' AS datetime2) AT TIME ZONE 'Eastern Standard Time'
--*/
/* Find highest resource consumption
ORDER BY
xed.event_data.value('(data[@name="duration"]/value)[1]', 'bigint') DESC
--xed.event_data.value('(data[@name="cpu_time"]/value)[1]', 'bigint') DESC
--xed.event_data.value('(data[@name="physical_reads"]/value)[1]', 'bigint') DESC
--xed.event_data.value('(data[@name="logical_reads"]/value)[1]', 'bigint') DESC
--xed.event_data.value('(data[@name="writes"]/value)[1]', 'bigint') DESC
--xed.event_data.value('(data[@name="row_count"]/value)[1]', 'bigint') DESC
--*/