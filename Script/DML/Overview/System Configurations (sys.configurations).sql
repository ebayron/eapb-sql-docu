
SELECT * INTO #configurations
FROM sys.configurations
WHERE configuration_id IN (109, 117, 400, 503, 518, 1519, 1520, 1535, 1538, 1539, 1581, 16390, 16391);

SELECT [name], [description], [value], configuration_id
FROM #configurations
ORDER BY name

SELECT c.[name], c.[description], c.[value], c.configuration_id
FROM sys.configurations c
LEFT JOIN #configurations t ON c.configuration_id = t.configuration_id
WHERE t.configuration_id IS NULL
	AND c.configuration_id NOT IN (1543, 1544)
 ORDER BY c.name

DROP TABLE #configurations

/* BEST PRACTICE

EXEC sp_configure 'show advanced option', '1'; 
RECONFIGURE;
EXEC sp_configure @configname = 'optimize for ad hoc workloads', @configvalue = '1'-- need service restart ?
RECONFIGURE
EXEC sp_configure 'show advanced option', '0';
RECONFIGURE;
EXEC sp_configure 'show advanced option', '1'; 
RECONFIGURE;
EXEC sp_configure @configname = 'fill factor (%)', @configvalue = '90' -- need service restart
RECONFIGURE;
EXEC sp_configure 'show advanced option', '0';
RECONFIGURE;
*/