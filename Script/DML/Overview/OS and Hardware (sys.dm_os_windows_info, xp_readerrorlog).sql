-- Windows Info (Using sys.dm_os_windows_info)
SELECT 
    windows_release AS [Windows_Release], -- Windows Edition (e.g., Windows Server 2019)
    os_language_version AS [OS Language Version],
    CASE windows_sku
        WHEN 4   THEN 'Windows Home'
        WHEN 48  THEN 'Windows Professional'
        WHEN 125 THEN 'Windows Enterprise'
        WHEN 97  THEN 'Windows Server Standard'
        WHEN 101 THEN 'Windows Server Datacenter'
        WHEN 8   THEN 'Windows Home Premium'
        WHEN 12  THEN 'Windows Enterprise N'
        WHEN 27  THEN 'Windows Server Datacenter Core'
        WHEN 39  THEN 'Windows Server Standard Core'
        WHEN 79  THEN 'Windows Server Essentials'
        WHEN 121 THEN 'Windows Server Datacenter Azure Edition'
		WHEN 100 THEN 'Windows Home Single Language'
        ELSE 'Unknown SKU (' + CAST(windows_sku AS VARCHAR) + ')'
    END AS Windows_Edition
	-- OS language version
FROM sys.dm_os_windows_info;

-- What kind of hardware is my server running on
EXEC xp_readerrorlog 0, 1, "Manufacturer"