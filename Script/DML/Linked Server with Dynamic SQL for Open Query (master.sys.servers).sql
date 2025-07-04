DECLARE @DynamicSQL NVARCHAR(MAX) = 'SELECT * FROM sys.databases';
DECLARE @QueryString NVARCHAR(MAX) = '';

-- Dynamically generate linked servers with OPENQUERY
SELECT
	@QueryString = @QueryString + ' UNION ALL SELECT * FROM OPENQUERY([' + name + '], ''' + @DynamicSQL + ''')'
FROM [master].sys.servers WITH(NOLOCK)
WHERE server_id > 0
--	AND is_remote_login_enabled <> 1
--  AND is_remote_proc_transaction_promotion_enabled <> 1
	
-- Remove the first " UNION ALL " in the string
SELECT @QueryString = SUBSTRING(@QueryString, 11, LEN(@QueryString))

SELECT @QueryString

-- Insert in a table variable
--INSERT INTO @table -- Create this table first!
--EXEC sp_executesql @LinkedServer;

--SELECT
--	*
--FROM @table
--ORDER BY AuditDate DESC, DBName, SchemaName, ObjectType
