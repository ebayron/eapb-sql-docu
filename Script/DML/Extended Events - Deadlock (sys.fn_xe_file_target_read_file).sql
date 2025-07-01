/* Declare variables */

DECLARE
	@DeadLockXMLData AS XML,
	@DeadLockNumber INT,
	@getInputBuffer CURSOR,
	@Document AS INT,
	@SQLString NVARCHAR (MAX),
	@GetDeadLocksForLastMinutes INT,
	@Path NVARCHAR(MAX);
 
SET	@GetDeadLocksForLastMinutes = 50;
SET @Path = 'F:\Clean Up\AuditDeadlock_*.xel';
 
/* Create temporary tables */

CREATE TABLE #DeadLockXMLData ( -- Store each Dead lock XML from the extended Event
	DeadLockXMLData XML,
	DeadLockNumber INT)

CREATE TABLE #DeadLockDetails( -- Store deadlock process, victim and application information
	ProcessID NVARCHAR(50),
	HostName NVARCHAR(50),
	LoginName NVARCHAR(100),
	ClientApp NVARCHAR(100),
	Frame NVARCHAR(MAX),
	TSQLString NVARCHAR(MAX),
	DeadLockDateTime DATETIME,
	IsVictim TINYINT,
	DeadLockNumber INT)

/* Insert the deadlocks from extended events to temp tables & filter only deadlocks */

INSERT INTO #DeadLockXMLData(DeadLockXMLData, DeadLockNumber)
SELECT
	CONVERT(XML, event_data) AS DeadLockXMLData,
	ROW_NUMBER() OVER (ORDER BY [object_name]) AS DeadLockNumber
FROM sys.fn_xe_file_target_read_file(@Path, NULL, NULL, NULL)
WHERE [object_name] = 'xml_deadlock_report'

/* Start a cursor to loop through all the deadlocks as you might get mutltiple deadlock in production and you would want all of them */

SET @getInputBuffer = CURSOR FOR
SELECT DeadLockXMLData,DeadLockNumber
FROM #DeadLockXMLData

OPEN @getInputBuffer
 
FETCH NEXT
FROM @getInputBuffer
INTO @DeadLockXMLData, @DeadLockNumber
 
WHILE	@@FETCH_STATUS = 0
 
BEGIN
	SET @Document = 0
	SET @SQLString = ''
 
	EXEC sp_xml_preparedocument @Document OUTPUT, @DeadLockXMLData
 
/* Insert parsed document's data from xml to temp table for readability */

	INSERT INTO #DeadLockDetails(ProcessID, HostName, LoginName, ClientApp, Frame, TSQLString, DeadLockDateTime, DeadLockNumber)
	SELECT ProcessID, HostName, LoginName, ClientApp, Frame, [TSQL] AS TSQLString, LastBatchCompleted, @DeadLockNumber
	FROM OPENXML(@Document, 'event/data/value/deadlock/process-list/process')
	WITH (
		ProcessID VARCHAR(50) '@id',
		HostName VARCHAR(50) '@hostname',
		LoginName VARCHAR(50) '@loginname',
		ClientApp VARCHAR(50) '@clientapp',
		CustomerName VARCHAR(100) '@clientapp',
		[TSQL] [NVARCHAR](4000) 'inputbuf',
		Frame NVARCHAR(4000) 'executionStack/frame',
		LastBatchCompleted NVARCHAR(50) '@lastbatchcompleted')
 
/* Update the victim SPID to highlight two queries separetely, the process (who created the deadlock) and the victim */
 
	UPDATE #DeadLockDetails
	SET IsVictim = 1
	WHERE ProcessID IN (
		SELECT ProcessID 
		FROM OPENXML(@Document, 'event/data/value/deadlock/victim-list/victimProcess')
		WITH (
			ProcessID VARCHAR(50) '@id',
			HostName VARCHAR(50) '@hostname',
			LoginName VARCHAR(50) '@loginname',
			ClientApp VARCHAR(50) '@clientapp',
			CustomerName VARCHAR(100) '@clientapp',
			TSQL [NVARCHAR](4000) 'inputbuf',
			Frame NVARCHAR(4000) 'executionStack/frame',
			LastBatchCompleted NVARCHAR(50) '@lastbatchcompleted'))
 
	EXEC sp_xml_removedocument @Document
 
	FETCH NEXT
	FROM @getInputBuffer INTO @DeadLockXMLData,@DeadLockNumber
END
 
CLOSE @getInputBuffer
DEALLOCATE @getInputBuffer
 
 
/* Get all the deadlocks as a result in easy readable table format and analyze it for further optimization */

SELECT
	DeadLockDateTime,
	HostName,
	LoginName,
	ClientApp,
	ISNULL(Frame, '') + ' **' + ISNULL(TSQLString,'') + '**' AS VictimTSQL,
	(SELECT MAX(ISNULL(Frame,'') + ' **' + ISNULL(TSQLString,'') + '**') AS TSQLString FROM #DeadLockDetails WHERE DeadLockNumber = D.DeadLockNumber AND ISNULL(IsVictim,0) = 0) AS ProcessTSQL
FROM #DeadLockDetails D
WHERE DATEDIFF(MINUTE,DeadLockDateTime,GETDATE()) <= @GetDeadLocksForLastMinutes
	AND IsVictim = 1
ORDER BY DeadLockNumber
 
DROP TABLE #DeadLockXMLData, #DeadLockDetails