SELECT 
	@@SERVERNAME AS Server_Name, 
	create_date AS SQL_Server_Install_Date
FROM sys.server_principals WITH(NOLOCK)
WHERE [name] = N'NT AUTHORITY\SYSTEM'
	OR [name] = N'NT AUTHORITY\NETWORK SERVICE';