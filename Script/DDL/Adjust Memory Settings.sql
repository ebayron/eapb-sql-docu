DECLARE @minMem INT = 4301 -- in MB
DECLARE @maxMem INT = 5530 -- in MB

EXEC sp_configure 'show advanced options', 1
RECONFIGURE

EXEC sp_configure 'min server memory (MB)'
EXEC sp_configure 'max server memory (MB)'

EXEC sp_configure 'min server memory', @minMem
RECONFIGURE

EXEC sp_configure 'max server memory', @maxMem
RECONFIGURE

EXEC sp_configure 'min server memory (MB)'
EXEC sp_configure 'max server memory (MB)'

-- observer config_value
