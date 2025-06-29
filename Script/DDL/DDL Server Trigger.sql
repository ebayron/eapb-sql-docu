USE [master]
GO

/****** Object:  DdlTrigger [tr_DDL_Database_Level_Events]    Script Date: 1/16/2020 12:46:34 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [tr_DDL_Server_Level_Events]
    ON ALL SERVER
    FOR DDL_SERVER_LEVEL_EVENTS
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

ENABLE TRIGGER [tr_DDL_Server_Level_Events] ON ALL SERVER
GO