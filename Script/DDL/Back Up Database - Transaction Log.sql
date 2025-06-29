DECLARE @ID VARCHAR(15);
DECLARE @DB SYSNAME;
DECLARE @Path NVARCHAR(200);
DECLARE @FullPath NVARCHAR(250);
DECLARE @Name NVARCHAR(100);
SET @ID = LEFT(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR, GETDATE(), 21), '-', ''), ' ', '_'), ':', ''), 15);
SET @DB = '<db_name>'; -- input database name
SET @Path = N'<back up location>'; -- input back up location
SET @FullPath = @Path + '\' + @DB + '_' + @ID + '.trn';
SET @Name = @DB + '-Transactional Log Database Backup';

IF EXISTS ( --Back Up Database
	SELECT 1
	FROM master.sys.databases
	WHERE state_desc = 'ONLINE' AND name = @DB)

	BEGIN
		BACKUP LOG @DB
			TO DISK = @FullPath
			WITH
				NOFORMAT,
				INIT,
				NAME = @Name,
				SKIP,
				NOREWIND,
				NOUNLOAD,
				COMPRESSION,
				STATS = 10
	END
ELSE
	BEGIN
		RAISERROR('Database is not ONLINE.', 16, 1)
	END

IF EXISTS ( --Verify Back Up
	SELECT 1
	FROM master.sys.databases
	WHERE state_desc = 'ONLINE' AND name = @DB)

	BEGIN
		DECLARE @backupSetId AS INT
			SELECT @backupSetId = position
			FROM msdb.dbo.backupset
			WHERE database_name = @DB
				AND backup_set_id = (SELECT
										MAX(backup_set_id)
									 FROM msdb..backupset
									 WHERE database_name = @DB)
		DECLARE @ErrorMsg NVARCHAR(150);
		SET @ErrorMsg = N'Verify failed. Backup information for database ' + @DB + ' not found.';

		IF @backupSetId IS NULL
			BEGIN
				RAISERROR(@ErrorMsg, 16, 1)
			END

		RESTORE VERIFYONLY FROM DISK = @FullPath
		WITH FILE = @backupSetId,
		NOUNLOAD,
		NOREWIND
	END
ELSE
	BEGIN
		RAISERROR('Database is not ONLINE.', 16, 1)
	END
	
/* Common Issue:
- Database is in Simple Recovery mode.
*/