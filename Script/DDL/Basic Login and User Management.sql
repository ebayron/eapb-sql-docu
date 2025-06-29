USE [master]
GO

/* LOGIN */

CREATE LOGIN [<domain user>] -- Windows Authentication
FROM WINDOWS
WITH
	DEFAULT_DATABASE = [<db_name>],
	DEFAULT_LANGUAGE = [us_english]
GO

CREATE LOGIN [<SQL user>] -- SQL Server Authentication
WITH
	PASSWORD=N'<pass>',
	DEFAULT_DATABASE = [<db_name>],
	DEFAULT_LANGUAGE = [us_english]
GO

/* SERVER ROLE */

ALTER SERVER ROLE [<server role>]
ADD MEMBER [<login>] -- define server role
GO

/* USER MAPPING */

USE [<db_name>]
GO

CREATE USER [<db_user>]
FOR LOGIN [<login>] -- can be same name
GO

/* DATABASE ROLE */

USE [<db_name>]
GO

ALTER ROLE [<database role>]
ADD MEMBER [<database user>]
GO

/* Securables */
GRANT CONNECT SQL TO [<login>]
GO

DENY CONNECT SQL TO [<login>]
GO

ALTER LOGIN [<login>] DISABLE
GO
