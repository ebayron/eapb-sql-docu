SELECT
       SCHEMA_NAME(schema_id) AS SchemaName,
       OBJECT_NAME(parent_object_id) AS TableName,
       [type_desc],
	   create_date,
	   modify_date
FROM sys.objects
WHERE type_desc LIKE '%CONSTRAINT'
