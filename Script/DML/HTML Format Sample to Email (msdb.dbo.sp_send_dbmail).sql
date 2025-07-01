DECLARE @body NVARCHAR(MAX) = '';
-- Generate HTML table format
SET @body = '<SPAN STYLE="BORDER-COLOR: GRAY; FONT-SIZE: 9.0PT; FONT-FAMILY: CALIBRI; FONT-WEIGHT: BOLD;"><B>Lists of databases.</B><BR/><br/>'
SET @body = @body + N'<TABLE BORDER="1" CELLPADDING="3" CELLSPACING="0" STYLE="BORDER: 2PX SOLID #000000;">'
SET @body = @body + N'<SPAN STYLE="BORDER-COLOR: GRAY; FONT-SIZE: 8.0PT; FONT-FAMILY: ARIAL;"><TR STYLE="BACKGROUND-COLOR: #483D8B; COLOR: #FFFFFF;">'
SET @body = @body + N'<TD ALIGN="CENTER" STYLE="BORDER: .5PX SOLID #333333; FONT-WEIGHT:BOLD;">Database Name</TD>'
SET @body = @body + N'<TD ALIGN="CENTER" STYLE="BORDER: .5PX SOLID #333333; FONT-WEIGHT:BOLD;">Create Date</TD>'
SET @body = @body + N'</TR><SPAN STYLE="COLOR: #000000; FONT-WEIGHT:BOLD;">' +
	CAST((SELECT '', '', 'CENTER' AS "TD/@ALIGN",'BORDER: .5PX SOLID #333333; FONT-WEIGHT:BOLD; FONT-SIZE: 11PX;' AS "TD/@STYLE", TD = [name],
		'', '', 'CENTER' AS "TD/@ALIGN",'BORDER: .5PX SOLID #333333; FONT-WEIGHT:BOLD; FONT-SIZE: 11PX;' AS "TD/@STYLE", TD = create_date
			FROM sys.databases
			ORDER BY 1

FOR XML PATH('TR'), TYPE) AS NVARCHAR(MAX)) + N'</TABLE> </BR></BR>' ;

IF (@body IS NOT NULL)                
	BEGIN                
		EXEC msdb.dbo.sp_send_dbmail                   
			@profile_name = 'profile',                  
			@recipients='bayronedgarallanperez@gmail.com;',                         
			@subject = 'SQL Databases',                  
			@body = @body,                  
			@body_format = 'HTML';                   
	END