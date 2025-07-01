/*
	sys.objects does not show DDL triggers, because they are not schema-scoped.
	All triggers, both DML and DDL, are found in sys.triggers.
	sys.triggers supports a mixture of name-scoping rules for the various kinds of triggers.
*/

DECLARE @SQL NVARCHAR(MAX) = '';

SELECT @SQL = @SQL + ' UNION ALL 
	SELECT
		''' + [name] + ''' AS [DB Name],
		SCHEMA_NAME([schema_id]) AS [Schema Name], 
		o.[name] COLLATE SQL_Latin1_General_CP1_CI_AS AS [Object Name],
		o.[type_desc] AS [Object Type],
		p.parameter_id AS [Parameter ID],
		p.[name] COLLATE SQL_Latin1_General_CP1_CI_AS AS [Parameter Name],
		TYPE_NAME(p.user_type_id) AS [Parameter Data Type],
		p.max_length AS [Parameter Max Bytes],
		p.is_output AS [Is Output Parameter]
	FROM ' + [name] + '.sys.objects AS o
	INNER JOIN ' + [name] + '.sys.parameters AS p ON o.[object_id] = p.[object_id]'
FROM sys.databases
WHERE database_id > 4 -- exclude system databases
	AND [state] = 0 -- online database only
	AND is_distributor = 0 -- exclude distributor database

SELECT @SQL = RIGHT(@SQL, LEN(@SQL)-11)  + ' ORDER BY 1, 2, 3'

EXEC(@SQL)