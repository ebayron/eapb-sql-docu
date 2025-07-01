-- Query is across database
-- Query is across servers (using registered servers)
-- WHERE clause can be added in lines 20 and 36 if necessary

DECLARE @sql NVARCHAR(MAX);
DECLARE @db_id TINYINT;
SET @db_id = 4; -- Set to 0 if including system databases, SET to 4 to exclude them
SET @sql = '';
SELECT @sql = @sql + N' UNION ALL SELECT ' +
				QUOTENAME(d.name,'''') + ' AS db_name,
				t.type_desc, 
				s.name COLLATE LATIN1_GENERAL_CI_AI AS schema_name,
				t.name COLLATE LATIN1_GENERAL_CI_AI AS table_name,
				t.object_id,
				t.create_date,
				t.modify_date
			FROM ' + QUOTENAME(name) + N'.sys.tables t WITH(NOLOCK)
			INNER JOIN ' + QUOTENAME(name) + N'.sys.schemas s WITH(NOLOCK) ON t.schema_id = s.schema_id
			
			'
FROM sys.databases d
WHERE database_id > @db_id;

SELECT @sql = @sql + N' UNION ALL SELECT ' +
				QUOTENAME(d.name,'''') + ' AS db_name, 
				t.type_desc,
				s.name COLLATE LATIN1_GENERAL_CI_AI AS schema_name,
				t.name COLLATE LATIN1_GENERAL_CI_AI AS table_name,
				t.object_id,
				t.create_date,
				t.modify_date
			FROM ' + QUOTENAME(name) + N'.sys.views t WITH(NOLOCK)
			INNER JOIN ' + QUOTENAME(name) + N'.sys.schemas s WITH(NOLOCK) ON t.schema_id = s.schema_id
			
			'
FROM sys.databases d
WHERE database_id > @db_id;

SELECT @sql = SUBSTRING(@sql, 11, LEN(@sql)); -- Remove the first instance of ' UNION ALL '
SELECT @sql = @sql + ' ORDER BY 1, 2, 3, 4'; -- Add ORDER BY in the last part of the statement
EXEC sp_executesql @sql;
GO
