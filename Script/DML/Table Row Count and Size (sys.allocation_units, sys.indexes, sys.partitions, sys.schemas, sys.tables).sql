SELECT 
    s.[name] AS "Schema Name",
    t.[name] AS "Table Name",
    p.[rows] AS "Row Counts",
    CAST(ROUND(((SUM(a.total_pages) * 8.00) / 1024 / 1024), 2) AS NUMERIC(36, 2)) AS "Total Space (GB)",
    CAST(ROUND(((SUM(a.total_pages) * 8.00) / 1024), 2) AS NUMERIC(36, 2)) AS "Total Space (MB)",
    CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8.00) / 1024, 2) AS NUMERIC(36, 2)) AS "Unused Space (MB)"
FROM sys.tables t
INNER JOIN sys.indexes i ON t.[object_id] = i.[object_id]
INNER JOIN sys.partitions p ON i.[object_id] = p.[object_id]
	AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON p.[partition_id] = a.container_id
LEFT OUTER JOIN sys.schemas s ON t.[schema_id] = s.[schema_id]
WHERE t.NAME NOT LIKE 'dt%' 
    AND t.is_ms_shipped = 0 -- exclude shipped objects
    AND i.OBJECT_ID > 255 -- exclude system-level tables
GROUP BY t.[name], s.[name], p.[rows]
ORDER BY 4 DESC