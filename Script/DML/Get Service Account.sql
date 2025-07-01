-- What service account is being used?
SELECT servicename, service_account
FROM sys.dm_server_services
