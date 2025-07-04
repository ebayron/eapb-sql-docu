SELECT
	j.name AS "Job Name",
	h.[message] AS "Error Message",
	CAST(CAST(CAST(CAST(h.run_date AS VARCHAR(8)) AS DATE) AS VARCHAR(10)) + SPACE(1) + STUFF(STUFF(RIGHT(REPLICATE('0', 2) + CAST(h.run_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':') AS DATETIME2(0)) AS "Run Date",
	STUFF(STUFF(STUFF(RIGHT(REPLICATE('0', 8) + CAST(h.run_duration AS VARCHAR(8)), 8), 3, 0, ':'), 6, 0, ':'), 9, 0, ':') AS "Run Duration (dd:hh:mm:ss)",
	(SELECT CAST(CAST(CAST(CAST(h3.run_date AS VARCHAR(8)) AS DATE) AS VARCHAR(10)) + SPACE(1) + STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CAST(h3.run_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':') AS DATETIME2(0)) FROM msdb.dbo.sysjobhistory h3 WHERE instance_id = (SELECT MAX(h2.instance_id) FROM msdb.dbo.sysjobhistory h2 WHERE h.job_id = h2.job_id AND h.step_id = h2.step_id AND h2.run_status = 1)) AS "Last Success Run Date",
	CASE h.run_status
		WHEN 0 THEN 'Failed'
		WHEN 1 THEN 'Succeeded'
		WHEN 2 THEN 'Retry'
		WHEN 3 THEN 'Canceled'
		WHEN 4 THEN 'In Progress'
		ELSE CAST(h.run_status AS CHAR(1))
	END AS "Run Status"
FROM msdb.dbo.sysjobs j WITH(NOLOCK)
INNER JOIN msdb.dbo.sysjobhistory h WITH(NOLOCK) ON j.job_id = h.job_id
WHERE h.run_status NOT IN (1, 2, 4)
	AND h.step_name <> '(Job outcome)'
--	AND CAST(CAST(CAST(CAST(h.run_date AS VARCHAR(8)) AS DATE) AS VARCHAR(10)) + SPACE(1) + STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CAST(h.run_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':') AS DATETIME) BETWEEN GETDATE() - CAST('00:30' AS DATETIME) AND GETDATE()  -- failed jobs on the last 30 minutes.
ORDER BY run_date DESC