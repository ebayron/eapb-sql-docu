-- Query is across database
-- Query can be across servers (using registered servers)

DECLARE @sql NVARCHAR(MAX) = '';
DECLARE @db_id TINYINT = 4; -- Set to 0 if including system databases, SET to 4 to exclude them
DECLARE @object_name VARCHAR(20) = ''; -- Input empty string to view all

SELECT @sql = @sql + N' UNION ALL SELECT ' +
				CAST(d.database_id  as NVARCHAR(3)) + ' AS db_id, ' +
				QUOTENAME(d.name,'''') + ' AS db_name, 
				s.name COLLATE LATIN1_GENERAL_CI_AI AS schema_name,
				t.name COLLATE LATIN1_GENERAL_CI_AI AS table_name,
				t.object_id,
				t.type_desc,
				t.create_date,
				t.modify_date
			FROM ' + QUOTENAME(name) + N'.sys.tables t WITH(NOLOCK)
			INNER JOIN ' + QUOTENAME(name) + N'.sys.schemas s WITH(NOLOCK) ON t.schema_id = s.schema_id
			WHERE t.name LIKE ''%' + @object_name + '%'''
FROM sys.databases d
WHERE [state] = 0
	AND database_id > @db_id;

SELECT @sql = @sql + N' UNION ALL SELECT ' +
				CAST(d.database_id  as NVARCHAR(10)) + ' AS db_id, ' +
				QUOTENAME(d.name,'''') + ' AS db_name, 
				s.name COLLATE LATIN1_GENERAL_CI_AI AS schema_name,
				t.name COLLATE LATIN1_GENERAL_CI_AI AS table_name,
				t.object_id,
				t.type_desc,
				t.create_date,
				t.modify_date
			FROM ' + QUOTENAME(name) + N'.sys.views t WITH(NOLOCK)
			INNER JOIN ' + QUOTENAME(name) + N'.sys.schemas s WITH(NOLOCK) ON t.schema_id = s.schema_id
			WHERE t.name LIKE ''%' + @object_name + '%'''
FROM sys.databases d
WHERE [state] = 0
	AND database_id > @db_id;

SELECT @sql = SUBSTRING(@sql, 11, LEN(@sql)); -- Remove the first instance of ' UNION ALL '
SELECT @sql = @sql + ' ORDER BY db_name, type_desc, table_name'; -- Add ORDER BY in the last part of the statement
EXEC sp_executesql @sql;
GO