DECLARE @target_data XML

SELECT
	@target_data = CAST(target_data AS XML)
FROM sys.dm_xe_sessions AS s
INNER JOIN sys.dm_xe_session_targets AS t ON t.event_session_address = s.[address]
WHERE s.[name] = 'XE_QueryTimeouts'
	AND t.target_name = 'pair_matching'

-- Query XML variable to get Target Execution information
--SELECT
--@target_data.value('(PairingTarget/@orphanCount)[1]', 'int') AS orphanCount,
--@target_data.value('(PairingTarget/@matchedCount)[1]', 'int') AS matchedCount,
--COALESCE(@target_data.value('(PairingTarget/@memoryPressureDroppedCount)[1]', 'int'),0) AS memoryPressureDroppedCount

-- Query the XML variable to get the Target Data
SELECT
	n.[value]('(event/action[@name="session_id"]/value)[1]', 'INT') AS session_id,
	n.[value]('(event/@name)[1]', 'VARCHAR(50)') AS event_name,
	n.[value]('(event/data[@name="statement"]/value)[1]', 'VARCHAR(8000)') AS [statement],
	--NULLIF(n.[value]('(event/action[@name="query_hash"]/value)[1]', 'NUMERIC(20)'), 0) AS query_hash_numeric,
	--n.[value]('(event/action[@name="tsql_stack"]/text)[1]', 'VARCHAR(MAX)') AS tsql_stack,
	DATEADD(hh, DATEDIFF(hh, GETUTCDATE(), CURRENT_TIMESTAMP), n.[value]('(event/@timestamp)[1]', 'DATETIME2')) AS datetime_local
FROM (
	SELECT td.query('.') as n
	FROM @target_data.nodes('PairingTarget/event') AS q(td)) as tab
WHERE n.value('(event/action[@name="session_id"]/value)[1]', 'int') <> @@SPID --Excluding this currently running query.