SELECT
	'KILL ' + CAST(spid AS VARCHAR(4)) AS killSQL, last_batch, hostname, *
FROM master..sysprocesses
WHERE spid > 50
	AND spid <> @@spid
	AND status NOT IN ('suspended','sleeping','dormant')
	--AND program_name NOT LIKE 'SQLAgent%'
	--AND (hostname LIKE '%api%' OR hostname LIKE '%web%')
	AND last_batch < DATEADD(mi, -11, GETDATE()) -- running for more than 11 minutes
ORDER BY last_batch