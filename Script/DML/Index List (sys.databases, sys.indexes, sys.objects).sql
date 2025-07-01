DECLARE @SQL NVARCHAR(MAX) = '';

SELECT @SQL = @SQL + ' UNION ALL SELECT
	DB_NAME(' + CAST(database_id AS CHAR(2)) + ') AS db_name,
    CASE
		WHEN o.[type] = ''U'' THEN ''Table''
        WHEN o.[type] = ''V'' THEN ''View''
    END AS [object_type],
	OBJECT_SCHEMA_NAME(o.object_id) AS schema_name,
	o.name AS table_view_name,
	i.[name] AS index_name,
    CASE
		WHEN i.[type] = 1 THEN ''Clustered index''
        WHEN i.[type] = 2 THEN ''Nonclustered unique index''
        WHEN i.[type] = 3 THEN ''XML index''
        WHEN i.[type] = 4 THEN ''Spatial index''
        WHEN i.[type] = 5 THEN ''Clustered columnstore index''
        WHEN i.[type] = 6 THEN ''Nonclustered columnstore index''
        WHEN i.[type] = 7 THEN ''Nonclustered hash index''
    END AS index_type,
	i.is_unique,
	i.is_primary_key,
	i.fill_factor,
	i.is_disabled,
	i.has_filter,
	SUBSTRING(c.column_names, 1, LEN(c.column_names)-1) AS column_names,
	CAST(s.avg_fragmentation_in_percent AS DECIMAL(9,2)) AS avg_fragmentation_in_percent,
	s.page_count,
	o.object_id AS object_id
FROM [' + name + '].sys.indexes i
INNER JOIN [' + name + '].sys.objects o ON i.[object_id] = o.[object_id]
INNER JOIN sys.dm_db_index_physical_stats (' + CAST(database_id AS NCHAR(2)) + ', NULL, NULL, NULL, NULL) AS s
	ON o.[object_id] = s.[object_id]
	AND i.[object_id] = s.[object_id]
	AND i.index_id = s.index_id
CROSS APPLY (
	SELECT col.[name] + '', ''
	FROM sys.index_columns ic
	INNER JOIN sys.columns col ON ic.[object_id] = col.[object_id]
		AND ic.column_id = col.column_id
	WHERE ic.[object_id] = o.[object_id]
		AND ic.index_id = i.index_id
	ORDER BY col.column_id
	FOR XML PATH ('''') ) c (column_names)
WHERE s.alloc_unit_type_desc = ''IN_ROW_DATA'' -- usually where the data resides
	AND i.index_id > 0' -- Excludes Heap
FROM sys.databases
WHERE [state] = 0
	AND database_id > 4 -- user databases only

SELECT @SQL = SUBSTRING(@SQL, 11, LEN(@SQL)); -- removes the first instance of ' UNION ALL '
SELECT @SQL = @SQL + ' ORDER BY 1, 2, 3, 4, 5'; -- adds sorting on the query

EXEC (@SQL)
