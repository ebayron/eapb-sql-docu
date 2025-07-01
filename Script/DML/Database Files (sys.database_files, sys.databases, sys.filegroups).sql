
DECLARE -- Declare variables.
	@SQL NVARCHAR(MAX),
	@DB SYSNAME;

IF OBJECT_ID(N'tempdb.dbo.#DatabaseFileSpace') IS NOT NULL DROP TABLE #DatabaseFileSpace; -- Drop temporary table if existing.
	
CREATE TABLE #DatabaseFileSpace( -- Create temporary table.
	DBName	SYSNAME,
	FGName SYSNAME NULL, -- Log file doesn't have a filegroup.
	PhysicalName SYSNAME,
	LogicalName	SYSNAME,
	CurrentSizeMB DECIMAL(12, 2),
	SpaceUsedMB	DECIMAL(12, 2),
	FreeSpaceMB	DECIMAL(12, 2),
	AutoGrowth VARCHAR(15),
	MaxSize VARCHAR(15));
	
DECLARE DatabaseList CURSOR LOCAL FAST_FORWARD FOR
	SELECT name
	FROM sys.databases
	WHERE [state] = 0; -- Only online databases.

OPEN DatabaseList;

WHILE 1 = 1
	BEGIN
		FETCH NEXT FROM DatabaseList INTO @DB;
		
		IF @@FETCH_STATUS = -1 BREAK; -- Stop loop if no more rows to fetch.
		
		SET @SQL = N'USE '
			+ QUOTENAME(@DB)
			+ N' INSERT INTO #DatabaseFileSpace
		SELECT
			DB_NAME(),
			f.name,
			d.physical_name,
			d.name,
			CAST((d.size * 8.00) / 1024 AS DECIMAL(9, 2)),
			CAST((FILEPROPERTY(d.name, ''SpaceUsed'') * 8.00) / 1024 AS DECIMAL(9, 2)),
			CAST(((d.size - FILEPROPERTY(d.name, ''SpaceUsed'')) * 8.00) / 1024 AS DECIMAL(9, 2)),
			CASE
				WHEN d.growth = 0 THEN ''0''
				ELSE
					CASE
						WHEN d.is_percent_growth = 0 THEN CAST(CAST((d.growth * 8.00) / 1024.00 AS DECIMAL(9, 2)) AS VARCHAR(20)) + '' MB''
						ELSE CAST(d.growth AS VARCHAR(3)) + ''%''
					END
			END,
			CASE d.max_size
				WHEN -1 THEN ''Unlimited''
				WHEN 0 THEN ''0''
				ELSE CAST(CAST((d.max_size * 8.00) / 1024 /1024 AS DECIMAL(9, 2)) AS VARCHAR(20)) + '' GB''
			END
		FROM sys.database_files d WITH(NOLOCK)
		LEFT JOIN sys.filegroups f WITH(NOLOCK) ON d.data_space_id = f.data_space_id';

		EXECUTE(@SQL); -- Execute dynamic SQL which will insert into the temporary table.
	
	END

CLOSE DatabaseList;
DEALLOCATE DatabaseList;

SELECT
	*,
	'USE ' + DBName + ' DBCC SHRINKFILE ('''+ LogicalName + ''', ' + CAST(CEILING(SpaceUsedMB) AS VARCHAR(10)) + ') -- Current Size is ' + CAST(CEILING(CurrentSizeMB) AS VARCHAR(10)) + ''
FROM #DatabaseFileSpace
-- WHERE PhysicalName LIKE 'T%' 
ORDER BY FreeSpaceMB DESC;

DROP TABLE #DatabaseFileSpace;;
GO

/*
	If cannot SHRINK, check LOG_REUSE_WAIT_DESC execute:
	
	SELECT * FROM sys.databases.

	Top reasons why error occurs:
		1. Transaction Log
		2. Replication
		3. Always On

	If error is due to transaction log, back up transaction log first, then immediately run DBCC SHRINKFILE.
	If error is replication, either pause replication of fix issue in Log Agent.
	If error is Always On, either remove Always On configuration or fix issue in synchronization of logs.
*/