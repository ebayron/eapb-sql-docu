/* Restart Endpoint - should be on both sides */
/* Applicable in mirrored database which is in "In Recovery" status. */

ALTER ENDPOINT Mirroring STATE = STOPPED

ALTER ENDPOINT Mirroring STATE = STARTED

/* Usually being used in INDBS01 and INDBS02 */

USE master

SELECT 'ALTER DATABASE [' + DB_NAME(database_id) + '] SET PARTNER FAILOVER; ', *
FROM sys.database_mirroring
WHERE mirroring_role IS NOT NULL

ALTER DATABASE [HiveDB] SET PARTNER FAILOVER;
