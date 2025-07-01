DECLARE @SQL NVARCHAR(MAX) = '';

SELECT @SQL = @SQL + '
	UNION ALL
	SELECT
		''' + [name] + ''' AS [DB Name],
		CAST(STATS_DATE(i.[object_id], index_id) AS DATETIME2(0)) AS [Statistics Last Updated],
		CAST(o.modify_date AS DATETIME2(0)) AS [Modify Date],
		SCHEMA_NAME(o.[schema_id]) AS [Schema Name],
		o.name AS [Table Name],
		i.name AS [Index Name],
		''UPDATE STATISTICS '' + ''[' + [name] + '].[''' + ' + SCHEMA_NAME(o.[schema_id]) + ' + '''].[''' + ' + o.[name] + '']'' + '' '' + i.[name] AS [Script]
	FROM ' + [name] + '.sys.indexes i WITH(NOLOCK)
	INNER JOIN ' + [name] + '.sys.objects o WITH(NOLOCK) ON i.[object_id] = o.[object_id]
	WHERE o.type_desc = ''USER_TABLE''
		AND STATS_DATE(i.[object_id], index_id) IS NOT NULL
		AND CAST(STATS_DATE(i.[object_id], index_id) AS DATETIME2(0)) < CAST(o.modify_date AS DATETIME2(0))'
FROM sys.databases
WHERE [state] = 0 -- online databases
	AND database_id > 4 -- system databases
	ANd is_distributor = 0 -- exclude distributor database

SELECT @SQL = @SQL + ' ORDER BY 2 DESC'
SELECT @SQL = RIGHT(@SQL, LEN(@SQL)-12)
EXEC(@SQL)

