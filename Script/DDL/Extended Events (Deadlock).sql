CREATE EVENT SESSION [XE_Deadlocks] ON SERVER

ADD EVENT sqlserver.xml_deadlock_report(
    ACTION(sqlserver.database_name))

ADD TARGET package0.event_file(
SET filename=N'F:\Clean Up\AuditDeadlock.xel',
	max_file_size = (10),
	max_rollover_files=(5))
WITH (
	MAX_MEMORY=4096 KB,
	EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
	MAX_DISPATCH_LATENCY=15 SECONDS,
	MAX_EVENT_SIZE=0 KB,
	MEMORY_PARTITION_MODE=NONE,
	TRACK_CAUSALITY=OFF,
	STARTUP_STATE=ON);

-- Start the event session  
ALTER EVENT SESSION XE_Deadlocks ON SERVER  
STATE = start;