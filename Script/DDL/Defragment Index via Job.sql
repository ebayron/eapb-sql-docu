DECLARE @Reorganize FLOAT = 10;
DECLARE @Rebuild FLOAT = 30;
DECLARE @Script NVARCHAR(MAX) = '';
DECLARE @DB SYSNAME;
DECLARE @body NVARCHAR(MAX) = '';

SELECT @DB = DB_ID();

IF OBJECT_ID('tempdb.dbo.#ReorganizeRebuildIndex') IS NOT NULL
	BEGIN
		DROP TABLE tempdb.dbo.#ReorganizeRebuildIndex
	END

SELECT
	SCHEMA_NAME(st.[schema_id]) AS [Schema Name],
	OBJECT_NAME(ps.[object_id]) AS [Table Name],
	si.[name] [Index Name],
	ps.avg_fragmentation_in_percent AS [Avg Fragmentation (%)],
	CASE
		WHEN ps.avg_fragmentation_in_percent >= @Rebuild THEN
			'ALTER INDEX [' + si.[name] + '] ON ['+ DB_NAME() + '].[' + SCHEMA_NAME(st.[schema_id]) + '].[' + OBJECT_NAME(ps.[object_id]) + '] REBUILD WITH (SORT_IN_TEMPDB = ON);'
		WHEN ps.avg_fragmentation_in_percent >= @Reorganize THEN 
			'ALTER INDEX [' + si.[name] + '] ON ['+ DB_NAME() + '].[' + SCHEMA_NAME(st.[schema_id]) + '].[' + OBJECT_NAME(ps.[object_id]) + '] REORGANIZE;'
	END AS [Script]
INTO #ReorganizeRebuildIndex
FROM sys.dm_db_index_physical_stats(@DB, NULL, NULL, NULL , NULL) ps
INNER JOIN sys.tables st WITH(NOLOCK) ON ps.[object_id] = st.[object_id]
INNER JOIN sys.indexes si WITH(NOLOCK) ON ps.[object_id] = si.[object_id]
	AND ps.index_id = si.index_id
WHERE st.is_ms_shipped = 0
	AND si.index_id > 0
	AND ps.page_count > 1000
	AND ps.avg_fragmentation_in_percent >= @Reorganize;

BEGIN
	SELECT @Script = @Script + SPACE(1) + Script
	FROM #ReorganizeRebuildIndex

	EXEC(@Script)
			
	SET @body = '<SPAN STYLE="BORDER-COLOR: GRAY; FONT-SIZE: 9.0PT; FONT-FAMILY: CALIBRI; FONT-WEIGHT: BOLD;"><B>Please see below for the list of defragmented indexes.</B><BR/><br/>'
	SET @body = @body + N'<TABLE BORDER="1" CELLPADDING="3" CELLSPACING="0" STYLE="BORDER: 2PX SOLID #000000;">'
	SET @body = @body + N'<SPAN STYLE="BORDER-COLOR: GRAY; FONT-SIZE: 8.0PT; FONT-FAMILY: ARIAL;"><TR STYLE="BACKGROUND-COLOR: #483D8B; COLOR: #FFFFFF;">'
	SET @body = @body + N'<TD ALIGN="CENTER" STYLE="BORDER: .5PX SOLID #333333; FONT-WEIGHT:BOLD;">Table Name</TD>'
	SET @body = @body + N'<TD ALIGN="CENTER" STYLE="BORDER: .5PX SOLID #333333; FONT-WEIGHT:BOLD;">Index Date</TD>'
	SET @body = @body + N'<TD ALIGN="CENTER" STYLE="BORDER: .5PX SOLID #333333; FONT-WEIGHT:BOLD;">Avg Fragmentation (%)</TD>'
	SET @body = @body + N'</TR><SPAN STYLE="COLOR: #000000; FONT-WEIGHT:BOLD;">' +
		CAST((SELECT '', '', 'CENTER' AS "TD/@ALIGN",'BORDER: .5PX SOLID #333333; FONT-WEIGHT:BOLD; FONT-SIZE: 11PX;' AS "TD/@STYLE", TD = [Table Name],
			'', '', 'CENTER' AS "TD/@ALIGN",'BORDER: .5PX SOLID #333333; FONT-WEIGHT:BOLD; FONT-SIZE: 11PX;' AS "TD/@STYLE", TD = [Index Name],
			'', '', 'CENTER' AS "TD/@ALIGN",'BORDER: .5PX SOLID #333333; FONT-WEIGHT:BOLD; FONT-SIZE: 11PX;' AS "TD/@STYLE", TD = CAST([Avg Fragmentation (%)] AS DECIMAL(9, 2))
				FROM #ReorganizeRebuildIndex
				ORDER BY 1

	FOR XML PATH('TR'), TYPE) AS NVARCHAR(MAX)) + N'</TABLE> </BR></BR>' ;

	IF (@body IS NOT NULL)                
		BEGIN                
			EXEC msdb.dbo.sp_send_dbmail                   
				@profile_name = 'CICS Profile',                  
				@recipients='ebayron@securitybank.com.ph;',                         
				@subject = 'CICS Defragmented Indexes Job Report',                  
				@body = @body,                  
				@body_format = 'HTML';                   
		END
END

DROP TABLE tempdb.dbo.#ReorganizeRebuildIndex