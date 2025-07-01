DECLARE @sql NVARCHAR(MAX) = '';

SELECT @sql = @sql + N'
	SELECT
		c.table_catalog COLLATE LATIN1_GENERAL_CI_AI AS "DB Name",
		c.table_schema COLLATE LATIN1_GENERAL_CI_AI AS "Table Schema",
		c.table_name COLLATE LATIN1_GENERAL_CI_AI AS "Table Name",
		c.column_name COLLATE LATIN1_GENERAL_CI_AI AS "Column Name",
		c.ordinal_position AS "Ordinal Position",
		c.data_type COLLATE LATIN1_GENERAL_CI_AI AS "Data Type",
		c.character_maximum_length AS "Character Maximum Length",
		c.numeric_precision AS "Numeric Precision",
		c.numeric_scale AS "Numeric Scale",
		c.is_nullable COLLATE LATIN1_GENERAL_CI_AI AS "Is Nullable?",
		c.collation_name COLLATE LATIN1_GENERAL_CI_AI AS "Collation Name"
	FROM ' + QUOTENAME(name) + N'.information_schema.columns c WITH(NOLOCK) UNION ALL '
FROM sys.databases WITH(NOLOCK)
WHERE database_id > 4;

SELECT @sql = SUBSTRING(@sql, -9, LEN(@sql)); -- removes the last instance of ' UNION ALL '

EXEC sp_executesql @sql;
GO