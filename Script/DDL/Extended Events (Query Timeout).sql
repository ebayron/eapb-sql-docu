CREATE EVENT SESSION [XE_QueryTimeouts] ON SERVER

ADD EVENT sqlserver.sql_statement_completed (
	ACTION (
		sqlserver.session_id,
		sqlserver.query_hash,
		sqlserver.tsql_stack)),
	
ADD EVENT sqlserver.sql_statement_starting (
	ACTION (
		sqlserver.session_id,
		sqlserver.query_hash,
		sqlserver.tsql_stack))

ADD TARGET package0.pair_matching (
	SET
		begin_event = 'sqlserver.sql_statement_starting',
		begin_matching_actions = 'sqlserver.session_id, sqlserver.tsql_stack',
		end_event = 'sqlserver.sql_statement_completed',
		end_matching_actions = 'sqlserver.session_id, sqlserver.tsql_stack',
		respond_to_memory_pressure = 0)

WITH (
	MAX_DISPATCH_LATENCY = 5 SECONDS,
	TRACK_CAUSALITY = ON,
	STARTUP_STATE = OFF)

-- Start the event session  
ALTER EVENT SESSION XE_QueryTimeouts ON SERVER  
STATE = start;
