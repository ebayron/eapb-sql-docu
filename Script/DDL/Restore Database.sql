USE [master]

DECLARE @DB SYSNAME = 'db1';
DECLARE @SQL NVARCHAR(150) = '';

SET @SQL = 'ALTER DATABASE ' + @DB + ' SET SINGLE_USER WITH ROLLBACK IMMEDIATE' -- close active connections first
EXEC (@SQL);

RESTORE DATABASE @DB
FROM DISK = N'D:\BackUp\db1_20191209_113258_FULL.bak'
WITH
	-- MOVE N'DBwithAutoShrink' TO N'D:\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\DATA2\DBwithAutoShrink.mdf', -- move to a different location
	-- MOVE N'DBwithAutoShrink_log' TO N'L:\Log\Log2\DBwithAutoShrink_log.ldf', -- move to a different location
	NORECOVERY,
	REPLACE, -- Overwrite existing database
	FILE = 1

RESTORE DATABASE @DB
FROM DISK = N'D:\BackUp\db1_20191209_113444_DIFF.bak'
WITH
	NORECOVERY,
	FILE = 1

RESTORE LOG @DB
FROM DISK = N'D:\BackUp\db1_20191209_113502.trn'
WITH
	-- RESTRICTED_USER, -- Restrict access to the restored database
	-- KEEP_REPLICATION, -- Keep Replication State
	-- NORECOVERY, -- Recovery state option
	-- STANDBY = N'T:\BackUp\<db name>_RollbackUndo_2019-09-29_15-17-24.bak', -- Recovery state option
	NOUNLOAD,
	FILE = 1

SET @SQL = 'ALTER DATABASE ' + @DB + ' SET MULTI_USER' -- set connection back to Multi User
EXEC (@SQL);