IF OBJECT_ID('tempdb.dbo.#temp1') IS NOT NULL DROP TABLE tempdb.dbo.#temp1
GO
IF OBJECT_ID('tempdb.dbo.#temp2') IS NOT NULL DROP TABLE tempdb.dbo.#temp2
GO

DECLARE @current_tracefilename VARCHAR(500);
DECLARE @0_tracefilename VARCHAR(500);
DECLARE @indx INT;

SELECT @current_tracefilename = [path]
FROM sys.traces
WHERE is_default = 1;

SET @current_tracefilename = REVERSE(@current_tracefilename);
SET @indx = PATINDEX('%\%', @current_tracefilename);
SET @current_tracefilename = REVERSE(@current_tracefilename);
SET @0_tracefilename = LEFT(@current_tracefilename, LEN(@current_tracefilename) - @indx) + '\log.trc';

SELECT
	t.StartTime, 
	t.DatabaseName AS "DBName", 
	te.[name] AS "EventName", 
	t.[Filename], 
	CAST(t.duration/1000.00/1000 AS DECIMAL(9, 2)) AS "Duration_S",
	(t.IntegerData * 8)/1024 AS "Growth_MB", 
	ApplicationName, 
	HostName, 
	LoginName
INTO #temp2
FROM ::fn_trace_gettable(@0_tracefilename, DEFAULT) t
		INNER JOIN sys.trace_events AS te ON t.EventClass = te.trace_event_id
WHERE te.trace_event_id >= 92
	AND te.trace_event_id <= 95

SELECT
	CONVERT(VARCHAR(10), StartTime, 120) AS StartTime,
	DBName,
	EventName,
	[FileName],
	COUNT(1) AS NoOfEvents,
	SUM(Growth_MB) AS TotalGrowthMB,
	SUM(Duration_S) AS TotalDurationS
INTO #temp1
FROM #temp2
GROUP BY
	CONVERT(VARCHAR(10), StartTime, 120),
	DBName,
	EventName,
	[FileName]
	
SELECT * FROM #temp1 ORDER BY 1 DESC, 2
SELECT * FROM #temp2 ORDER BY 1 DESC

IF OBJECT_ID('tempdb.dbo.#temp1') IS NOT NULL DROP TABLE tempdb.dbo.#temp1
GO
IF OBJECT_ID('tempdb.dbo.#temp2') IS NOT NULL DROP TABLE tempdb.dbo.#temp2
GO
