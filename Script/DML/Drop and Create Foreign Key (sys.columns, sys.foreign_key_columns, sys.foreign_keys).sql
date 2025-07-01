/*
Notes:

Step 1: Generate the script that will create the foreign key constraints.
Step 2: Generate the script that will drop the constrains.
Step 3: Run Step 2 to drop all foreign key constraints.
Step 4: Perform any maintenance.
Step 5: Run Step 1 to recreate all foreign key constraints.
*/

/* GENERATE CREATE FOREIGN KEY SCRIPT */

IF OBJECT_ID('tempdb..#tmp') IS NOT NULL BEGIN DROP TABLE #tmp END
GO

WITH cte_fk
AS (
	SELECT
		DB_NAME() AS DBName,
		OBJECT_SCHEMA_NAME(fk.parent_object_id) AS ParentSchemaName,
		OBJECT_NAME(fk.parent_object_id) AS ParentTableName,
		OBJECT_SCHEMA_NAME(fk.referenced_object_id) AS ReferenceSchemaName,
		OBJECT_NAME(fk.referenced_object_id) AS ReferenceTableName,
		fk.name AS ForeignKeyConstraintName,
		c.name AS RefColumnName,
		cf.name AS ParentColumnList,
		fk.is_not_trusted AS IsNotTrusted,
		fk.delete_referential_action AS DeleteReferenceAction,
		fk.update_referential_action AS UpdateReferenceAction,
		fk.is_not_for_replication AS IsNotForReplication
	FROM sys.foreign_keys AS fk
	INNER JOIN sys.foreign_key_columns AS fkc ON fk.[object_id] = fkc.constraint_object_id
	INNER JOIN sys.columns c ON c.[object_id] = fkc.referenced_object_id
		AND c.column_id = fkc.referenced_column_id
	INNER JOIN sys.columns cf ON cf.[object_id] = fkc.parent_object_id
		AND cf.column_id = fkc.parent_column_id
	WHERE fk.is_ms_shipped = 0
)
	SELECT * INTO #tmp FROM (
	SELECT DISTINCT
		'ALTER TABLE [' + DBName + '].[' + ParentSchemaName + '].[' + ParentTableName + ']'
		+ CASE IsNotTrusted
			WHEN 0 THEN ' WITH CHECK'
            ELSE ' WITH NOCHECK'
          END
		+ ' ADD CONSTRAINT ' + ForeignKeyConstraintName
		+ ' FOREIGN KEY ('
		+ STUFF((SELECT ',' + ParentColumnList
				 FROM cte_fk i
				 WHERE i.ForeignKeyConstraintName = o.ForeignKeyConstraintName
					AND i.ParentSchemaName = o.ParentSchemaName
					AND i.ParentTableName = o.ParentTableName
					AND i.ReferenceTableName = o.ReferenceTableName
				 FOR XML PATH('')), 1, 1, '')
		+ ') REFERENCES ' + '['
		+ DBName + '].[' + ReferenceSchemaName + '].[' + ReferenceTableName + '] ('
		+ STUFF((SELECT ',' + RefColumnName
				 FROM cte_fk i
				 WHERE i.ForeignKeyConstraintName = o.ForeignKeyConstraintName
					AND i.ParentSchemaName = o.ParentSchemaName
					AND i.ParentTableName = o.ParentTableName
					AND i.ReferenceTableName = o.ReferenceTableName
				 FOR XML PATH('')), 1, 1, '') + ')'
		+ ' ON UPDATE '
		+ CASE UpdateReferenceAction
			WHEN 0 THEN 'NO ACTION'
			WHEN 1 THEN 'CASCADE'
			WHEN 2 THEN 'SET NULL'
			ELSE 'SET DEFAULT '
		  END
		+ ' ON DELETE '
		+ CASE DeleteReferenceAction
			WHEN 0 THEN 'NO ACTION'
			WHEN 1 THEN 'CASCADE'
			WHEN 2 THEN 'SET NULL'
			ELSE 'SET DEFAULT'
		  END
		+ CASE IsNotForReplication
			WHEN 1 THEN ' NOT FOR REPLICATION '
			ELSE ''
		  END AS Script
	FROM cte_fk o) a

-- EXECUTE SCRIPT
DECLARE @DynamicSQL NVARCHAR(MAX);
SET @DynamicSQL = '';

SELECT
	@DynamicSQL = @DynamicSQL + Script + ';' + CHAR(13)
FROM #tmp

SELECT @DynamicSQL FOR XML PATH;

DROP TABLE #tmp


/* GENERATE DROP FOREIGN KEY SCRIPT */

SELECT
    'ALTER TABLE ' 
    +  OBJECT_SCHEMA_NAME(parent_object_id) 
    +'.[' + OBJECT_NAME(parent_object_id) 
    +'] DROP CONSTRAINT ' 
    + name as DropFKConstraint
FROM sys.foreign_keys


