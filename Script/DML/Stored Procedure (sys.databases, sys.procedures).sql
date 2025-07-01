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