USE [master]
GO
ALTER DATABASE [testDB2]
ADD FILE (
	NAME = N'testDB2_2', -- logical filename
	FILENAME = N'D:\Microsoft SQL Server\SQL2016\MSSQL13.SQL2016\MSSQL\DATA\testDB2_2.mdf' , -- path
	SIZE = 1024MB ,
	FILEGROWTH = 512MB )
TO FILEGROUP [PRIMARY]
GO
