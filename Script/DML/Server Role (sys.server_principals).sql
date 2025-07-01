SELECT
	[name] AS "Login",
    [type_desc] AS "Login Type",
    create_date AS "Create Date",
    modify_date AS "Modify Date",
    is_disabled AS "Is Disabled?"
FROM sys.server_principals WITH(NOLOCK)
WHERE [type] = 'R' -- Server role
ORDER BY [name];