USE production_bonus

BEGIN TRAN

PRINT 'DROPPING TABLES...'

IF OBJECT_ID('dbo.tbAddress_CityProvince_Log', 'U') IS NOT NULL
	DROP TABLE dbo.tbAddress_CityProvince_log
IF OBJECT_ID('dbo.tbAddress_CityProvince', 'U') IS NOT NULL
	DROP TABLE dbo.tbAddress_CityProvince
IF OBJECT_ID('dbo.tbAddress_Region_Log', 'U') IS NOT NULL
	DROP TABLE dbo.tbAddress_Region_Log
IF OBJECT_ID('dbo.tbAddress_Region', 'U') IS NOT NULL
	DROP TABLE dbo.tbAddress_Region
IF OBJECT_ID('dbo.tbAddress_IslandGroup_Log', 'U') IS NOT NULL
	DROP TABLE dbo.tbAddress_IslandGroup_log
IF OBJECT_ID('dbo.tbAddress_IslandGroup', 'U') IS NOT NULL
	DROP TABLE dbo.tbAddress_IslandGroup

PRINT 'TABLES DROPPED.'

PRINT 'CREATING TABLES...'

CREATE TABLE tbAddress_IslandGroup (
	id				TINYINT		NOT NULL IDENTITY,
	name			VARCHAR(8)	NOT NULL,
	dateModified	DATETIME	NOT NULL CONSTRAINT def_tbAddress_IslandGroup_dateModified DEFAULT GETDATE(),
	userModifiedID	SMALLINT	NOT NULL
	CONSTRAINT pk_tbAddress_IslandGroup PRIMARY KEY (id),
	CONSTRAINT uq_tbAddress_IslandGroup_name UNIQUE (name),
	CONSTRAINT fk_tbAddress_IslandGroup_userModifiedID FOREIGN KEY (userModifiedID) REFERENCES tbUsers(id)
)

CREATE TABLE tbAddress_IslandGroup_Log (
	logID			TINYINT		NOT NULL IDENTITY,
	id				TINYINT		NOT NULL,
	name			VARCHAR(8)	NOT NULL,
	dateModified	DATETIME	NOT NULL CONSTRAINT def_tbAddress_IslandGroup_Log_dateModified DEFAULT GETDATE(),
	userModifiedID	SMALLINT	NOT NULL
	CONSTRAINT pk_tbAddress_IslandGroup_Log PRIMARY KEY (logID),
	CONSTRAINT fk_tbAddress_IslandGroup_Log_id FOREIGN KEY (id) REFERENCES tbAddress_IslandGroup(id),
	CONSTRAINT fk_tbAddress_IslandGroup_Log_userModifiedID FOREIGN KEY (userModifiedID) REFERENCES tbUsers(id)
)

CREATE TABLE tbAddress_Region (
	id				TINYINT		NOT NULL IDENTITY,
	name			VARCHAR(20)	NOT NULL,
	alt_name		VARCHAR(50)	NOT NULL,
	islandGroupID	TINYINT		NOT NULL,
	dateModified	DATETIME	NOT NULL CONSTRAINT def_tbAddress_Region DEFAULT GETDATE(),
	userModifiedID	SMALLINT	NOT NULL
	CONSTRAINT pk_tbAddress_Region PRIMARY KEY (id),
	CONSTRAINT uq_tbAddress_Region_name UNIQUE (name),
	CONSTRAINT fk_tbAddress_Region_islandGroupID FOREIGN KEY (islandGroupID) REFERENCES tbAddress_IslandGroup(id),
	CONSTRAINT fk_tbAddress_Region_userModifiedID FOREIGN KEY (userModifiedID) REFERENCES tbUsers(id)
)

CREATE TABLE tbAddress_Region_Log (
	id				SMALLINT	NOT NULL IDENTITY,
	regionID		TINYINT		NOT NULL,
	name			VARCHAR(20)	NOT NULL,
	alt_name		VARCHAR(50) NOT NULL,
	islandGroupID	TINYINT		NOT NULL,
	dateModified	DATETIME	NOT NULL CONSTRAINT def_tbAddress_Region_Log DEFAULT GETDATE(),
	userModifiedID	SMALLINT	NOT NULL
	CONSTRAINT pk_tbAddress_Region_Log PRIMARY KEY (id),
	CONSTRAINT fk_tbAddress_Region_Log_regionID FOREIGN KEY (regionID) REFERENCES tbAddress_Region(id),
	CONSTRAINT fk_tbAddress_Region_Log_islandGroupID FOREIGN KEY (islandGroupID) REFERENCES tbAddress_IslandGroup(id),
	CONSTRAINT fk_tbAddress_Region_Log_userModifiedID FOREIGN KEY (userModifiedID) REFERENCES tbUsers(id)
)

CREATE TABLE tbAddress_CityProvince (
	id				TINYINT		NOT NULL IDENTITY,
	name			VARCHAR(30)	NOT NULL,
	regionID		TINYINT		NOT NULL,
	dateModified	DATETIME	NOT NULL CONSTRAINT def_tbAddress_CityProvince_dateModified DEFAULT GETDATE(),
	userModifiedID	SMALLINT	NOT NULL
	CONSTRAINT pk_tbAddress_CityProvince PRIMARY KEY (id),
	CONSTRAINT uq_tbAddress_CityProvince_name UNIQUE (name),
	CONSTRAINT fk_tbAddress_CityProvince_regionID FOREIGN KEY (regionID) REFERENCES tbAddress_Region(id),
	CONSTRAINT fk_tbAddress_CityProvince_userModifiedID FOREIGN KEY (userModifiedID) REFERENCES tbUsers(id)
)

CREATE TABLE tbAddress_CityProvince_Log (
	id				SMALLINT	NOT NULL IDENTITY,
	cityProvinceID	TINYINT		NOT NULL,
	name			VARCHAR(30)	NOT NULL,
	regionID		TINYINT		NOT NULL,
	dateModified	DATETIME	NOT NULL CONSTRAINT def_tbAddress_CityProvince_Log_dateModified DEFAULT GETDATE(),
	userModifiedID	SMALLINT	NOT NULL
	CONSTRAINT pk_tbAddress_CityProvince_Log PRIMARY KEY (id),
	CONSTRAINT fk_tbAddress_CityProvince_Log_cityProvinceID FOREIGN KEY (cityProvinceID) REFERENCES tbAddress_CityProvince(id),
	CONSTRAINT fk_tbAddress_CityProvince_Log_regionID FOREIGN KEY (regionID) REFERENCES tbAddress_Region(id),
	CONSTRAINT fk_tbAddress_CityProvince_Log_userModifiedID FOREIGN KEY (userModifiedID) REFERENCES tbUsers(id)
)

PRINT 'TABLES CREATED.'

PRINT 'CREATING TRIGGERS...'

IF EXISTS (SELECT OBJECT_ID FROM sys.triggers WHERE name = 'tr_tbAddress_IslandGroup')
	DROP TRIGGER tr_tbAddress_IslandGroup

	GO
	CREATE TRIGGER tr_tbAddress_IslandGroup
	ON tbAddress_IslandGroup
	FOR INSERT, UPDATE AS
	BEGIN
		INSERT INTO tbAddress_IslandGroup_Log (id, name, userModifiedID)
		SELECT id, name, userModifiedID FROM INSERTED
	END
GO

IF EXISTS (SELECT OBJECT_ID FROM sys.triggers WHERE name = 'tr_tbAddress_Region')
	DROP TRIGGER tr_tbAddress_Region

	GO
	CREATE TRIGGER tr_tbAddress_Region
	ON tbAddress_Region
	AFTER INSERT, UPDATE AS
	BEGIN
		INSERT INTO tbAddress_Region_Log (regionID, name, alt_name, islandGroupID, userModifiedID)
		SELECT id, name, alt_name, islandGroupID, userModifiedID FROM INSERTED
	END
GO

IF EXISTS (SELECT OBJECT_ID FROM sys.triggers WHERE name = 'tr_tbAddress_CityProvince')
	DROP TRIGGER tr_tbAddress_CityProvincee

	GO
	CREATE TRIGGER tr_tbAddress_CityProvince
	ON tbAddress_CityProvince
	AFTER INSERT, UPDATE AS
	BEGIN
		INSERT INTO tbAddress_CityProvince_Log (cityProvinceID, name, regionID, userModifiedID)
		SELECT id, name, regionID, userModifiedID FROM INSERTED
	END
GO

PRINT 'TRIGGERS CREATED.'

PRINT 'INSERTING DATA...'

INSERT INTO tbAddress_IslandGroup (name, userModifiedID) VALUES ('LUZON', 1)
INSERT INTO tbAddress_IslandGroup (name, userModifiedID) VALUES ('VISAYAS', 1)
INSERT INTO tbAddress_IslandGroup (name, userModifiedID) VALUES ('MINDANAO', 1)

PRINT 'INSERTED ISLANDGROUP'

INSERT INTO tbAddress_Region (name, alt_name, islandGroupID, userModifiedID) VALUES ('NCR', 'NATIONAL CAPITAL REGION', 1, 1)
INSERT INTO tbAddress_Region (name, alt_name, islandGroupID, userModifiedID) VALUES ('REGION I', 'ILOCOS REGION', 1, 1)
INSERT INTO tbAddress_Region (name, alt_name, islandGroupID, userModifiedID) VALUES ('CAR', 'CORDILLERA ADMINISTRARIVE REGION', 1, 1)
INSERT INTO tbAddress_Region (name, alt_name, islandGroupID, userModifiedID) VALUES ('REGION II', 'CAGAYAN VALLEY', 1, 1)
INSERT INTO tbAddress_Region (name, alt_name, islandGroupID, userModifiedID) VALUES ('REGION III', 'CENTRAL LUZON', 1, 1)
INSERT INTO tbAddress_Region (name, alt_name, islandGroupID, userModifiedID) VALUES ('REGION IV - A', 'CALABARZON', 1, 1)
INSERT INTO tbAddress_Region (name, alt_name, islandGroupID, userModifiedID) VALUES ('REGION IV - B', 'MIMAROPA', 1, 1)
INSERT INTO tbAddress_Region (name, alt_name, islandGroupID, userModifiedID) VALUES ('REGION V', 'BICOL REGION', 1, 1)
INSERT INTO tbAddress_Region (name, alt_name, islandGroupID, userModifiedID) VALUES ('REGION VI', 'WESTERN VISAYAS', 2, 1)
INSERT INTO tbAddress_Region (name, alt_name, islandGroupID, userModifiedID) VALUES ('REGION XVIII', 'NEGROS ISLAND REGION', 2, 1)
INSERT INTO tbAddress_Region (name, alt_name, islandGroupID, userModifiedID) VALUES ('REGION VII', 'CENTRAL VISAYAS', 2, 1)
INSERT INTO tbAddress_Region (name, alt_name, islandGroupID, userModifiedID) VALUES ('REGION VIII', 'EASTERN VISAYAS', 2, 1)
INSERT INTO tbAddress_Region (name, alt_name, islandGroupID, userModifiedID) VALUES ('REGION IX', 'ZAMBOANGA PENINSULA', 3, 1)
INSERT INTO tbAddress_Region (name, alt_name, islandGroupID, userModifiedID) VALUES ('REGION X', 'NORTHERN MINDANAO', 3, 1)
INSERT INTO tbAddress_Region (name, alt_name, islandGroupID, userModifiedID) VALUES ('REGION XI', 'DAVAO REGION', 3, 1)
INSERT INTO tbAddress_Region (name, alt_name, islandGroupID, userModifiedID) VALUES ('REGION XII', 'SOCCSKSARGEN', 3, 1)
INSERT INTO tbAddress_Region (name, alt_name, islandGroupID, userModifiedID) VALUES ('REGION XIII', 'CARAGA', 3, 1)
INSERT INTO tbAddress_Region (name, alt_name, islandGroupID, userModifiedID) VALUES ('ARMM', 'AUTONOMOUS REGION IN MUSLIM MINDANAO', 3, 1)

PRINT 'INSERTED REGION'

INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('ABRA', '3', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('AGUSAN DEL NORTE', '17', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('AGUSAN DEL SUR', '17', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('AKLAN', '9', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('ALBAY', '8', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('ANGELES', '5', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('ANTIQUE', '9', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('APAYAO', '3', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('AURORA', '5', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('BACOLOD', '10', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('BAGUIO', '3', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('BASILAN', '18', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('BATAAN', '5', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('BATANES', '4', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('BATANGAS', '6', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('BENGUET', '3', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('BILIRAN', '12', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('BOHOL', '11', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('BUKIDNON', '14', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('BULACAN', '5', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('BUTUAN', '17', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('CAGAYAN', '4', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('CAGAYAN DE ORO', '14', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('CALOOCAN', '1', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('CAMARINES NORTE', '8', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('CAMARINES SUR', '8', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('CAMIGUIN', '14', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('CAPIZ', '9', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('CATANDUANES', '8', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('CAVITE', '6', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('CEBU', '11', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('CEBU CITY', '11', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('COMPOSTELA VALLEY', '15', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('COTABATO', '16', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('COTABATO CITY', '16', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('DAGUPAN', '2', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('DAVAO CITY', '15', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('DAVAO DEL NORTE', '15', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('DAVAO DEL SUR', '15', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('DAVAO OCCIDENTAL', '15', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('DAVAO ORIENTAL', '15', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('DINAGAT ISLANDS', '17', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('EASTERN SAMAR', '12', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('GENERAL SANTOS', '16', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('GUIMARAS', '9', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('IFUGAO', '3', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('ILIGAN', '14', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('ILOCOS NORTE', '2', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('ILOCOS SUR', '2', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('ILOILO', '9', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('ILOILO CITY', '9', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('ISABELA', '4', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('ISABELA CITY', '13', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('KALINGA', '3', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('LA UNION', '2', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('LAGUNA', '6', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('LANAO DEL NORTE', '14', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('LANAO DEL SUR', '18', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('LAPU-LAPU', '11', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('LAS PIÑAS', '1', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('LEYTE', '12', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('LUCENA', '6', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('MAGUINDANAO', '18', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('MAKATI', '1', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('MALABON', '1', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('MANDALUYONG', '1', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('MANDAUE', '11', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('MANILA', '1', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('MARIKINA', '1', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('MARINDUQUE', '7', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('MASBATE', '8', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('MISAMIS OCCIDENTAL', '14', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('MISAMIS ORIENTAL', '14', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('MOUNTAIN PROVINCE', '3', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('MUNTINLUPA', '1', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('NAGA', '8', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('NAVOTAS', '1', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('NEGROS OCCIDENTAL', '10', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('NEGROS ORIENTAL', '10', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('NORTHERN SAMAR', '12', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('NUEVA ECIJA', '5', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('NUEVA VIZCAYA', '4', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('OCCIDENTAL MINDORO', '7', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('OLONGAPO', '5', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('ORIENTAL MINDORO', '7', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('ORMOC', '12', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('PALAWAN', '7', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('PAMPANGA', '5', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('PANGASINAN', '2', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('PARAÑAQUE', '1', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('PASAY', '1', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('PASIG', '1', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('PATEROS', '1', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('PUERTO PRINCESA', '7', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('QUEZON', '6', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('QUEZON CITY', '1', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('QUIRINO', '4', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('RIZAL', '6', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('ROMBLON', '7', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('SAMAR', '12', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('SAN JUAN', '1', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('SANTIAGO', '5', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('SARANGANI', '16', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('SIQUIJOR', '11', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('SORSOGON', '8', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('SOUTH COTABATO', '16', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('SOUTHERN LEYTE', '12', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('SULTAN KUDARAT', '16', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('SULU', '18', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('SURIGAO DEL NORTE', '17', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('SURIGAO DEL SUR', '17', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('TACLOBAN', '12', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('TAGUIG', '1', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('TARLAC', '5', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('TAWI-TAWI', '18', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('VALENZUELA', '1', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('ZAMBALES', '5', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('ZAMBOANGA CITY', '13', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('ZAMBOANGA DEL NORTE', '13', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('ZAMBOANGA DEL SUR', '13', 1)
INSERT INTO tbAddress_CityProvince (name, regionID, userModifiedID) VALUES ('ZAMBOANGA SIBUGAY', '13', 1)

PRINT 'INSERTED CITYPROVINCE'

PRINT 'INSERT DONE.'

SELECT * FROM tbAddress_IslandGroup
SELECT * FROM tbAddress_IslandGroup_Log
SELECT * FROM tbAddress_Region
SELECT * FROM tbAddress_Region_Log
SELECT * FROM tbAddress_CityProvince
SELECT * FROM tbAddress_CityProvince_Log

SELECT *
FROM tbAddress_CityProvince cp
INNER JOIN tbAddress_Region r ON cp.regionID = r.id 
INNER JOIN tbAddress_IslandGroup ig ON r.islandGroupID = ig.id

/*******************************
	SHOWS FOREIGN KEY TABLES OF A TABLE
*******************************/

--EXEC sp_fkeys 'tbAddress_IslandGroup'

/*******************************
	CREATES STORED PROCEDURE WHERE ALTER STATEMENTS OF DROPPING ALL CONSTRAINTS ARE GENERATED
*******************************/

--CREATE PROCEDURE spGenerateDropConstraintStatements
--AS BEGIN
--	SELECT
--		' ALTER TABLE ' +
--		QUOTENAME(s.name) +
--		'.' +
--		QUOTENAME(t.name) +
--		' DROP CONSTRAINT ' +
--		QUOTENAME(c.name) +
--		';'
--	FROM		sys.objects AS c
--	INNER JOIN	sys.tables AS t ON c.parent_object_id = t.[object_id]
--	INNER JOIN sys.schemas AS s ON t.[schema_id] = s.[schema_id]
--	WHERE c.[type] IN ('D','C','F','PK','UQ')
--	ORDER BY c.[type]
--END

COMMIT TRAN