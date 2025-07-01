SELECT
    Operation,
    [Transaction ID],
    [Begin Time],
    [Transaction Name],
    SUSER_SNAME([Transaction SID])
FROM fn_dblog(NULL, NULL)
WHERE [Operation] = 'LOP_BEGIN_XACT'
	AND [Transaction ID] IN (
		SELECT 
			[Transaction ID] 
		FROM fn_dblog(NULL, NULL) 
		WHERE Operation = 'LOP_DELETE_ROWS' -- Deleted transaction
			AND AllocUnitName NOT LIKE 'sys.%')