-- https://www.sqlshack.com/how-to-configure-read-only-routing-for-an-availability-group-in-sql-server-2016/
--TCP://T1VM-CTRUNCDB01.sbcdom.com:5022
--TCP://P01VWNCICSPDB01.sbcdom.com:5022

--1
ALTER AVAILABILITY GROUP [AG-CICS]
MODIFY REPLICA ON N'T1VM-CTRUNCDB01'
WITH (SECONDARY_ROLE (ALLOW_CONNECTIONS = READ_ONLY));
 
--2
ALTER AVAILABILITY GROUP [AG-CICS]
MODIFY REPLICA ON N'T1VM-CTRUNCDB01'
WITH (SECONDARY_ROLE (READ_ONLY_ROUTING_URL = N'TCP://P01VWNCICSPDB01.sbcdom.com:5022'));
 
--3
ALTER AVAILABILITY GROUP [AG-CICS]
MODIFY REPLICA ON N'P01VWNCICSPDB01'
WITH (SECONDARY_ROLE (ALLOW_CONNECTIONS = READ_ONLY));
 
--4
ALTER AVAILABILITY GROUP [AG-CICS]
MODIFY REPLICA ON N'P01VWNCICSPDB01'
WITH (SECONDARY_ROLE (READ_ONLY_ROUTING_URL = N'TCP://T1VM-CTRUNCDB01.sbcdom.com:5022'));

--/*****************
SELECT replica_server_name
	, read_only_routing_url
	, secondary_role_allow_connections_desc
--	SELECT *
FROM sys.availability_replicas
--*******************/
