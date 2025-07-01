SELECT
	@@SERVERNAME AS [Server Name],
	@@VERSION AS [Instance Version]	

SELECT createdate AS [Installation Date]
FROM syslogins
WHERE name = 'NT AUTHORITY\SYSTEM'

-- When SQL Server was last restarted
DECLARE @int INT

SELECT @int = DATEDIFF(SECOND,sqlserver_start_time,GETDATE()) FROM sys.dm_os_sys_info

SELECT
	sqlserver_start_time AS [Server Up Time],
	GETDATE() AS [Server Date and Time],
	RIGHT('00' + RTRIM(LTRIM(CONVERT(CHAR(2), (@int / 86400)))), 2) + ':' +  --Days
	RIGHT('00' + RTRIM(LTRIM(CONVERT(CHAR(2), ((@int % 86400) / 3600)))), 2) + ':'+ -- Hours
	RIGHT('00' + RTRIM(LTRIM(CONVERT(CHAR(2), (((@int % 86400) % 3600)/60)))), 2) AS [Duration (dd:hh:mm)]
FROM sys.dm_os_sys_info

-- General Server Information
SELECT 
    SERVERPROPERTY ('MachineName') AS MachineName,
    SERVERPROPERTY ('ServerName') AS ServerName,
    SERVERPROPERTY ('InstanceName') AS InstanceName,
    SERVERPROPERTY ('ComputerNamePhysicalNetBIOS') AS ComputerNamePhysicalNetBIOS,
    SERVERPROPERTY ('Edition') AS Edition,
    SERVERPROPERTY ('ProductVersion') AS ProductVersion,
    SERVERPROPERTY ('ProductLevel') AS ProductLevel,
    SERVERPROPERTY ('ProductUpdateLevel') AS ProductUpdateLevel,
    SERVERPROPERTY ('ProductBuild') AS ProductBuild,
    SERVERPROPERTY ('ProductBuildType') AS ProductBuildType,
    SERVERPROPERTY ('ProductMajorVersion') AS ProductMajorVersion,
    SERVERPROPERTY ('ProductMinorVersion') AS ProductMinorVersion,
    SERVERPROPERTY ('IsFullTextInstalled') AS IsFullTextInstalled,
    SERVERPROPERTY ('FilestreamConfiguredLevel') AS FilestreamConfiguredLevel,
    SERVERPROPERTY ('FilestreamEffectiveLevel') AS FilestreamEffectiveLevel,
    SERVERPROPERTY ('IsXTPSupported') AS IsXTPSupported,
    SERVERPROPERTY ('IsPolyBaseInstalled') AS IsPolyBaseInstalled,
    SERVERPROPERTY ('IsExternalGovernanceEnabled') AS IsExternalGovernanceEnabled;

-- Licensing and Resource Information
SELECT 
    SERVERPROPERTY ('Collation') AS Collation,
	SERVERPROPERTY ('LicenseType') AS LicenseType,
    SERVERPROPERTY ('NumLicenses') AS NumLicenses,
    SERVERPROPERTY ('ProcessID') AS ProcessID,
    SERVERPROPERTY ('EngineEdition') AS EngineEdition,
    SERVERPROPERTY ('ResourceVersion') AS ResourceVersion,
    SERVERPROPERTY ('ResourceLastUpdateDateTime') AS ResourceLastUpdateDateTime,
    SERVERPROPERTY ('SqlCharSet') AS SqlCharSet,
    SERVERPROPERTY ('SqlCharSetName') AS SqlCharSetName,
    SERVERPROPERTY ('SqlSortOrder') AS SqlSortOrder,
    SERVERPROPERTY ('SqlSortOrderName') AS SqlSortOrderName;

-- Configuration and Security
SELECT 
    SERVERPROPERTY ('IsSingleUser') AS IsSingleUser,
    SERVERPROPERTY ('IsEncrypted') AS IsEncrypted,
    SERVERPROPERTY ('IsSqlTDEEnabled') AS IsSqlTDEEnabled,
    SERVERPROPERTY ('IsAdvancedAnalyticsInstalled') AS IsAdvancedAnalyticsInstalled,
    SERVERPROPERTY ('IsTempDbMetadataMemoryOptimized') AS IsTempDbMetadataMemoryOptimized;

-- Always On and High Availability
SELECT
    SERVERPROPERTY ('IsMirroringEnabled') AS IsMirroringEnabled,
	SERVERPROPERTY ('IsClustered') AS IsClustered,
    SERVERPROPERTY ('IsHadrEnabled') AS IsHadrEnabled,
    SERVERPROPERTY ('IsAlwaysOnFailoverClusterInstance') AS IsAlwaysOnFailoverClusterInstance,
    SERVERPROPERTY ('HadrManagerStatus') AS HadrManagerStatus;

-- Miscellaneous
SELECT 
    SERVERPROPERTY ('BuildClrVersion') AS BuildClrVersion,
    SERVERPROPERTY ('IsSupportedVersion') AS IsSupportedVersion,
    SERVERPROPERTY ('ThreadPoolType') AS ThreadPoolType,
    SERVERPROPERTY ('SoftNumaConfiguration') AS SoftNumaConfiguration,
    SERVERPROPERTY ('AffinityType') AS AffinityType,
    SERVERPROPERTY ('IsLedgerDatabaseEnabled') AS IsLedgerDatabaseEnabled,
    SERVERPROPERTY ('IsPdwEdition') AS IsPdwEdition,
    SERVERPROPERTY ('IsRemoteDedicatedAdministratorConnectionEnabled') AS IsRemoteDedicatedAdministratorConnectionEnabled;

