-- T-SQL
SELECT sqlserver_start_time FROM sys.dm_os_sys_info
SELECT create_date FROM sys.databases WHERE name = 'tempdb'

# PowerShell
Systeminfo | find "System Boot Time" 


-- or look at CPU section in Task Manager