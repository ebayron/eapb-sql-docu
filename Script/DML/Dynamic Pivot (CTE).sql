IF OBJECT_ID('##DemoTable') IS NOT NULL DROP TABLE ##DemoTable

CREATE TABLE ##DemoTable (
	AssignmentName VARCHAR(255),
	StudentName VARCHAR(255),
	GRADE INT
)

INSERT INTO ##DemoTable VALUES ('Assignment1', 'Student 1', 70)
INSERT INTO ##DemoTable VALUES ('Assignment2', 'Student 2', 75)
INSERT INTO ##DemoTable VALUES ('Assignment2', 'Student 3', 80)
INSERT INTO ##DemoTable VALUES ('Assignment3', 'Student 4', 85)
INSERT INTO ##DemoTable VALUES ('Assignment3', 'Student 5', 90)
INSERT INTO ##DemoTable VALUES ('Assignment3', 'Student 6', 95)

SELECT * FROM ##DemoTable
GO

-- STATIC PIVOT

WITH PivotData AS (
	SELECT
		AssignmentName,
		StudentName,
		Grade
	FROM ##DemoTable
)
SELECT
	StudentName,
	Assignment1,
	Assignment2,
	Assignment3
FROM PivotData
PIVOT (
	SUM(Grade)
	FOR AssignmentName
	IN (Assignment1, Assignment2, Assignment3)
) AS PivotResult
ORDER BY StudentName 

-- DYNAMIC PIVOT

DECLARE @SQl AS VARCHAR(MAX)
DECLARE @Column AS VARCHAR(MAX)

SELECT
	@Column = COALESCE(@Column + ' , ','') + QUOTENAME(AssignmentName)
FROM (
	SELECT DISTINCT AssignmentName
	FROM ##DemoTable
) AS b
ORDER BY b.AssignmentName

SET @SQL = '
WITH PivotDaTa AS (
	SELECT
		AssignmentName,
		StudentName,
		Grade
	FROM ##DemoTable
)

SELECT
	StudentName,
	' + @Column + '
FROM PivotData
PIVOT (
	SUM(Grade)
	FOR AssignmentName
	IN (' + @Column + ')
) AS PivotResult
ORDER BY StudentName'

EXEC (@SQL)

SELECT * FROM ##DemoTable

DROP TABLE ##DemoTable