SELECT
	name AS "Database Name",
	(SELECT MAX(b.backup_finish_date) FROM msdb.dbo.backupset b WHERE d.name = b.database_name AND b.type = 'D') AS "Full Back Up",
	(SELECT MAX(b.backup_finish_date) FROM msdb.dbo.backupset b WHERE d.name = b.database_name AND b.type = 'I') AS "Differential Back Up",
	(SELECT MAX(b.backup_finish_date) FROM msdb.dbo.backupset b WHERE d.name = b.database_name AND b.type = 'L') AS "Transactional Log Back Up"
FROM sys.databases d