ALTER DATABASE db_name SET MULTI_USER

ALTER DATABASE db_name SET SINGLE_USER


-- set to multi-user
exec sp_dboption 'db_name', 'single user', 'FALSE' -- for older versions
GO

