SELECT
	tr.name AS trigger_name,
	SCHEMA_NAME(tb.schema_id) AS schema_name,
	tb.name AS table_name,
	tr.create_date,
	tr.modify_date
FROM sys.triggers tr
INNER JOIN sys.tables tb ON tr.parent_id = tb.object_id
ORDER BY 1