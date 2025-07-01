SELECT
	d.database_id AS "Database ID",
	d.name AS "Database Name",
	d.create_date AS "Create Date",
	CAST((SELECT SUM(mf.size * 8)/1024.00/1024 FROM sys.master_files mf WHERE mf.database_id = d.database_id) AS DECIMAL(9, 3)) AS "Database Size (GB)",
	d.compatibility_level AS "Compatibility Level",
	CASE d.compatibility_level
		WHEN 80 THEN '80'
		WHEN 90 THEN '90, 80'
		WHEN 100 THEN '100, 90, 80'
		WHEN 110 THEN '110, 100, 90'
		WHEN 120 THEN '120, 110, 100'
		WHEN 130 THEN '130, 120, 110, 100'
		WHEN 140 THEN '150 (Azure), 140, 130, 120, 110, 100'
		WHEN 150 THEN '150, 140, 130, 120, 110, 100'
		ELSE CAST(d.compatibility_level AS CHAR(3))
	END AS "Supported Compatibility Levels",
	CASE d.compatibility_level
		WHEN 80 THEN 'SQL Server 2000'
		WHEN 90 THEN 'SQL Server 2005'
		WHEN 100 THEN 'SQL Server 2008 / SQL Server 2008 R2'
		WHEN 110 THEN 'SQL Server 2012'
		WHEN 120 THEN 'SQL Server 2014'
		WHEN 130 THEN 'SQL Server 2016'
		WHEN 140 THEN 'SQL Server 2017 / Azure SQL Database single database/elastic pool / Azure SQL Database managed instance'
		WHEN 150 THEN 'SQL Server 2019'
		ELSE CAST(d.compatibility_level AS CHAR(3))
	END AS "Database Version",
	SERVERPROPERTY('ProductVersion') AS "Database Engine Version", 
	d.collation_name AS "Database Collation",
	d.user_access_desc AS "User Access",
	d.state_desc AS "State",
	d.snapshot_isolation_state_desc AS "Snapshot Isolation",
	d.recovery_model_desc AS "Recovery Model",
	d.log_reuse_wait_desc AS "Log Reuse Wait",
	d.replica_id AS "Always On Replica ID",
	d.group_database_id AS "Always On Group Database ID",
	d.is_cdc_enabled AS "Is CDC Enabled?",
	d.is_encrypted AS "Is Encrypted?",
	d.is_fulltext_enabled AS "Is Fulltext Enabled?",
	d.is_trustworthy_on AS "Is Trustworthy On?",
	d.is_db_chaining_on AS "Is DB Chaining On?",
	d.is_read_committed_snapshot_on AS "Is Read Committed Snapshot On?",
	d.is_read_only AS "Is Read Only?",
	d.is_auto_close_on AS "Is Auto Close?",
	d.is_auto_shrink_on AS "Is Auto Shrink?",
	d.is_in_standby AS "Is in Standby?"
FROM master.sys.databases d
ORDER BY 2
