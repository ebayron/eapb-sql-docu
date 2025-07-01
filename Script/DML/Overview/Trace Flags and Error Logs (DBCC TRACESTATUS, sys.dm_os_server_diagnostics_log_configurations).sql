-- returns a list of all global trace flags that are enabled
DBCC TRACESTATUS(-1)

-- SQL Server error log
SELECT * -- max_size (GB)
FROM sys.dm_os_server_diagnostics_log_configurations;
