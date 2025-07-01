DECLARE @BackupFile VARCHAR(100) = 'E:\insertbackuppathhere.bak';

DECLARE @fileListTable TABLE (
    [LogicalName]           NVARCHAR(128),
    [PhysicalName]          NVARCHAR(260),
    [Type]                  CHAR(1),
    [FileGroupName]         NVARCHAR(128),
    [Size]                  NUMERIC(20,0),
    [MaxSize]               NUMERIC(20,0),
    [FileID]                BIGINT,
    [CreateLSN]             NUMERIC(25,0),
    [DropLSN]               NUMERIC(25,0),
    [UniqueID]              UNIQUEIDENTIFIER,
    [ReadOnlyLSN]           NUMERIC(25,0),
    [ReadWriteLSN]          NUMERIC(25,0),
    [BackupSizeInBytes]     BIGINT,
    [SourceBlockSize]       INT,
    [FileGroupID]           INT,
    [LogGroupGUID]          UNIQUEIDENTIFIER,
    [DifferentialBaseLSN]   NUMERIC(25,0),
    [DifferentialBaseGUID]  UNIQUEIDENTIFIER,
    [IsReadOnly]            BIT,
    [TDEThumbprint]         VARBINARY(32), -- remove this column if using SQL 2005
    [SnapshotURL]           NVARCHAR(400), -- remove this column prior to SQL 2016
    [IsPresent]             BIT
)
INSERT INTO @fileListTable EXEC('RESTORE FILELISTONLY FROM DISK = ''' + @BackupFile + '''')

SELECT
	LogicalName
	PhysicalName,
	CASE [Type]
		WHEN 'D' THEN 'Full'
		WHEN 'L' THEN 'Transactional Log'
		ELSE [Type]
	END AS [Type],
	FileGroupName,
	CAST(((Size/1024)/1024)/1024 AS DECIMAL(9, 2)) AS size_in_GB,
	FileID
FROM @fileListTable
