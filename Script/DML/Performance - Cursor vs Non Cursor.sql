BEGIN
	SET NOCOUNT ON;

	DECLARE @DynamicSQL NVARCHAR(MAX);
	DECLARE @LinkedServer NVARCHAR(MAX);
	DECLARE @body VARCHAR(MAX);

	DECLARE @TempTable TABLE (
		DBName SYSNAME NULL,
		ProcName VARCHAR(100) NULL,
		CreateDate DATETIME2(0) NOT NULL
	);

	SET @LinkedServer = '';
	SET @DynamicSQL = N'
		DECLARE @DBName SYSNAME,
				@DynamicSQL NVARCHAR(MAX);

		CREATE TABLE #TempTable 
		(
			DBName SYSNAME NULL,
			ProcName VARCHAR(100) NULL,
			CreateDate DATETIME2(0) NOT NULL
		);

		DECLARE DBCursor CURSOR
		LOCAL FAST_FORWARD
		FOR SELECT name
			FROM sys.databases
			WHERE database_id > 4
			AND state = 0;

		OPEN DBCursor;
		FETCH NEXT FROM DBCursor INTO @DBName;

		WHILE @@FETCH_STATUS = 0
		BEGIN

			SET @DynamicSQL = N''USE '' + QUOTENAME(@DBName) + N''; '';
			SET @DynamicSQL = @DynamicSQL + 
			N''
				INSERT INTO #TempTable
				SELECT
					DB_NAME(),
					name,
					create_date
				FROM sys.procedures WITH(NOLOCK)
			'';

			EXEC (@DynamicSQL);

			FETCH NEXT FROM DBCursor INTO @DBName;
		END

		CLOSE DBCursor;
		DEALLOCATE DBCursor;

		SELECT
			*
		FROM #TempTable

		DROP TABLE #TempTable;'

	INSERT INTO @TempTable
	EXEC (@DynamicSQL)

	SELECT
		*
	FROM @TempTable
	ORDER BY 1, 2
END


GO

DECLARE @SQL NVARCHAR(MAX) = '';

SELECT @SQL = @SQL + 
	' UNION ALL SELECT
		''' + [name] + ''' AS [DB Name],
		name AS [Procedure Name],
		create_date AS [Create Date]
	FROM ' + [name] + '.sys.procedures WITH(NOLOCK)'
FROM sys.databases
WHERE database_id > 4
	AND [state] = 0

SELECT @SQL = RIGHT(@SQL, LEN(@SQL)-11) + ' ORDER BY 1, 2'

EXEC(@SQL)

/* Results:

Query 1 costs 67% in total
Query 2 costs 33% only

(When removing ORDER BY in Query 2)

Query 1 costs 70% in total
Query 2 costs 30% only

*/