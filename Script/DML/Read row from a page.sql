
-- Get PageID
DBCC IND('<dbname>', 'tablename', -1)

-- Get Data from PageID
CREATE TABLE #DBCCPageResults (
    ParentObject VARCHAR(255),
    Object VARCHAR(255),
    Field VARCHAR(255),
    VALUE NVARCHAR(MAX));

DBCC TRACEON(3604)
INSERT INTO #DBCCPageResults
EXEC ('DBCC PAGE (master, 1, 365, 3) WITH TABLERESULTS');
DBCC TRACEOFF(3604)

SELECT ParentObject, Field, Value 
FROM #DBCCPageResults
WHERE (ParentObject LIKE 'Slot%'
	AND Object LIKE 'Slot%')
	OR Field = 'm_slotCnt' -- include number of records inside a page; 

-- DROP TABLE #DBCCPageResults;

-- View physical location per record in a tablename
SELECT sys.fn_PhysLocFormatter(%%physloc%%) * FROM <table_name>

-- View Page for each record
SELECT sys.fn_PhysLocFormatter(%%physloc%%), *
FROM master..serverlist -- WITH (INDEX=0)