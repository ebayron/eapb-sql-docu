CREATE TABLE [dbo].[tbl1] (
[tbl1_ID] INT IDENTITY(1, 1) NOT NULL,
[coln] [datatype] NULL | NOT NULL
CONSTRAINT PK_tbl1_ID PRIMARY KEY (tbl1_ID))
GO

CREATE TABLE [dbo].[tbl1_Log] (
[tbl1_Log_ID] INT NOT NULL IDENTITY,
[tbl1_ID] INT NOT NULL,
[coln] [datatype] NULL | NOT NULL
[Action_Type] CHAR(1) NULL,
[Action_Done_By] VARCHAR(128) NULL,
[Action_Done_On] DATETIME NULL,
[From_Host] VARCHAR(128) NULL,
CONSTRAINT PK_tbl1_Log_ID PRIMARY KEY (tbl1_Log_ID))
GO

