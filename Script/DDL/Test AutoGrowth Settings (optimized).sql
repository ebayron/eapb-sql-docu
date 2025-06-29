/* Execute before running the whole query
	SET STATISTICS IO OFF;
	SET STATISTICS TIME OFF;
*/

USE [master]

IF EXISTS (SELECT 1 FROM sys.databases WHERE [name] = 'AutoShrink_Optimized') DROP DATABASE [AutoShrink_Optimized]
GO

CREATE DATABASE [AutoShrink_Optimized]
	ON PRIMARY (
		NAME = N'AutoShrink_Optimized',
		FILENAME = N'D:\Microsoft SQL Server\SQL2016\MSSQL13.SQL2016\MSSQL\DATA\AutoShrink_Optimized.mdf',
		SIZE = 2048MB,
		FILEGROWTH = 2048MB)
	LOG ON (
		NAME = N'AutoShrink_NotOptimized_log',
		FILENAME = N'D:\Microsoft SQL Server\SQL2016\MSSQL13.SQL2016\MSSQL\DATA\AutoShrink_Optimized.ldf',
		SIZE = 2048MB,
		FILEGROWTH = 2048MB)
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
FROM AutoShrink_Optimized.sys.database_files d
LEFT JOIN AutoShrink_Optimized.sys.filegroups f ON d.data_space_id = f.data_space_id
GO

SET NOCOUNT ON;
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT TOP 10000000 a.*, b.SalesOrderID AS "SalesOrderID2"  INTO AutoShrink_Optimized..Sales
FROM AdventureWorks2016.Sales.SalesOrderDetail a 
CROSS JOIN AdventureWorks2016.Sales.SalesOrderDetail b
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE [name] = 'AutoShrink_Optimized') DROP DATABASE AutoShrink_Optimized
GO

/*
Table 'SalesOrderDetail'. Scan count 2, logical reads 279, physical reads 4, read-ahead reads 302, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Worktable'. Scan count 1, logical reads 270023, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 20967 ms,  elapsed time = 26343 ms.
*/