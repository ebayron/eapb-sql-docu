USE [master]
GO

CREATE PROC [dbo].[spKillSession]
AS
	BEGIN                                        

	DECLARE @DynamicSQL NVARCHAR(MAX) = N'';
	DECLARE @Kill NVARCHAR(MAX) = N'';
	DECLARE @Query NVARCHAR(MAX) = N'';

	SET @DynamicSQL = '
		SELECT
			sqltext.[text],
			r.start_time,
			DATEDIFF(MILLISECOND, r.start_time, GETDATE()) / 1000 AS runtime,
			session_id          
		FROM sys.dm_exec_requests r
		CROSS APPLY sys.dm_exec_sql_text(r.[sql_handle]) AS sqltext                  
		--INNER JOIN sys.dm_exec_sessions s			ON s.session_id = r.session_id                  
		--INNER JOIN sys.dm_db_task_space_usage tsu	ON s.session_id = tsu.session_id and r.request_id = tsu.request_id                  
		--INNER JOIN sys.dm_tran_locks AS tl			ON s.session_id = tl.request_session_id                  
		--INNER JOIN sys.databases db					ON db.database_id = tl.resource_database_id                  
		--INNER JOIN sys.dm_os_waiting_tasks AS wt	ON tl.lock_owner_address = wt.resource_address                  
		--INNER JOIN sys.partitions AS p				ON p.hobt_id = tl.resource_associated_entity_id                  
		--INNER JOIN sys.dm_exec_connections ec1		ON ec1.session_id = tl.request_session_id                  
		--INNER JOIN sys.dm_exec_connections ec2		ON ec2.session_id = wt.blocking_session_id                                
		WHERE sqltext.[text] LIKE ''%getNextCombinedPhoneAndIntrvwProcess%'' -- specify query
			AND DATEDIFF(MILLISECOND, r.start_time, GETDATE()) / 1000 > 20 -- specify time
		--WHERE r.status IN (''running'', ''runnable'', ''suspended'')                  
		--	AND r.blocking_session_id <> 0                  
		--GROUP BY    r.session_id,                  
		--            s.host_name,                  
		--            s.login_name,          
		--            db.name,                   
		--            OBJECT_NAME(p.OBJECT_ID),                  
		--            r.start_time,                  
		--            r.blocking_session_id,                  
		--            ec1.client_net_address,                  
		--            s.program_name
		'

	IF OBJECT_ID('tempdb.dbo.#TempKillSession') IS NOT NULL DROP TABLE #TempKillSession

	CREATE TABLE #TempKillSession (
		sqltext NVARCHAR(MAX) NOT NULL,
		starttime DATETIME NOT NULL,
		runtime TINYINT NOT NULL,
		sessionID TINYINT NOT NULL)


	INSERT INTO #TempKillSession
	EXEC (@DynamicSQL) AT [SQLDBCLUSTER\CC60]

	SELECT
		@Kill = 'KILL ' + CAST(sessionID AS CHAR(3))
	FROM #TempKillSession

	IF (SELECT COUNT(1) FROM #TempKillSession) > 0
		BEGIN
			EXEC (@DynamicSQL) AT [SQLDBCLUSTER\CC60] -- Specify server if using Registered Server

			SELECT @Query = sqltext + '(Seconds: ' + CAST(runtime AS CHAR(3)) + ') (Session ID: ' + sessionID + ')' FROM #TempKillSession

			PRINT @Query

			EXEC msdb.dbo.sp_send_dbmail                   
				@profile_name = 'db_mail_profile',                  
				@recipients = 'ebayron@eperformax.com',                         
				@subject = 'KILL Session',                  
				@body = @Query,                  
				@body_format = 'HTML';
		END
	END                       

