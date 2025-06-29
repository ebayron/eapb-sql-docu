-- Create Database for Audit Results
CREATE DATABASE AuditDB;
GO

-- Create Table where audit logs will be populated
CREATE TABLE AuditDB.dbo.DatabaseDDLEvents
(
    EventDate    DATETIME2(0)	NOT NULL DEFAULT GETDATE(),
    EventType    NVARCHAR(64)	NULL,
    EventDDL     NVARCHAR(MAX)	NULL,
    EventXML     XML			NULL,
    DatabaseName NVARCHAR(255)	NULL,
    SchemaName   NVARCHAR(255)	NULL,
    ObjectName   NVARCHAR(255)	NULL,
    HostName     VARCHAR(64)	NULL,
    IPAddress    VARCHAR(48)	NULL,
    ProgramName  NVARCHAR(255)	NULL,
    LoginName    NVARCHAR(255)	NULL);
GO

-- Create DDL 
USE [AdventureWorks2016]
GO

CREATE TRIGGER [tr_DDL_Database_Level_Events]
    ON DATABASE
    FOR DDL_DATABASE_LEVEL_EVENTS
AS
BEGIN
    SET NOCOUNT ON;
    
	DECLARE @EventData XML = EVENTDATA();
    DECLARE @IP VARCHAR(48) = CONVERT(VARCHAR(48), CONNECTIONPROPERTY('client_net_address'));
 
    INSERT AuditDB.dbo.DDLEvents
    (
        EventType,
        EventDDL,
        EventXML,
        DatabaseName,
        SchemaName,
        ObjectName,
        HostName,
        IPAddress,
        ProgramName,
        LoginName
    )
    SELECT
        @EventData.[value]('(/EVENT_INSTANCE/EventType)[1]',   'NVARCHAR(100)'), 
        @EventData.[value]('(/EVENT_INSTANCE/TSQLCommand)[1]', 'NVARCHAR(MAX)'),
        @EventData,
        DB_NAME(),
        @EventData.[value]('(/EVENT_INSTANCE/SchemaName)[1]',  'NVARCHAR(255)'), 
        @EventData.[value]('(/EVENT_INSTANCE/ObjectName)[1]',  'NVARCHAR(255)'),
        HOST_NAME(),
        @IP,
        PROGRAM_NAME(),
        SUSER_SNAME();
END
GO

ENABLE TRIGGER [tr_DDL_Database_Level_Events] ON DATABASE
GO


