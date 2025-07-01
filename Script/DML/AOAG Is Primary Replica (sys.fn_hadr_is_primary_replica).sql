/*
This system function has been added that will help you identify if the database and instance you are currently working on is the primary replica.
The procedure returns a 1, if it evaluates to true, that is, it is the primary replica.
You can combine this with some logical code to determine which section of the code to run depending on whether the replica is currently the primary replica.
The following script will back up your database if the current instance that it runs is the primary instance.
*/

DECLARE @dbname VARCHAR(30)
DECLARE @backuplocation VARCHAR(80)
SET @dbname = 'DB1'
SET @backuplocation = 'C:\BACKUP\'
SET @backuplocation = @backuplocation + @dbname
IF sys.fn_hadr_is_primary_replica(@dbname) <> 1
BEGIN
	SELECT 'Nothing to backup'
END
ELSE
	BACKUP DATABASE @DBName TO DISK = @backuplocationIt