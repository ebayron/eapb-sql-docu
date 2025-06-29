DECLARE @ID VARCHAR(15);
DECLARE @DB SYSNAME;
DECLARE @Path NVARCHAR(200);
DECLARE @FullPath NVARCHAR(250);
DECLARE @Name NVARCHAR(100);
SET @ID = LEFT(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR, GETDATE(), 21), '-', ''), ' ', '_'), ':', ''), 15);
SET @DB = '<db_name>'; -- input database name
SET @Path = N'<back up location>'; -- input back up location
SET @FullPath = @Path + '\' + @DB + '_' + @ID + '_DIFF.bak';
SET @Name = @DB + '-Differential Database Backup';

BACKUP DATABASE @DB
	TO DISK = @FullPath
	WITH
		DIFFERENTIAL,
		NOFORMAT,
		INIT,
		NAME = @Name,
		SKIP,
		NOREWIND,
		NOUNLOAD,
		COMPRESSION,
		STATS = 10

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
GO