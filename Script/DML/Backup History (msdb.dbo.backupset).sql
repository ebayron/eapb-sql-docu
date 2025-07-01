SELECT
	backup_finish_date,
	backup_start_date,
	name AS backup_name,
	[database_name],
	CASE [type]
		WHEN 'D' THEN 'Full'
		WHEN 'I' THEN 'Differential'
		WHEN 'L' THEN 'Transactional Log'
		WHEN 'F' THEN 'Filegroup'
		WHEN 'G' THEN 'Differential Filegroup'
		WHEN 'P' THEN 'Partial'
		WHEN 'Q' THEN 'Differential Partial'
	END AS backup_type,
	CAST(((backup_size/1024.00)/1024)/1024 AS DECIMAL(9,2)) AS backup_size_GB,
	CAST(((compressed_backup_size/1024.00)/1024)/1024 AS DECIMAL(9,2)) AS backup_size_compressed_GB,
	[user_name],
	first_lsn,
	last_lsn,
	checkpoint_lsn,
	database_backup_lsn,
	differential_base_lsn
FROM msdb.dbo.backupset
ORDER BY 1 DESC