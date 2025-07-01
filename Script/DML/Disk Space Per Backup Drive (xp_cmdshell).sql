USE [master]
GO

/* 1. Create temporarily tables (1 for servers with their back up drives are in a separate machine and
1 for servers where the back up drives are on the same machine). */

DECLARE @DriveFreeSpace TABLE (
	DrivePath VARCHAR(200) NULL,
	FreeSpace VARCHAR(255) NULL
)

DECLARE @dmzdata TABLE  (
	Drive CHAR(1) NOT NULL,
	MBFree VARCHAR(255))

/* 2. Declare variables */

DECLARE @server1 TABLE (TextLine VARCHAR(255) NULL);
DECLARE @server2 TABLE (TextLine VARCHAR(255) NULL);
DECLARE @drive1 VARCHAR(20) = 'dir \\LT19-L1-034\c$';
DECLARE @drive2 VARCHAR(20) = 'dir \\LT19-L1-034\d$';

/* 3. Execute xp_cmdshell to return information of drive space. */

INSERT INTO @server1
EXEC [.\SQL2016].[master]..xp_cmdshell @drive1

INSERT INTO @server2
EXEC [.\SQL2017].[master]..xp_cmdshell @drive2

/* 4. Merge results of each drive by inserting into the temporary table */

INSERT INTO @DriveFreeSpace (DrivePath, FreeSpace)
SELECT @drive1, TextLine FROM @server1

INSERT INTO @DriveFreeSpace (DrivePath, FreeSpace)
SELECT @drive2, TextLine FROM @server2

/* 5 .Format the result, out of all the meta data that are retrieved, only the free space will be remained. */

DELETE
FROM @DriveFreeSpace
WHERE ISNULL(FreeSpace, '') NOT LIKE '%free%'

UPDATE @DriveFreeSpace
SET FreeSpace = LTRIM(RTRIM(REPLACE(REPLACE(SUBSTRING(FreeSpace, CHARINDEX(')', FreeSpace) + 2, LEN(FreeSpace)), ',', ''), 'bytes free', '')))

UPDATE @DriveFreeSpace
SET FreeSpace = CAST(((CAST(FreeSpace AS BIGINT)/1024.00)/1024/1024) AS DECIMAL(9, 2))

SELECT
	SUBSTRING(DrivePath, 5, LEN(DrivePath)) AS "Drive Path",
	FreeSpace AS "Free Space (GB)"
FROM @DriveFreeSpace