SELECT
	p.[name] AS "Login",
    p.[type_desc] AS "Login Type",
    l.password_hash AS "Password Hash",
    p.create_date AS "Create Date",
    p.modify_date AS "Modify Date",
    p.is_disabled AS "Is Disabled?",
	SUBSTRING(r.server_roles, 1, LEN(r.server_roles)-1) AS "Server Roles"
FROM sys.server_principals p
LEFT JOIN sys.sql_logins l ON p.principal_id = l.principal_id
CROSS APPLY (
	SELECT
		r.[name] + ', '
	FROM  sys.server_principals r
	INNER JOIN sys.server_role_members m ON r.principal_id = m.role_principal_id
	WHERE m.member_principal_id = p.principal_id
	ORDER BY r.[name]
	FOR XML PATH ('') ) r (server_roles)

WHERE p.[type] <> 'R' -- Server role
	AND p.[name] NOT LIKE '##MS_%' -- Built-In/Service Accounts 
	AND p.[name] NOT LIKE 'NT %' -- Built-In/Service Accounts 
ORDER BY p.[name];

