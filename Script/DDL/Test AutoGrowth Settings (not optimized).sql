/* Execute before running the whole query
	SET STATISTICS IO OFF;
	SET STATISTICS TIME OFF;
*/

USE [master]

IF EXISTS (SELECT 1 FROM sys.databases WHERE [name] = 'AutoShrink_NotOptimized') DROP DATABASE [AutoShrink_NotOptimized]
GO

--DBCC TRACEON(3604,3605)

CREATE DATABASE [AutoShrink_NotOptimized]
	ON PRIMARY (
		NAME = N'AutoShrink_NotOptimized',
		FILENAME = N'D:\Microsoft SQL Server\SQL2016\MSSQL13.SQL2016\MSSQL\DATA\AutoShrink_NotOptimized.mdf',
		SIZE = 128MB,
		FILEGROWTH = 10MB)
	LOG ON (
		NAME = N'AutoShrink_NotOptimized_log',
		FILENAME = N'D:\Microsoft SQL Server\SQL2016\MSSQL13.SQL2016\MSSQL\DATA\AutoShrink_NotOptimized_log.ldf',
		SIZE = 128,
		FILEGROWTH = 10MB)
GO


SELECT
	d.[name] AS DBName,
	CAST((d.size * 8.00) / 1024 AS DECIMAL(9, 2)) AS InitialSizeMB,
	CASE
		WHEN d.growth = 0 THEN '0'
	ELSE
		CASE
			WHEN d.is_percent_growth = 0 THEN CAST(CAST((d.growth * 8.00) / 1024.00 AS DECIMAL(9, 2)) AS VARCHAR(20)) + ' MB'
		ELSE CAST(d.growth AS VARCHAR(3)) + '%'
		END
	END AS AutoGrowth
FROM AutoShrink_NotOptimized.sys.database_files d
LEFT JOIN AutoShrink_NotOptimized.sys.filegroups f ON d.data_space_id = f.data_space_id

SET NOCOUNT ON;
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT TOP 10000000 a.*, b.SalesOrderID AS "SalesOrderID2"  INTO AutoShrink_NotOptimized..Sales
FROM AdventureWorks2016.Sales.SalesOrderDetail a 
CROSS JOIN AdventureWorks2016.Sales.SalesOrderDetail b
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE [name] = 'AutoShrink_NotOptimized') DROP DATABASE AutoShrink_NotOptimized
GO

/*
Table 'SalesOrderDetail'. Scan count 2, logical reads 279, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Worktable'. Scan count 1, logical reads 270023, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 23905 ms,  elapsed time = 91950 ms.
*/