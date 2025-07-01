-- Query 1
SELECT * FROM [10.70.2.8].[master].[dbo].[sysdatabases]

-- Query 2
SELECT * FROM OPENQUERY ([CASH PORTAL], 'select 1 a from dual');