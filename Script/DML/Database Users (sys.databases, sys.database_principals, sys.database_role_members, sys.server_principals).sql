DECLARE @SQL NVARCHAR(MAX) = '';

SELECT @SQL = @SQL + ' UNION ALL 
	SELECT
		''' + [name] + ''' AS [DB Name],
		dp.[name] As [Database User],
		dp.[type_desc] AS [User Type],
		dp.default_schema_name AS [Default Schema Name],
		dp.create_date AS [Create Date],
		sp.[name] AS [Login],
		SUBSTRING(dr.database_roles, 1, LEN(dr.database_roles)-1) AS "Database Roles"
	FROM ' + [name] + '.sys.database_principals dp
	LEFT JOIN sys.server_principals sp ON dp.[sid] = sp.[sid]
	CROSS APPLY (
	SELECT
		p.[name] + '', ''
	FROM  ' + [name] + '.sys.database_principals p
	INNER JOIN ' + [name] + '.sys.database_role_members m ON p.principal_id = m.role_principal_id
	WHERE m.member_principal_id = dp.principal_id
	ORDER BY p.[name]
	FOR XML PATH ('''') ) dr (database_roles)
	WHERE dp.[type] NOT IN (''R'')
		AND dp.[name] NOT IN (''dbo'', ''guest'', ''INFORMATION_SCHEMA'', ''sys'')'
FROM sys.databases
WHERE database_id > 4 -- exclude system databases
	AND [state] = 0 -- online databases only

SELECT @SQL = RIGHT(@SQL, LEN(@SQL)-11) + ' ORDER BY 1'

EXEC(@SQL)