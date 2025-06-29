/*
	The script below will create a data file,
	create a 10MB ‘filler’ table at the start of the data file,
	create a 10MB ‘production’ clustered index,
	and then analyze the fragmentation of the new clustered index.
*/

USE [master];
GO

IF DATABASEPROPERTYEX (N'DBMaint2008', N'Version') IS NOT NULL
DROP DATABASE [DBMaint2008];
GO

CREATE DATABASE DBMaint2008;
GO

USE [DBMaint2008];
GO

SET NOCOUNT ON;
GO

-- Create the 10MB filler table at the 'front' of the data file
CREATE TABLE FillerTable (
	c1 INT IDENTITY,
	c2 CHAR (8000) DEFAULT 'filler');

-- Fill up the filler table
INSERT INTO FillerTable DEFAULT VALUES;
GO 1280

-- Create the production table, which will be 'after' the filler table in the data file
CREATE TABLE ProdTable (
	c1 INT IDENTITY,
	c2 CHAR (8000) DEFAULT 'production');

CREATE CLUSTERED INDEX prod_cl ON ProdTable(c1);

INSERT INTO [ProdTable] DEFAULT VALUES;
GO 1280

-- Check the fragmentation of the production table
SELECT avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats (DB_ID ('DBMaint2008'), OBJECT_ID ('ProdTable'), 1, NULL, )
GO

/*
avg_fragmentation_in_percent
-----------------------------
0.390625
*/

-- The logical fragmentation of the clustered index before the shrink is a near-perfect 0.4%.
-- Now drop the 'filler' table, run a shrink to reclaim the space, and reanalyze the fragmentation of the clustered index.

-- Drop the filler table, creating 10MB of free space at the 'front' of the data file
DROP TABLE FillerTable;

-- Shrink the database
DBCC SHRINKDATABASE (DBMaint2008);

-- Check the index fragmentation again
SELECT avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats (DB_ID (N'DBMaint2008'), OBJECT_ID (N'ProdTable'), 1, NULL, )

/*
avg_fragmentation_in_percent
-----------------------------
99.296875
*/