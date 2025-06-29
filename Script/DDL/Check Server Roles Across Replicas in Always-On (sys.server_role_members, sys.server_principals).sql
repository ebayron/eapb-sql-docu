-- run in registered server wherein clustered servers are in 1 group. manually identify and parallel results as per primary replica.
-- below query result shows user-defined users under sysadmin role and other server-roles, if any.
-- database roles should be parallel accross other replicas upon back-up and restore to secondary replicas.

SELECT
	r.name AS RoleName,
	m.name AS MemberName,
	'ALTER SERVER ROLE ' + r.name + ' ADD MEMBER [' + m.name + ']' AS script  
FROM sys.server_role_members s 
INNER JOIN sys.server_principals AS r ON s.role_principal_id = r.principal_id
INNER JOIN sys.server_principals AS m ON s.member_principal_id = m.principal_id
WHERE m.name NOT LIKE 'NT %' AND m.name <> 'sa'
ORDER BY 1;