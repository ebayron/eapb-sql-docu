-- this query only covers drives where there are database files.

SELECT DISTINCT
	d.volume_mount_point AS Drive,
	CAST(CONVERT(DECIMAL(9, 2),d.total_bytes/1048576.0)/1024 AS DECIMAL(9,2)) AS "Total Space (GB)",
	CAST(CONVERT(DECIMAL(9, 2),d.total_bytes/1048576.0)/1024 - CONVERT(DECIMAL(9, 2),d.available_bytes/1048576.0)/1024 AS DECIMAL(9,2)) AS "Used Space (GB)",
	CAST(CONVERT(DECIMAL(9, 2),d.available_bytes/1048576.0)/1024 AS DECIMAL(9,2)) AS "Free Space (GB)",
	CAST(CAST((CAST(CONVERT(DECIMAL(9, 2),d.available_bytes/1048576.0)/1024 AS DECIMAL(9,2)) / CAST(CONVERT(DECIMAL(9, 2),d.total_bytes/1048576.0)/1024 AS DECIMAL(9,2))) * 100 AS DECIMAL(9, 2)) AS VARCHAR(6)) + ' %' AS "Free Space %",
	d.file_system_type AS "File System Type"
FROM master.sys.master_files m
CROSS APPLY master.sys.dm_os_volume_stats(m.database_id, m.FILE_ID) d
ORDER BY 1 ASC