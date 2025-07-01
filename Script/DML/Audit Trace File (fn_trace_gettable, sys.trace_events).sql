DECLARE @filename VARCHAR(255) 
SELECT @FileName = SUBSTRING(path, 0, LEN(path)-CHARINDEX('\', REVERSE(path))+1) + '\Log.trc'  
FROM sys.traces   
WHERE is_default = 1;  

SELECT TOP 50
       gt.StartTime, 
       gt.EndTime, 
	   gt.Duration, 
	   gt.ServerName,
       gt.DatabaseName,      
       gt.ObjectName, 
       gt.TextData, 
       gt.NTUserName, 
       gt.NTDomainName,
	   gt.HostName,
       gt.LoginName,  
	   gt.SessionLoginName,
	   SUSER_SNAME(gt.LoginSid) AS LoginSIDName,
       gt.ApplicationName,
       gt.SPID,
       gt.EventClass, 
       gt.EventSubClass,
       te.Name AS EventName
FROM [fn_trace_gettable](@filename, DEFAULT) gt 
JOIN sys.trace_events te ON gt.EventClass = te.trace_event_id 
--WHERE EventClass in (164) --AND gt.EventSubClass = 2
ORDER BY gt.StartTime DESC; 