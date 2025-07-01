SELECT 
	servicename,
    startup_type,
    startup_type_desc,
    service_account,
    --status,
    status_desc,
    --process_id,
    cluster_nodename,
	instant_file_initialization_enabled,
    filename
FROM sys.dm_server_services;
