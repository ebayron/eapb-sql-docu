/*
	Reference:
		https://www.mssqltips.com/sqlservertutorial/256/discovering-unused-indexes/
		https://basitaalishan.com/2012/07/06/find-the-size-of-index-in-sql-server/
	
	Notes:
	If you see indexes where there are no seeks, scans or lookups, but there are updates,
	this means that SQL Server has not used the index to satisfy a query but still needs to maintain the index.
	Remember that the data from these DMVs is reset when SQL Server is restarted.
	Make sure you have collected data for a long enough period of time to determine which indexes may be good candidates to be dropped.
*/

SET NOCOUNT ON

-- Get Server Up Time
DECLARE @int INT
DECLARE @serveruptime VARCHAR(50)

SELECT @int = DATEDIFF(SECOND,sqlserver_start_time,GETDATE()) FROM sys.dm_os_sys_info

SELECT @serveruptime =
	RIGHT('00' + RTRIM(LTRIM(CONVERT(CHAR(2), (@int / 86400)))), 2) + ':' +  --Days
	RIGHT('00' + RTRIM(LTRIM(CONVERT(CHAR(2), ((@int % 86400) / 3600)))), 2) + ':'+ -- Hours
	RIGHT('00' + RTRIM(LTRIM(CONVERT(CHAR(2), (((@int % 86400) % 3600)/60)))), 2) + ':'+ -- Minutes
	RIGHT('00' + RTRIM(LTRIM(CONVERT(CHAR(2), (((@int % 86400) % 3600) % 60)))), 2) -- Seconds

IF OBJECT_ID('tempdb.dbo.#tmp') IS NOT NULL BEGIN DROP TABLE #tmp END

SELECT * INTO #tmp FROM (
	SELECT DISTINCT
		i.name AS [Index Name], 
		SCHEMA_NAME(t.[schema_id]) AS [Schema Name],
		t.name AS [Table Name],
		-- OBJECT_NAME(s.[object_id]) AS ObjectName,
		s.user_seeks + s.user_scans + s.user_lookups AS [User Seeks, Scans, and Lookups], 
		s.user_updates AS [User Updates],
		-- p.[IndexSizeKB] AS [Index Size KB],
		SQRT(CAST(s.user_updates AS DECIMAL(9, 2)) / CAST(NULLIF(s.user_seeks + s.user_scans + s.user_lookups, 0) AS DECIMAL(9, 2))) AS [Rank],
		'DROP INDEX [' + i.[name] + '] ON ' + SCHEMA_NAME(t.[schema_id]) + '.' + OBJECT_NAME(s.[object_id]) AS [Drop Index Script]
	FROM sys.dm_db_index_usage_stats s
	INNER JOIN sys.indexes i ON i.[object_id] = s.[object_id]
		AND i.index_id = s.index_id 
	INNER JOIN sys.tables t ON i.[object_id] = t.[object_id]
	INNER JOIN sys.objects o ON i.[object_id] = o.[object_id]
	WHERE OBJECTPROPERTY(s.[object_id], 'IsUserTable') = 1
		AND s.database_id = DB_ID()
		AND i.is_primary_key = 0 -- exclude primary keys
		AND i.name IS NOT NULL -- exclude heaps
		AND i.[type] <> 1 -- exclude the clustered indexes
		AND o.is_ms_shipped = 0 -- exclude system objects
		AND o.[type] NOT IN ('F', 'UQ') -- exclude the foreign keys and unique contraints
		AND user_seeks + user_scans + user_lookups < user_updates -- Seeks, scans, and lookups is less than updates
) b

IF OBJECT_ID('tempdb.dbo.#tmp2') IS NOT NULL BEGIN DROP TABLE #tmp2 END

SELECT TOP 3 @serveruptime AS [Server Up Time (DD:HH:MM:SS)], GETDATE() AS [Date Generated], *
FROM #tmp
ORDER BY [Rank] DESC