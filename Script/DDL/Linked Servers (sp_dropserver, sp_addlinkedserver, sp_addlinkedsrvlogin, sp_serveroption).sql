USE [master];

DECLARE @LinkedServer SYSNAME = '';
DECLARE @UserName SYSNAME = '';
DECLARE @Password SYSNAME = '';
DECLARE @OracleDataSrc SYSNAME = ''; -- Example N'//192.168.1.1:1521/OracleInstance'

IF EXISTS(SELECT 1 FROM sys.servers WHERE name =  @LinkedServer)
BEGIN
	EXEC dbo.sp_dropserver
		@server= @LinkedServer,
		@droplogins = 'droplogins'
END

EXEC dbo.sp_addlinkedserver
	@server = @LinkedServer,
	@srvproduct = N'SQL Server';

/*
-- For Oracle

EXEC master.dbo.sp_addlinkedserver
	@server = @LinkedServer,
	@srvproduct = N'Oracle',
	@provider = N'OraOLEDB.Oracle',
	@datasrc = @OracleDataSrc

EXEC master.dbo.sp_addlinkedsrvlogin
	@rmtsrvname = @LinkedServer,
	@useself = N'False',
	@locallogin = NULL,
	@rmtuser = @UserName,
	@rmtpassword = @Password
*/

EXEC dbo.sp_addlinkedsrvlogin
	@rmtsrvname = @LinkedServer,
	@useself = N'False',
	@locallogin = NULL,
	@rmtuser = @UserName,
	@rmtpassword = @Password;

EXEC dbo.sp_serveroption -- Configured to enable EXEC <query> AT <linked server> to insert data from linked servers to local temporary tables.
	@server = @LinkedServer,
	@optname = N'rpc',
	@optvalue = N'false';

EXEC dbo.sp_serveroption -- Configured to enable EXEC <query> AT <linked server> to insert data from linked servers to local temporary tables.
	@server = @LinkedServer,
	@optname = N'remote proc transaction promotion',
	@optvalue = N'false';

/*
Script to enable below script:

--INSERT INTO #TempTable
--EXEC (@DynamicSQL) AT [ServerName];

EXEC dbo.sp_serveroption -- Enable Promotion of Distributed Transactions for RPC
	@server = @LinkedServer,
	@optname = N'rpc out',
	@optvalue = N'true';
*/

/*
Data Access (local server only)

Insert local server in order to use OPENQUERY. This will be used to use VIEW table in STORED PROCEDURE results.

EXEC dbo.sp_serveroption 
	@server = [PC-NODE1],
	@optname = N'data access',
	@optvalue = N'true';
*/
