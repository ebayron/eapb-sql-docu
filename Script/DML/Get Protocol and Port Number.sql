-- Below query will show a distinct list of protocols and its used port number that are currently being used by the sessions.

SELECT DISTINCT
	net_transport,
	local_tcp_port
FROM sys.dm_exec_connections