-- Query Gets The Most Number Of Disk Reads
 
SELECT TOP 200
 [Average execution speed in seconds] = qs.total_elapsed_time / qs.execution_count / 1000000.0,
 [Total execution count] = qs.execution_count,
 [Execution frequency per second] = qs.execution_count/DATEDIFF(Second, qs.creation_time, GetDate()),
 [Total CPU used] = total_worker_time,
 [Average CPU used per execution] = total_worker_time / qs.execution_count,
 [Total disk reads] = qs.total_physical_reads,
 [Average disk reads per execution] = qs.total_physical_reads / qs.execution_count,
 [Total memory reads] = qs.total_logical_reads,
 [Average memory reads per execution] = qs.total_logical_reads / qs.execution_count,
 [DatabaseName] = DB_NAME(qt.dbid),
 
 [Individual Query] = SUBSTRING (qt.text,qs.statement_start_offset/2,
         (CASE WHEN qs.statement_end_offset = -1 THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2
          ELSE qs.statement_end_offset END - qs.statement_start_offset)/2)
 
FROM sys.dm_exec_query_stats qs CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt  order by [Average disk reads per execution] desc
 
-- End Of Query

-- Query gets the average cpu used per query
 
SELECT TOP 200
 [Average execution speed in seconds] = qs.total_elapsed_time / qs.execution_count / 1000000.0,
 [Total execution count] = qs.execution_count,
 [Execution frequency per second] = qs.execution_count/DATEDIFF(Second, qs.creation_time, GetDate()),
 [Total CPU used] = total_worker_time,
 [Average CPU used per execution] = total_worker_time / qs.execution_count,
 [Total disk reads] = qs.total_physical_reads,
 [Average disk reads per execution] = qs.total_physical_reads / qs.execution_count,
 [Total memory reads] = qs.total_logical_reads,
 [Average memory reads per execution] = qs.total_logical_reads / qs.execution_count,
 [DatabaseName] = DB_NAME(qt.dbid),
 
 [Individual Query] = SUBSTRING (qt.text,qs.statement_start_offset/2,
         (CASE WHEN qs.statement_end_offset = -1 THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2
          ELSE qs.statement_end_offset END - qs.statement_start_offset)/2)
 
FROM sys.dm_exec_query_stats qs CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt order by [Average CPU used per execution] desc
 
-- End Of Query

-- QUERY gets the most cpu used in total.
 
SELECT TOP 200
 [Average execution speed in seconds] = qs.total_elapsed_time / qs.execution_count / 1000000.0,
 [Total execution count] = qs.execution_count,
 [Execution frequency per second] = qs.execution_count/DATEDIFF(Second, qs.creation_time, GetDate()),
 [Total CPU used] = total_worker_time,
 [Average CPU used per execution] = total_worker_time / qs.execution_count,
 [Total disk reads] = qs.total_physical_reads,
 [Average disk reads per execution] = qs.total_physical_reads / qs.execution_count,
 [Total memory reads] = qs.total_logical_reads,
 [Average memory reads per execution] = qs.total_logical_reads / qs.execution_count,
 [DatabaseName] = DB_NAME(qt.dbid),
 
 [Individual Query] = SUBSTRING (qt.text,qs.statement_start_offset/2,
         (CASE WHEN qs.statement_end_offset = -1 THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2
          ELSE qs.statement_end_offset END - qs.statement_start_offset)/2)
 
FROM sys.dm_exec_query_stats qs CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt order by [Total CPU used] desc
 
-- End Of Query
-- Query gets the average cpu used per query
 
SELECT TOP 200
 [Average execution speed in seconds] = qs.total_elapsed_time / qs.execution_count / 1000000.0,
 [Total execution count] = qs.execution_count,
 [Execution frequency per second] = qs.execution_count/DATEDIFF(Second, qs.creation_time, GetDate()),
 [Total CPU used] = total_worker_time,
 [Average CPU used per execution] = total_worker_time / qs.execution_count,
 [Total disk reads] = qs.total_physical_reads,
 [Average disk reads per execution] = qs.total_physical_reads / qs.execution_count,
 [Total memory reads] = qs.total_logical_reads,
 [Average memory reads per execution] = qs.total_logical_reads / qs.execution_count,
 [DatabaseName] = DB_NAME(qt.dbid),
 
 [Individual Query] = SUBSTRING (qt.text,qs.statement_start_offset/2,
         (CASE WHEN qs.statement_end_offset = -1 THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2
          ELSE qs.statement_end_offset END - qs.statement_start_offset)/2)
 
FROM sys.dm_exec_query_stats qs CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt order by [Average CPU used per execution] desc
 
-- End Of Query

SELECT TOP 200
 [Average execution speed in seconds] = qs.total_elapsed_time / qs.execution_count / 1000000.0,
 [Total execution count] = qs.execution_count,
 [Execution frequency per second] = qs.execution_count/DATEDIFF(Second, qs.creation_time, GetDate()),
 [Total CPU used] = total_worker_time,
 [Average CPU used per execution] = total_worker_time / qs.execution_count,
 [Total disk reads] = qs.total_physical_reads,
 [Average disk reads per execution] = qs.total_physical_reads / qs.execution_count,
 [Total memory reads] = qs.total_logical_reads,
 [Average memory reads per execution] = qs.total_logical_reads / qs.execution_count,
 [DatabaseName] = DB_NAME(qt.dbid),
 
 [Individual Query] = SUBSTRING (qt.text,qs.statement_start_offset/2,
         (CASE WHEN qs.statement_end_offset = -1 THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2
          ELSE qs.statement_end_offset END - qs.statement_start_offset)/2)
 
FROM sys.dm_exec_query_stats qs CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt order by [Execution frequency per second] desc
 
-- End Of Query