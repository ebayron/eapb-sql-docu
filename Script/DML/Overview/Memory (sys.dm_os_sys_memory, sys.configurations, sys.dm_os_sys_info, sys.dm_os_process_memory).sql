-- Get available memory on the system
SELECT 
    CAST(total_physical_memory_kb / 1024 / 1024.0 AS DECIMAL(9, 2)) AS Total_Physical_Memory_GB,
    CAST(available_physical_memory_kb / 1024 / 1024.0 AS DECIMAL(9, 2)) AS Available_Physical_Memory_GB -- Free memory available for the OS & other apps.
    --total_page_file_kb / 1024 / 1024 AS Total_Page_File_GB,
    --available_page_file_kb / 1024 / 1024 AS Available_Page_File_GB
FROM sys.dm_os_sys_memory;

-- SQL Server Max & Min Memory Settings
SELECT 
    name AS SettingName,
    CAST(CAST(value_in_use AS DECIMAL(9, 2)) / 1024 AS DECIMAL(9, 2)) AS Value_GB
FROM sys.configurations
WHERE name IN ('max server memory (MB)', 'min server memory (MB)');

SELECT 
    CAST(physical_memory_in_use_kb / 1024 / 1024.0 AS DECIMAL(9, 2)) AS [Actual memory SQL Server is using (GB)]
FROM sys.dm_os_process_memory;

-- Get system-level memory details
SELECT 
    physical_memory_kb / 1024 / 1024 AS Total_Physical_Memory_GB,
    virtual_memory_kb / 1024 / 1024 AS Total_Virtual_Memory_GB,
    max_workers_count AS Max_Workers
FROM sys.dm_os_sys_info;

-- Get SQL Server memory usage
SELECT 
    process_physical_memory_low AS Is_Memory_Low,  -- 1 = SQL Server under memory pressure 
    process_virtual_memory_low AS Is_Virtual_Memory_Low,  -- 1 = Low virtual memory
    large_page_allocations_kb / 1024 / 1024 AS SQLServer_Large_Page_Allocations_GB,
    locked_page_allocations_kb / 1024 / 1024 AS SQLServer_Locked_Page_Allocations_GB,
    memory_utilization_percentage AS Memory_Utilization_Percent,
	-- A low percentage might indicate that SQL Server has more memory than it needs.
	-- A very high percentage (close to 100%) could indicate that SQL Server is under memory pressure.
    total_virtual_address_space_kb / 1024 / 1024 AS SQLServer_Total_Virtual_Memory_GB
FROM sys.dm_os_process_memory;


/* Configure Max and Min Memory Setting

-- CONSIDER ADDING A LOGIC WHERE SIZE OF RAM MATTERS

DECLARE @TotalServerMemoryMB INT,
        @MaxMemoryMB INT,
        @MinMemoryMB INT;

SELECT @TotalServerMemoryMB = physical_memory_kb / 1024 
FROM sys.dm_os_sys_info;

SELECT 
    CAST(@TotalServerMemoryMB / 1024.0 AS DECIMAL(9, 2)) AS [Total Server Memory (MB)]

SELECT 
    name AS [Old Setting],
    CAST(CAST(value_in_use AS DECIMAL(9, 2)) / 1024 AS DECIMAL(9, 2)) AS Value_GB
FROM sys.configurations
WHERE name IN ('max server memory (MB)', 'min server memory (MB)');

-- Calculate 90% of total memory for max server memory
SET @MaxMemoryMB = (@TotalServerMemoryMB * 90) / 100;

-- Calculate 50% of max memory for min server memory
SET @MinMemoryMB = (@MaxMemoryMB * 50) / 100;

-- Configure Max Server Memory
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

EXEC sp_configure 'max server memory (MB)', @MaxMemoryMB;
RECONFIGURE;

-- Configure Min Server Memory
EXEC sp_configure 'min server memory (MB)', @MinMemoryMB;
RECONFIGURE;

-- Display new settings

SELECT
    CAST(@MaxMemoryMB / 1024.0 AS DECIMAL(9, 2)) AS [New Max (GB)],
    CAST(@MinMemoryMB /1024.0 AS DECIMAL(9, 2)) AS [New Min (GB)];

*/