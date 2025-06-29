DECLARE @Reorganize FLOAT = 10;
DECLARE @Rebuild FLOAT = 30;
DECLARE @IsAutoExecute BIT = 0;
DECLARE @Script NVARCHAR(MAX) = '';
DECLARE @DB SYSNAME;

SELECT @DB = DB_ID();

IF OBJECT_ID('tempdb.dbo.#ReorganizeRebuildIndex') IS NOT NULL
	BEGIN
		DROP TABLE tempdb.dbo.#ReorganizeRebuildIndex
	END

SELECT
	SCHEMA_NAME(st.[schema_id]) AS [Schema Name],
	OBJECT_NAME(ps.[object_id]) AS [Table Name],
	si.[name] [Index Name],
	ps.avg_fragmentation_in_percent AS [Avg Fragmentation (%)],
	CASE
		WHEN ps.avg_fragmentation_in_percent >= @Rebuild THEN
			'ALTER INDEX [' + si.[name] + '] ON ['+ DB_NAME() + '].[' + SCHEMA_NAME(st.[schema_id]) + '].[' + OBJECT_NAME(ps.[object_id]) + '] REBUILD WITH (SORT_IN_TEMPDB = ON);'
		WHEN ps.avg_fragmentation_in_percent >= @Reorganize THEN 
			'ALTER INDEX [' + si.[name] + '] ON ['+ DB_NAME() + '].[' + SCHEMA_NAME(st.[schema_id]) + '].[' + OBJECT_NAME(ps.[object_id]) + '] REORGANIZE;'
	END AS [Script]
INTO #ReorganizeRebuildIndex
FROM sys.dm_db_index_physical_stats(@DB, NULL, NULL, NULL , NULL) ps
INNER JOIN sys.tables st WITH(NOLOCK) ON ps.[object_id] = st.[object_id]
INNER JOIN sys.indexes si WITH(NOLOCK) ON ps.[object_id] = si.[object_id]
	AND ps.index_id = si.index_id
WHERE st.is_ms_shipped = 0 -- exclude Microsoft objects
	AND si.index_id > 0 -- exclude heap tables
	AND ps.page_count > 1000 -- less than 1000 page counts is not worth processing
	AND ps.avg_fragmentation_in_percent >= @Reorganize;

IF @IsAutoExecute = 0
	BEGIN
		SELECT * FROM #ReorganizeRebuildIndex
	END
ELSE
	BEGIN
		SELECT @Script = @Script + SPACE(1) + Script
		FROM #ReorganizeRebuildIndex

		EXEC(@Script)
	END

DROP TABLE tempdb.dbo.#ReorganizeRebuildIndex