-- 1. CHECK IF FOREIGN KEYS ARE ENABLED OR DISABLED

SELECT 
    SCHEMA_NAME(SCHEMA_ID) AS SchemaName,
    OBJECT_NAME(parent_object_id) AS TableName,
    name AS ForeignKeyConstraintName,
    is_disabled
FROM sys.foreign_keys
ORDER BY is_disabled

-- 2. GENERATE SCRIPT TO DISABLE FOREIGN KEYS

IF OBJECT_ID('tempdb..#tmp') IS NOT NULL BEGIN DROP TABLE #tmp END
SELECT * INTO #tmp FROM (
SELECT
	'ALTER TABLE ' + '['+ SCHEMA_NAME(SCHEMA_ID) + '].['+ OBJECT_NAME(parent_object_id) 
     + ']'+ ' NOCHECK CONSTRAINT ' + '[' + name + ']' AS disableconstraintquery
FROM sys.foreign_keys
WHERE is_disabled = 0) a
GO
SELECT * FROM #tmp;

-- 3. GENERATE SCRIPT TO ENABLE FOREIGN KEYS

IF OBJECT_ID('tempdb..#tmp') IS NOT NULL BEGIN DROP TABLE #tmp END
SELECT * INTO #tmp FROM (
SELECT
	'ALTER TABLE ' + '['+ SCHEMA_NAME(SCHEMA_ID) + '].['+ OBJECT_NAME(parent_object_id) 
     + ']'+ ' CHECK CONSTRAINT ' + '[' + name + ']' AS disableconstraintquery
FROM sys.foreign_keys
WHERE is_disabled = 1) a
GO
SELECT * FROM #tmp;

-- 4. EXECUTE GENERATED SCRIPT

DECLARE @DynamicSQL NVARCHAR(MAX);
SET @DynamicSQL = '';

SELECT
	@DynamicSQL = @DynamicSQL + disableconstraintquery + ';' + CHAR(13)
FROM #tmp
SELECT @DynamicSQL;
EXEC sp_executesql @DynamicSQL;