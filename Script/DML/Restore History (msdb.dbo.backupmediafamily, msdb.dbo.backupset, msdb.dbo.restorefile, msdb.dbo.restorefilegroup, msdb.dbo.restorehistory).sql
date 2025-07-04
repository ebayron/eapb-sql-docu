SELECT
	restore_history_id,
	restore_date,
	destination_database_name,
	[user_name],
	backup_set_id,
	restore_type,
	[replace],
	[recovery],
	[restart]
FROM msdb.dbo.restorehistory

SELECT
	rh.destination_database_name AS [Database],
	CASE
		WHEN rh.restore_type = 'D' THEN 'Database'
		WHEN rh.restore_type = 'F' THEN 'File'
		WHEN rh.restore_type = 'I' THEN 'Differential'
		WHEN rh.restore_type = 'L' THEN 'Log'
		ELSE rh.restore_type
	END AS [Restore Type],
	rh.restore_date AS [Restore Date],
	bm.physical_device_name AS [Source],
	rf.destination_phys_name AS [Restore File],
	rh.user_name AS [Restored By]
FROM msdb.dbo.restorehistory rh
INNER JOIN msdb.dbo.backupset bs ON rh.backup_set_id = bs.backup_set_id
INNER JOIN msdb.dbo.restorefile rf ON rh.restore_history_id = rf.restore_history_id
INNER JOIN msdb.dbo.backupmediafamily bm ON bm.media_set_id = bs.media_set_id
ORDER BY rh.restore_history_id DESC
GO

SELECT *
FROM msdb.dbo.restorefilegroup
