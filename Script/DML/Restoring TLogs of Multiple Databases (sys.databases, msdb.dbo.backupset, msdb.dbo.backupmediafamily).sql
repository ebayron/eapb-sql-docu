--usefule for AG restoration

DECLARE -- Declare variables.
    @SQL NVARCHAR(MAX),
    @DB SYSNAME;

IF OBJECT_ID(N'tempdb.dbo.#RestoreTLogs') IS NOT NULL
DROP TABLE #RestoreTLogs; -- Drop temporary table if existing.

CREATE TABLE #RestoreTLogs( -- Create temporary table.
    db SYSNAME NOT NULL,
    script NVARCHAR(600) NOT NULL,
    physical_device_name NVARCHAR(200) NOT NULL,
    backup_start_date DATETIME2 NOT NULL,
    backup_type CHAR(4) NOT NULL,
    server_name SYSNAME,
    recovery_model NVARCHAR(60) NOT NULL,
    username NVARCHAR(128) NOT NULL);

DECLARE DatabaseList CURSOR LOCAL FAST_FORWARD FOR
    SELECT name
    FROM sys.databases
    WHERE database_id > 5 -- change this as per requirement

OPEN DatabaseList;

WHILE 1 = 1
    BEGIN
        FETCH NEXT FROM DatabaseList INTO @DB;

        IF @@FETCH_STATUS = -1 BREAK; -- Stop loop if no more rows to fetch.

        SET @SQL = N'USE '
            + QUOTENAME(@DB)
            + N' INSERT INTO #RestoreTLogs

        SELECT 
            s.database_name, 
            ''RESTORE ''+ CASE s.[type] WHEN ''L'' THEN ''LOG'' ELSE ''DATABASE'' END +'' '' + DB_NAME() + '' FROM DISK = N'''''' + REPLACE(m.physical_device_name, SUBSTRING(m.physical_device_name, 1, 2),''\\'' +  RTRIM(CONVERT(char(30),SERVERPROPERTY(''MachineName''))) + ''\'' + SUBSTRING(m.physical_device_name, 1, 1) + ''$'') + '''''' WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  STATS = 5'',
            m.physical_Device_name,
            s.backup_start_date,
            s.[type],
            s.server_name,
            s.recovery_model,
            s.user_name
        FROM msdb.dbo.backupset s 
        INNER JOIN msdb.dbo.backupmediafamily m ON s.media_set_id = m.media_set_id
        WHERE s.database_name = DB_NAME() -- Remove this line for all the database
           -- AND s.[type]  = ''L''
            AND backup_start_date > DATEADD(HOUR, -5, GETDATE())'

        --SELECT @SQL -- used when troubleshooting and testing instead of using EXECUTE(@SQL) below
        EXECUTE(@SQL); -- Execute dynamic SQL which will insert into the temporary table.
    END

CLOSE DatabaseList;
DEALLOCATE DatabaseList;

SELECT * FROM #RestoreTLogs
ORDER BY db, backup_start_date;

DROP TABLE #RestoreTLogs;
GO



/*
-- Use this script to specify a single database to avoid errors when the database is already in single_user mode

USE master

DECLARE @dbname AS SYSNAME = 'admin'

 SELECT 
	s.database_name, 
	'RESTORE '+ CASE s.[type] WHEN 'L' THEN 'LOG' ELSE 'DATABASE' END +' ' + @dbname + ' FROM DISK = N''' + REPLACE(m.physical_device_name, SUBSTRING(m.physical_device_name, 1, 2),'\\' +  RTRIM(CONVERT(char(30),SERVERPROPERTY('MachineName'))) + '\' + SUBSTRING(m.physical_device_name, 1, 1) + '$') + ''' WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  STATS = 5',
	m.physical_Device_name,
	s.backup_start_date,
	s.[type],
	s.server_name,
	s.recovery_model,
	s.user_name
FROM msdb.dbo.backupset s 
INNER JOIN msdb.dbo.backupmediafamily m ON s.media_set_id = m.media_set_id
WHERE s.database_name =  @dbname
	AND backup_start_date > DATEADD(HOUR, -5, GETDATE())
*/