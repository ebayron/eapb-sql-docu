-- 1. sp_depends
EXEC sp_depends '[dbo].[GetCustomer]'

-- 2. sys.sysdepends
SELECT DISTINCT
	OBJECT_NAME(sd.id) AS SPname,
	ob.name AS TableorViewName
FROM sys.sysdepends sd
INNER JOIN sys.sysobjects o ON sd.id = o.id
INNER JOIN sys.sysobjects ob ON sd.depid = ob.id
	AND o.xtype = 'P'

-- 3. sys.all_sql_modules
SELECT
	OBJECT_NAME(object_id) AS objname,
	defitinition
FROM sys.all_sql_modules
WHERE definition LIKE '%getcustomer%'


-- note that #1 and #2 cross database objects will not appear here.

