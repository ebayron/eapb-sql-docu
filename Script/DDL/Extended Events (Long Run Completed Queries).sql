CREATE EVENT SESSION [XE_LongRunCompletedQueries] ON SERVER

ADD EVENT sqlserver.sp_statement_completed (
	ACTION (
		package0.collect_system_time,
		sqlserver.client_app_name,
		sqlserver.client_hostname,
		sqlserver.[database_name],
		sqlserver.plan_handle,
		sqlserver.query_hash,
		sqlserver.session_id)
	WHERE duration > 1800000000),  -- longer than 30 minutes

ADD EVENT sqlserver.sql_statement_completed (
	ACTION (
		package0.collect_system_time,
		sqlserver.client_app_name,
		sqlserver.client_hostname,
		sqlserver.[database_name],
		sqlserver.plan_handle,
		sqlserver.query_hash,
		sqlserver.session_id)
	WHERE duration > 1800000000) -- longer than 30 minutes

ADD TARGET package0.ring_buffer(
	SET max_events_limit = (0 /*unlimited*/),
	max_memory=(1048576 /*1 GB*/))
WITH (
	STARTUP_STATE = OFF,
	MAX_DISPATCH_LATENCY = 5SECONDS)

/*
5000000 - 5 seconds
60000000 - 1 minute
600000000 - 10 minutes
1800000000 - 30 minutes
*/

-- Start the event session  
ALTER EVENT SESSION XE_LongRunCompletedQueries ON SERVER  
STATE = start;
